import { describe, expect, it, vi } from 'vitest';

import {
  type Env,
  type RateLimiter,
  type UpstreamFetch,
} from '../src/index';
import { handleStagingRequest } from '../src/staging';

const createEndpoint =
  'https://staging.funapp.world/api/founding-friend-payments/checkout-sessions';
const acceptingRateLimiter: RateLimiter = {
  async limit() {
    return { success: true };
  },
};

describe('staging payment entrypoint', () => {
  it('keeps creation disabled without Stripe I/O by default', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const response = await handleStagingRequest(
      createRequest(),
      stagingEnv(),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(response.status).toBe(503);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it.each([
    [
      'live expected mode',
      { STRIPE_EXPECTED_LIVEMODE: 'true' },
    ],
    [
      'live restricted key',
      { STRIPE_SECRET_KEY: 'rk_live_REDACTEDSAFEVALUE' },
    ],
    [
      'non-restricted sandbox key',
      { STRIPE_SECRET_KEY: 'sk_test_REDACTEDSAFEVALUE' },
    ],
    [
      'production return origin',
      { PUBLIC_APP_ORIGIN: 'https://funapp.world' },
    ],
  ])('rejects %s before Stripe I/O', async (_, override) => {
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const response = await handleStagingRequest(
      createRequest(),
      stagingEnv(override),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(response.status).toBe(500);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('rejects production hosts and unsupported paths before Stripe I/O', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const productionHost = await handleStagingRequest(
      createRequest(
        'https://funapp.world/api/founding-friend-payments/checkout-sessions',
      ),
      stagingEnv(),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );
    const unsupportedPath = await handleStagingRequest(
      createRequest(
        'https://staging.funapp.world/api/founding-friend-payments/unknown',
      ),
      stagingEnv(),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(productionHost.status).toBe(404);
    expect(unsupportedPath.status).toBe(404);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });
});

function stagingEnv(override: Partial<Env> = {}): Env {
  return {
    PAYMENT_CREATION_ENABLED: 'false',
    STRIPE_SECRET_KEY: 'rk_test_REDACTEDSAFEVALUE',
    STRIPE_PRICE_ID: 'price_test249gbp',
    STRIPE_EXPECTED_LIVEMODE: 'false',
    STRIPE_AUTOMATIC_TAX_ENABLED: 'false',
    PUBLIC_APP_ORIGIN: 'https://staging.funapp.world',
    PURCHASE_REFERENCE_SECRET: 'staging-reference-secret-at-least-32-chars',
    ...override,
  };
}

function createRequest(url = createEndpoint): Request {
  return new Request(url, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({
      email: 'alex@example.com',
      attemptId: '123e4567-e89b-42d3-a456-426614174000',
    }),
  });
}
