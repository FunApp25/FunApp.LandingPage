import { describe, expect, it, vi } from 'vitest';

import { hubSpotCountryValues } from '../src/hubspot-country-values';
import {
  handleRequest,
  type Env,
  type RateLimiter,
  type UpstreamFetch,
} from '../src/index';

const hereAndNowEndpoint =
  'https://funapp.world/api/registrations/here-and-now';
const foundingFriendEndpoint =
  'https://funapp.world/api/registrations/founding-friend';
const localHereAndNowEndpoint =
  'http://localhost:8787/api/registrations/here-and-now';
const hereAndNowFormGuid = '11111111-1111-1111-1111-111111111111';
const foundingFriendFormGuid = '22222222-2222-2222-2222-222222222222';

const enabledEnv: Env = {
  HUBSPOT_PORTAL_ID: '123456789',
  HUBSPOT_FORM_GUID: '00000000-0000-0000-0000-000000000000',
  HUBSPOT_HERE_AND_NOW_FORM_GUID: hereAndNowFormGuid,
  HUBSPOT_FOUNDING_FRIEND_FORM_GUID: foundingFriendFormGuid,
  REGISTRATION_SUBMISSIONS_ENABLED: 'true',
};
const allowedRateLimiter: RateLimiter = {
  limit: async () => ({ success: true }),
};
const hereAndNowRegistration = {
  firstName: 'Alex',
  lastName: 'Morgan',
  email: 'alex@example.com',
  age: 29,
  marketingConsent: false,
};
const foundingFriendRegistration = {
  firstName: 'Taylor',
  lastName: 'Jones',
  email: 'taylor@example.com',
  age: 31,
  country: 'United Kingdom',
  marketingConsent: true,
};

