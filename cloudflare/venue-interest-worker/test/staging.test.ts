import { describe, expect, it, vi } from 'vitest';

import { handleRequest, type Env, type UpstreamFetch } from '../src/index';
import {
  handleStagingRequest,
  type StagingEnv,
} from '../src/staging';

const hereAndNowEndpoint =
  'https://staging.funapp.world/api/registrations/here-and-now';
const allowedRateLimiter = {
  async limit() {
    return { success: true };
  },
};

const validRegistration = {
  firstName: 'Alex',
  lastName: 'Morgan',
  email: 'alex@example.com',
  age: 29,
  marketingConsent: false,
};

describe('staging registration entrypoint', () => {
  it('accepts a valid registration without HubSpot configuration or I/O', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const response = await handleStagingRequest(
      registrationRequest(hereAndNowEndpoint),
      stagingEnv(),
      { upstreamFetch },
    );

    expect(response.status).toBe(204);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('supports Founding Friend through the same no-I/O staging adapter', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const response = await handleStagingRequest(
      registrationRequest(
        'https://staging.funapp.world/api/registrations/founding-friend',
        { ...validRegistration, country: 'United Kingdom' },
      ),
      stagingEnv(),
      { upstreamFetch },
    );

    expect(response.status).toBe(204);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('fails closed without the staging rate-limit binding', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const response = await handleStagingRequest(
      registrationRequest(hereAndNowEndpoint),
      { STAGING_REGISTRATION_MOCK_ENABLED: 'true' },
      { upstreamFetch },
    );

    expect(response.status).toBe(500);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it.each([
    ['missing', null, 503],
    ['disabled', 'false', 503],
    ['invalid', 'yes', 500],
  ])('fails closed for %s staging configuration', async (_, value, status) => {
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const response = await handleStagingRequest(
      registrationRequest(hereAndNowEndpoint),
      stagingEnv(value),
      { upstreamFetch },
    );

    expect(response.status).toBe(status);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('rejects non-staging hosts and unsupported staging paths without I/O', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const productionHost = await handleStagingRequest(
      registrationRequest(
        'https://funapp.world/api/registrations/here-and-now',
      ),
      stagingEnv(),
      { upstreamFetch },
    );
    const venuePath = await handleStagingRequest(
      registrationRequest('https://staging.funapp.world/api/venue-interest'),
      stagingEnv(),
      { upstreamFetch },
    );

    expect(productionHost.status).toBe(404);
    expect(venuePath.status).toBe(404);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('does not let the production entrypoint select the staging adapter', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>(async () =>
      new Response(null, { status: 200 })
    );
    const productionEnv: Env & { STAGING_REGISTRATION_MOCK_ENABLED: string } = {
      HUBSPOT_PORTAL_ID: '123456789',
      HUBSPOT_HERE_AND_NOW_FORM_GUID:
        '11111111-1111-1111-1111-111111111111',
      REGISTRATION_SUBMISSIONS_ENABLED: 'true',
      STAGING_REGISTRATION_MOCK_ENABLED: 'true',
    };
    const response = await handleRequest(
      registrationRequest(
        'https://funapp.world/api/registrations/here-and-now',
      ),
      productionEnv,
      {
        upstreamFetch,
        registrationRateLimiter: allowedRateLimiter,
      },
    );

    expect(response.status).toBe(204);
    expect(upstreamFetch).toHaveBeenCalledTimes(1);
  });
});

function stagingEnv(
  enabled: string | null = 'true',
): StagingEnv {
  if (enabled === null) {
    return { REGISTRATION_RATE_LIMITER: allowedRateLimiter };
  } else {
    return {
      STAGING_REGISTRATION_MOCK_ENABLED: enabled,
      REGISTRATION_RATE_LIMITER: allowedRateLimiter,
    };
  }
}

function registrationRequest(
  url: string,
  body: Record<string, unknown> = validRegistration,
): Request {
  return new Request(url, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(body),
  });
}
