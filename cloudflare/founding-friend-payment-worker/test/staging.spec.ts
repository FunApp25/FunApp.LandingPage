import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import {
  handleRequest,
  worker,
  type CheckoutFailureDiagnostic,
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
const errorLog = vi.fn();

beforeEach(() => {
  vi.spyOn(console, 'error').mockImplementation(errorLog);
});

afterEach(() => {
  vi.restoreAllMocks();
  errorLog.mockClear();
});

describe('staging payment entrypoint', () => {
  it('keeps creation disabled without Stripe I/O by default', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const response = await handleStagingRequest(createRequest(), stagingEnv(), {
      upstreamFetch,
      paymentRateLimiter: acceptingRateLimiter,
    });

    expect(response.status).toBe(503);
    expect(upstreamFetch).not.toHaveBeenCalled();
    expect(errorLog).not.toHaveBeenCalled();
  });

  it.each([
    [
      'live expected mode',
      { STRIPE_EXPECTED_LIVEMODE: 'true' },
      'staging_livemode',
    ],
    [
      'live restricted key',
      { STRIPE_SECRET_KEY: 'rk_live_REDACTEDSAFEVALUE' },
      'staging_stripe_key',
    ],
    [
      'non-restricted sandbox key',
      { STRIPE_SECRET_KEY: 'sk_test_REDACTEDSAFEVALUE' },
      'staging_stripe_key',
    ],
    [
      'production return origin',
      { PUBLIC_APP_ORIGIN: 'https://funapp.world' },
      'staging_origin',
    ],
  ] as const)('rejects %s before Stripe I/O', async (_, override, stage) => {
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const response = await handleStagingRequest(
      createRequest(),
      stagingEnv(override),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    await expectFailure(response, stage, 'configuration_invalid');
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
    expect(errorLog).not.toHaveBeenCalled();
  });
});

describe('staging Checkout failure diagnostics', () => {
  it.each([
    [
      'missing secret',
      { PURCHASE_REFERENCE_SECRET: undefined },
      'purchase_reference_secret',
    ],
    [
      'empty secret',
      { PURCHASE_REFERENCE_SECRET: '' },
      'purchase_reference_secret',
    ],
    [
      'short secret',
      { PURCHASE_REFERENCE_SECRET: 'short' },
      'purchase_reference_secret',
    ],
    [
      'LF secret',
      { PURCHASE_REFERENCE_SECRET: `${'x'.repeat(32)}\n` },
      'purchase_reference_secret',
    ],
    [
      'CR secret',
      { PURCHASE_REFERENCE_SECRET: `\r${'x'.repeat(32)}` },
      'purchase_reference_secret',
    ],
    [
      'CRLF secret',
      { PURCHASE_REFERENCE_SECRET: `${'x'.repeat(32)}\r\n` },
      'purchase_reference_secret',
    ],
    [
      'local mock setting',
      { STRIPE_MOCK_SCENARIO: 'paid' },
      'mock_configuration',
    ],
    [
      'local origin setting',
      { LOCAL_DEVELOPMENT_ALLOWED_ORIGIN: 'http://localhost:7357' },
      'mock_configuration',
    ],
    [
      'invalid enablement',
      { PAYMENT_CREATION_ENABLED: 'yes' },
      'payment_availability',
    ],
    ['missing key', { STRIPE_SECRET_KEY: undefined }, 'stripe_configuration'],
    ['missing Price', { STRIPE_PRICE_ID: undefined }, 'stripe_configuration'],
    ['invalid Price', { STRIPE_PRICE_ID: 'invalid' }, 'stripe_configuration'],
    [
      'missing tax flag',
      { STRIPE_AUTOMATIC_TAX_ENABLED: undefined },
      'automatic_tax',
    ],
    [
      'invalid tax flag',
      { STRIPE_AUTOMATIC_TAX_ENABLED: 'yes' },
      'automatic_tax',
    ],
  ] as const)(
    'correlates %s with its configuration stage',
    async (_, override, stage) => {
      const upstreamFetch = vi.fn<UpstreamFetch>();
      const response = await handleStagingRequest(
        createRequest(),
        stagingEnv({ PAYMENT_CREATION_ENABLED: 'true', ...override }),
        { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
      );

      await expectFailure(response, stage, 'configuration_invalid');
      expect(upstreamFetch).not.toHaveBeenCalled();
    },
  );

  it('identifies a missing rate limiter', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const response = await handleStagingRequest(
      createRequest(),
      stagingEnv({ PAYMENT_CREATION_ENABLED: 'true' }),
      { upstreamFetch },
    );

    await expectFailure(response, 'rate_limiter', 'configuration_invalid');
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('keeps concurrent failures correlated with their own response', async () => {
    const responses = await Promise.all([
      handleStagingRequest(
        createRequest(),
        stagingEnv({ PAYMENT_CREATION_ENABLED: 'yes' }),
      ),
      handleStagingRequest(
        createRequest(),
        stagingEnv({
          PAYMENT_CREATION_ENABLED: 'true',
          PURCHASE_REFERENCE_SECRET: undefined,
        }),
        { paymentRateLimiter: acceptingRateLimiter },
      ),
    ]);
    const bodies = (await Promise.all(
      responses.map((response) => response.json()),
    )) as Array<{
      error: { requestId: string };
    }>;
    expect(bodies[0].error.requestId).not.toBe(bodies[1].error.requestId);
    expect(errorLog.mock.calls.map(([line]) => JSON.parse(line))).toEqual([
      {
        requestId: bodies[0].error.requestId,
        stage: 'payment_availability',
        category: 'configuration_invalid',
      },
      {
        requestId: bodies[1].error.requestId,
        stage: 'purchase_reference_secret',
        category: 'configuration_invalid',
      },
    ]);
  });

  it.each(['importKey', 'sign'] as const)(
    'sanitizes HMAC %s failures',
    async (method) => {
      const env = stagingEnv({ PAYMENT_CREATION_ENABLED: 'true' });
      const request = createRequest();
      request.headers.set('authorization', 'Bearer synthetic-private-header');
      request.headers.set('cookie', 'synthetic-private-cookie');
      request.headers.set('x-request-id', 'untrusted-request-id');
      const sensitive = [
        'alex@example.com',
        '123e4567-e89b-42d3-a456-426614174000',
        'FF-1234567890ABCDEF',
        env.STRIPE_SECRET_KEY,
        env.PURCHASE_REFERENCE_SECRET,
        request.headers.get('authorization'),
        request.headers.get('cookie'),
        'untrusted-request-id',
        'synthetic-stack-trace',
      ];
      const error = new Error(sensitive.join(' '));
      error.stack = 'synthetic-stack-trace';
      vi.spyOn(crypto.subtle, method).mockRejectedValue(error);
      const upstreamFetch = vi.fn<UpstreamFetch>();
      const response = await handleStagingRequest(request, env, {
        upstreamFetch,
        paymentRateLimiter: acceptingRateLimiter,
      });

      await expectFailure(
        response,
        'purchase_reference_hmac',
        'runtime_unexpected',
      );
      expect(upstreamFetch).not.toHaveBeenCalled();
      const output = JSON.stringify(errorLog.mock.calls);
      for (const value of sensitive) {
        expect(output).not.toContain(value);
      }
    },
  );

  it('identifies unexpected body-reading exceptions without logging the exception', async () => {
    const request = createRequest();
    vi.spyOn(request.body!, 'getReader').mockImplementation(() => {
      throw new Error('synthetic-private-body-error');
    });
    const upstreamFetch = vi.fn<UpstreamFetch>();
    const response = await handleStagingRequest(
      request,
      stagingEnv({ PAYMENT_CREATION_ENABLED: 'true' }),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    await expectFailure(response, 'request_validation', 'runtime_unexpected');
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('keeps the existing 500 response if the diagnostic sink throws', async () => {
    errorLog.mockImplementationOnce(() => {
      throw new Error('synthetic-log-sink-failure');
    });
    const response = await handleStagingRequest(
      createRequest(),
      stagingEnv({
        PAYMENT_CREATION_ENABLED: 'true',
        PURCHASE_REFERENCE_SECRET: undefined,
      }),
      { paymentRateLimiter: acceptingRateLimiter },
    );

    await expectFailure(
      response,
      'purchase_reference_secret',
      'configuration_invalid',
    );
  });

  it('preserves rate-limiter exceptions as 503 without a 500 diagnostic', async () => {
    const response = await handleStagingRequest(
      createRequest(),
      stagingEnv({ PAYMENT_CREATION_ENABLED: 'true' }),
      {
        paymentRateLimiter: {
          async limit() {
            throw new Error('synthetic-limiter-failure');
          },
        },
      },
    );

    expect(response.status).toBe(503);
    expect(errorLog).not.toHaveBeenCalled();
  });

  it.each(['configuration', 'hmac', 'body'] as const)(
    'keeps production %s failures silent even on the staging hostname',
    async (failure) => {
      const request = createRequest();
      if (failure === 'hmac') {
        vi.spyOn(crypto.subtle, 'sign').mockRejectedValue(
          new Error('synthetic-hmac-failure'),
        );
      } else if (failure === 'body') {
        vi.spyOn(request.body!, 'getReader').mockImplementation(() => {
          throw new Error('synthetic-body-failure');
        });
      }
      const env = stagingEnv({
        PAYMENT_CREATION_ENABLED: 'true',
        ...(failure === 'configuration'
          ? { PURCHASE_REFERENCE_SECRET: undefined }
          : {}),
        PAYMENT_RATE_LIMITER: acceptingRateLimiter,
      });
      const response = await worker.fetch(request, env);

      expect(response.status).toBe(500);
      expect(errorLog).not.toHaveBeenCalled();
    },
  );

  it('does not attach creation diagnostics to shared verification', async () => {
    const reportFailure = vi.fn();
    const response = await handleRequest(
      new Request(`${createEndpoint}/verify`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          sessionId: 'cs_test_abcdefghijklmnopqrstuvwxyz123456',
        }),
      }),
      stagingEnv(),
      {},
      reportFailure,
    );

    expect(response.status).toBe(500);
    expect(reportFailure).not.toHaveBeenCalled();
    expect(errorLog).not.toHaveBeenCalled();
  });
});

async function expectFailure(
  response: Response,
  stage: CheckoutFailureDiagnostic['stage'],
  category: CheckoutFailureDiagnostic['category'],
): Promise<void> {
  expect(response.status).toBe(500);
  expect(response.headers.get('cache-control')).toBe('no-store');
  const body = (await response.json()) as {
    error: { code: string; requestId: string };
  };
  expect(body).toEqual({
    error: {
      code: 'unexpected',
      requestId: expect.stringMatching(/^[a-f0-9-]{36}$/),
    },
  });
  expect(errorLog).toHaveBeenCalledExactlyOnceWith(
    JSON.stringify({
      requestId: body.error.requestId,
      stage,
      category,
    }),
  );
}

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