describe('registration routes', () => {
  it('dispatches Here & Now to its server-selected form and exact mapping', async () => {
    let capturedInput: RequestInfo | URL | undefined;
    let capturedBody = '';
    const response = await post(
      hereAndNowEndpoint,
      hereAndNowRegistration,
      async (input, init) => {
        capturedInput = input;
        capturedBody = init?.body as string;
        return new Response('not exposed', { status: 200 });
      },
    );

    expect(response.status).toBe(204);
    expect(capturedInput).toEqual(
      new URL(
        `https://api.hsforms.com/submissions/v3/integration/submit/123456789/${hereAndNowFormGuid}`,
      ),
    );
    expect(JSON.parse(capturedBody)).toEqual({
      fields: [
        { name: 'firstname', value: 'Alex' },
        { name: 'lastname', value: 'Morgan' },
        { name: 'email', value: 'alex@example.com' },
        { name: 'age', value: '29' },
        { name: 'marketing_consent', value: 'false' },
      ],
    });
    expect(capturedBody).not.toContain('formGuid');
    expect(capturedBody).not.toContain('legalConsentOptions');
  });

  it('dispatches Founding Friend with optionals and the exact mapping', async () => {
    let capturedInput: RequestInfo | URL | undefined;
    let capturedBody = '';
    const response = await post(
      foundingFriendEndpoint,
      {
        ...foundingFriendRegistration,
        gender: 'Non-binary',
        usageReason: 'Meet local people\nand join activities',
      },
      async (input, init) => {
        capturedInput = input;
        capturedBody = init?.body as string;
        return new Response(null, { status: 200 });
      },
    );

    expect(response.status).toBe(204);
    expect(capturedInput).toEqual(
      new URL(
        `https://api.hsforms.com/submissions/v3/integration/submit/123456789/${foundingFriendFormGuid}`,
      ),
    );
    expect(JSON.parse(capturedBody)).toEqual({
      fields: [
        { name: 'firstname', value: 'Taylor' },
        { name: 'lastname', value: 'Jones' },
        { name: 'email', value: 'taylor@example.com' },
        { name: 'age', value: '31' },
        { name: 'gender', value: 'Non-binary' },
        {
          name: 'usage_reason',
          value: 'Meet local people\nand join activities',
        },
        { name: 'marketing_consent', value: 'true' },
        { name: 'country', value: 'United Kingdom' },
      ],
    });
  });

  it.each([
    ['missing firstName', { ...hereAndNowRegistration, firstName: undefined }],
    ['missing marketingConsent', { ...hereAndNowRegistration, marketingConsent: undefined }],
    ['non-integer age', { ...hereAndNowRegistration, age: 29.5 }],
    ['string age', { ...hereAndNowRegistration, age: '29' }],
    ['string consent', { ...hereAndNowRegistration, marketingConsent: 'false' }],
    ['invalid email', { ...hereAndNowRegistration, email: 'invalid' }],
    ['multiline name', { ...hereAndNowRegistration, firstName: 'First\nName' }],
    ['unknown property', { ...hereAndNowRegistration, formGuid: hereAndNowFormGuid }],
    ['Here & Now country', { ...hereAndNowRegistration, country: 'United Kingdom' }],
    ['invalid gender', { ...hereAndNowRegistration, gender: 'Other' }],
  ])('rejects %s', async (_, body) => {
    const upstreamFetch = vi.fn<UpstreamFetch>(successfulUpstreamFetch);
    const response = await post(hereAndNowEndpoint, body, upstreamFetch);

    await expectError(response, 400, 'invalid_request');
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('requires Founding Friend country and accepts every canonical value', async () => {
    expect(hubSpotCountryValues.size).toBe(254);
    await expectError(
      await post(
        foundingFriendEndpoint,
        { ...foundingFriendRegistration, country: undefined },
      ),
      400,
      'invalid_request',
    );
    await expectError(
      await post(
        foundingFriendEndpoint,
        { ...foundingFriendRegistration, country: 'Not a canonical country' },
      ),
      400,
      'invalid_request',
    );

    for (const country of hubSpotCountryValues) {
      const response = await post(foundingFriendEndpoint, {
        ...foundingFriendRegistration,
        country,
      });
      expect(response.status, country).toBe(204);
    }
  });

  it('accepts all four canonical gender values and omits blank optionals', async () => {
    for (const gender of [
      'Man',
      'Woman',
      'Non-binary',
      'Prefer not to answer',
    ]) {
      let capturedBody = '';
      const response = await post(
        hereAndNowEndpoint,
        { ...hereAndNowRegistration, gender, usageReason: '   ' },
        async (_, init) => {
          capturedBody = init?.body as string;
          return new Response(null, { status: 200 });
        },
      );
      expect(response.status).toBe(204);
      expect(JSON.parse(capturedBody).fields).toContainEqual({
        name: 'gender',
        value: gender,
      });
      expect(JSON.parse(capturedBody).fields).not.toContainEqual({
        name: 'usage_reason',
        value: expect.any(String),
      });
    }
  });

  it('allows negative and zero integer ages without inventing eligibility', async () => {
    for (const age of [-1, 0]) {
      const response = await post(hereAndNowEndpoint, {
        ...hereAndNowRegistration,
        age,
      });
      expect(response.status).toBe(204);
    }
  });

  it('rejects unsupported methods and exact-route mismatches', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>(successfulUpstreamFetch);
    const methodResponse = await rawRequest(
      new Request(hereAndNowEndpoint, { method: 'GET' }),
      enabledEnv,
      upstreamFetch,
    );
    const pathResponse = await rawRequest(
      new Request(`${hereAndNowEndpoint}/extra`, { method: 'POST' }),
      enabledEnv,
      upstreamFetch,
    );

    expect(methodResponse.status).toBe(405);
    expect(methodResponse.headers.get('allow')).toBe('POST');
    await expectError(pathResponse, 404, 'not_found');
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('fails closed while disabled without rate limiting or provider I/O', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>(successfulUpstreamFetch);
    const rateLimiter = { limit: vi.fn(async () => ({ success: true })) };

    for (const configuredValue of [undefined, '', 'false']) {
      const response = await rawRequest(
        jsonRequest(hereAndNowEndpoint, hereAndNowRegistration),
        {
          ...enabledEnv,
          REGISTRATION_SUBMISSIONS_ENABLED: configuredValue,
        },
        upstreamFetch,
        rateLimiter,
      );
      await expectError(response, 503, 'service_unavailable');
    }

    expect(rateLimiter.limit).not.toHaveBeenCalled();
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it.each([
    ['malformed enable flag', { REGISTRATION_SUBMISSIONS_ENABLED: 'yes' }],
    ['missing portal', { HUBSPOT_PORTAL_ID: undefined }],
    ['malformed portal', { HUBSPOT_PORTAL_ID: 'portal' }],
    ['missing Here & Now form', { HUBSPOT_HERE_AND_NOW_FORM_GUID: undefined }],
    ['malformed form', { HUBSPOT_HERE_AND_NOW_FORM_GUID: 'not-a-guid' }],
  ])('fails closed for %s', async (_, override) => {
    const upstreamFetch = vi.fn<UpstreamFetch>(successfulUpstreamFetch);
    const response = await rawRequest(
      jsonRequest(hereAndNowEndpoint, hereAndNowRegistration),
      { ...enabledEnv, ...override },
      upstreamFetch,
    );

    await expectError(response, 500, 'unexpected');
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('requires the abuse-control binding before accepting data', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>(successfulUpstreamFetch);
    const response = await handleRequest(
      jsonRequest(hereAndNowEndpoint, hereAndNowRegistration),
      enabledEnv,
      { upstreamFetch },
    );

    await expectError(response, 500, 'unexpected');
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('returns 429 when the registration rate limiter denies the attempt', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>(successfulUpstreamFetch);
    const rateLimiter = {
      limit: vi.fn(async () => ({ success: false })),
    };
    const response = await rawRequest(
      jsonRequest(hereAndNowEndpoint, hereAndNowRegistration, {
        'cf-connecting-ip': '192.0.2.10',
      }),
      enabledEnv,
      upstreamFetch,
      rateLimiter,
    );

    await expectError(response, 429, 'rate_limited');
    expect(rateLimiter.limit).toHaveBeenCalledWith({
      key: '/api/registrations/here-and-now:192.0.2.10',
    });
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('fails unavailable if the rate-limit binding fails', async () => {
    const response = await rawRequest(
      jsonRequest(hereAndNowEndpoint, hereAndNowRegistration),
      enabledEnv,
      successfulUpstreamFetch,
      { limit: async () => Promise.reject(new Error('synthetic')) },
    );

    await expectError(response, 503, 'service_unavailable');
  });

  it('preserves the 16 KiB request-body protection', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>(successfulUpstreamFetch);
    const response = await post(
      hereAndNowEndpoint,
      { ...hereAndNowRegistration, usageReason: 'x'.repeat(16 * 1024) },
      upstreamFetch,
    );

    await expectError(response, 400, 'invalid_request');
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it.each([
    [400, 422, 'submission_rejected'],
    [429, 429, 'rate_limited'],
    [500, 503, 'service_unavailable'],
    [503, 503, 'service_unavailable'],
    [418, 500, 'unexpected'],
  ])('maps HubSpot %s to sanitized %s', async (provider, status, code) => {
    const response = await post(
      hereAndNowEndpoint,
      hereAndNowRegistration,
      async () =>
        new Response('alex@example.com provider detail', { status: provider }),
    );

    await expectError(response, status, code);
  });

  it('maps provider network and timeout failures without retrying', async () => {
    const networkFetch = vi.fn<UpstreamFetch>(async () => {
      throw new TypeError('synthetic network failure');
    });
    await expectError(
      await post(hereAndNowEndpoint, hereAndNowRegistration, networkFetch),
      503,
      'service_unavailable',
    );
    expect(networkFetch).toHaveBeenCalledTimes(1);

    const timeoutFetch = vi.fn<UpstreamFetch>(
      (_, init) =>
        new Promise<Response>((_, reject) => {
          init?.signal?.addEventListener('abort', () =>
            reject(new DOMException('', 'AbortError')),
          );
        }),
    );
    const timeoutResponse = await rawRequest(
      jsonRequest(hereAndNowEndpoint, hereAndNowRegistration),
      enabledEnv,
      timeoutFetch,
      allowedRateLimiter,
      1,
    );
    await expectError(timeoutResponse, 503, 'service_unavailable');
    expect(timeoutFetch).toHaveBeenCalledTimes(1);
  });

  it.each([
    ['success', 204],
    ['provider_rejection', 422],
    ['rate_limited', 429],
    ['provider_unavailable', 503],
    ['network_failure', 503],
    ['timeout', 503],
  ])('serves local mock scenario %s without provider I/O', async (scenario, status) => {
    const upstreamFetch = vi.fn<UpstreamFetch>(successfulUpstreamFetch);
    const response = await rawRequest(
      jsonRequest(localHereAndNowEndpoint, hereAndNowRegistration, {
        origin: 'http://localhost:7357',
      }),
      {
        ...enabledEnv,
        LOCAL_DEVELOPMENT_ALLOWED_ORIGIN: 'http://localhost:7357',
        HUBSPOT_MOCK_SCENARIO: scenario,
      },
      upstreamFetch,
    );

    expect(response.status).toBe(status);
    expect(response.headers.get('access-control-allow-origin')).toBe(
      'http://localhost:7357',
    );
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('supports local mock CORS preflight but not production CORS', async () => {
    const localEnv = {
      ...enabledEnv,
      LOCAL_DEVELOPMENT_ALLOWED_ORIGIN: 'http://localhost:7357',
      HUBSPOT_MOCK_SCENARIO: 'success',
    };
    const preflight = await rawRequest(
      new Request(localHereAndNowEndpoint, {
        method: 'OPTIONS',
        headers: { origin: 'http://localhost:7357' },
      }),
      localEnv,
    );
    const productionPreflight = await rawRequest(
      new Request(hereAndNowEndpoint, { method: 'OPTIONS' }),
      enabledEnv,
    );

    expect(preflight.status).toBe(204);
    expect(preflight.headers.get('access-control-allow-origin')).toBe(
      'http://localhost:7357',
    );
    expect(productionPreflight.status).toBe(405);
    expect(
      productionPreflight.headers.get('access-control-allow-origin'),
    ).toBeNull();
  });

  it('fails closed if local mock configuration appears on a deployed host', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>(successfulUpstreamFetch);
    const response = await rawRequest(
      jsonRequest(hereAndNowEndpoint, hereAndNowRegistration),
      {
        ...enabledEnv,
        LOCAL_DEVELOPMENT_ALLOWED_ORIGIN: 'http://localhost:7357',
        HUBSPOT_MOCK_SCENARIO: 'success',
      },
      upstreamFetch,
    );

    expect(response.status).toBe(500);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('does not log registration data or provider responses', async () => {
    const spies = [
      vi.spyOn(console, 'log').mockImplementation(() => undefined),
      vi.spyOn(console, 'info').mockImplementation(() => undefined),
      vi.spyOn(console, 'warn').mockImplementation(() => undefined),
      vi.spyOn(console, 'error').mockImplementation(() => undefined),
    ];

    try {
      const response = await post(
        hereAndNowEndpoint,
        hereAndNowRegistration,
        async () => new Response('private provider response', { status: 400 }),
      );
      expect(response.status).toBe(422);
      for (const spy of spies) {
        expect(spy).not.toHaveBeenCalled();
      }
    } finally {
      for (const spy of spies) spy.mockRestore();
    }
  });
});

const successfulUpstreamFetch: UpstreamFetch = async () =>
  new Response(null, { status: 200 });

async function post(
  endpoint: string,
  body: Record<string, unknown>,
  upstreamFetch: UpstreamFetch = successfulUpstreamFetch,
): Promise<Response> {
  return rawRequest(jsonRequest(endpoint, body), enabledEnv, upstreamFetch);
}

function jsonRequest(
  endpoint: string,
  body: Record<string, unknown>,
  headers: HeadersInit = {},
): Request {
  const requestHeaders = new Headers(headers);
  requestHeaders.set('content-type', 'application/json; charset=utf-8');
  return new Request(endpoint, {
    method: 'POST',
    headers: requestHeaders,
    body: JSON.stringify(body),
  });
}

async function rawRequest(
  request: Request,
  env: Env,
  upstreamFetch: UpstreamFetch = successfulUpstreamFetch,
  registrationRateLimiter: RateLimiter = allowedRateLimiter,
  submissionTimeoutMs?: number,
): Promise<Response> {
  return handleRequest(request, env, {
    upstreamFetch,
    registrationRateLimiter,
    submissionTimeoutMs,
  });
}

async function expectError(
  response: Response,
  status: number,
  code: string,
): Promise<void> {
  expect(response.status).toBe(status);
  const body = await response.json();
  expect(body).toEqual({ code, requestId: expect.any(String) });
  expect(JSON.stringify(body)).not.toContain('alex@example.com');
  expect(JSON.stringify(body)).not.toContain('provider detail');
}
