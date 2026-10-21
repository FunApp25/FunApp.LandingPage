import { describe, expect, it, vi } from 'vitest';

import {
  type Env,
  type RateLimiter,
  handleRequest,
} from '../src/index';

const createPath = '/api/founding-friend-payments/checkout-sessions';
const verifyPath =
  '/api/founding-friend-payments/checkout-sessions/verify';
const attemptId = '123e4567-e89b-42d3-a456-426614174000';
const email = 'founder@example.com';
const sessionId = 'cs_test_abcdefghijklmnopqrstuvwxyz123456';

const acceptingRateLimiter: RateLimiter = {
  async limit() {
    return { success: true };
  },
};

describe('Founding Friend payment Worker', () => {
  it('fails closed without provider I/O when creation is disabled', async () => {
    const upstreamFetch = vi.fn();
    const response = await handleRequest(
      createRequest(),
      productionEnv({ PAYMENT_CREATION_ENABLED: 'false' }),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(response.status).toBe(503);
    expect(upstreamFetch).not.toHaveBeenCalled();
    expect(await response.json()).toMatchObject({
      error: { code: 'service_unavailable' },
    });
  });

  it('treats malformed enablement as invalid configuration', async () => {
    const upstreamFetch = vi.fn();
    const response = await handleRequest(
      createRequest(),
      productionEnv({ PAYMENT_CREATION_ENABLED: 'yes' }),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(response.status).toBe(500);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('validates the complete £249 contract without requiring a Customer before Checkout completes', async () => {
    const requests: Array<{ url: string; init?: RequestInit }> = [];
    const upstreamFetch = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      requests.push({ url: input.toString(), init });
      if (input.toString().includes('/v1/prices/')) {
        return Response.json(validPrice());
      }
      const body = new URLSearchParams(init?.body as string);
      return Response.json(
        validCreatedSession(body.get('client_reference_id')),
      );
    });

    const response = await handleRequest(createRequest(), productionEnv(), {
      upstreamFetch,
      paymentRateLimiter: acceptingRateLimiter,
    });

    expect(response.status).toBe(201);
    expect(requests).toHaveLength(2);
    expect(requests[0]?.url).toContain('/v1/prices/price_test249gbp');
    const create = requests[1];
    const parameters = new URLSearchParams(create?.init?.body as string);
    expect(parameters.get('mode')).toBe('payment');
    expect(parameters.get('line_items[0][price]')).toBe(
      'price_test249gbp',
    );
    expect(parameters.get('line_items[0][quantity]')).toBe('1');
    expect(parameters.get('customer_email')).toBe(email);
    expect(parameters.get('customer_creation')).toBe('always');
    expect(parameters.get('automatic_tax[enabled]')).toBe('false');
    expect(parameters.get('expand[]')).toBe('line_items.data.price');
    expect(parameters.get('client_reference_id')).toMatch(
      /^FF-[A-F0-9]{16}$/,
    );
    expect(parameters.get('metadata[purchase_reference]')).toBe(
      parameters.get('client_reference_id'),
    );
    expect(parameters.get('metadata[automatic_tax_enabled]')).toBe('false');
    expect(
      parameters.get('payment_intent_data[metadata][purchase_reference]'),
    ).toBe(parameters.get('client_reference_id'));
    expect(
      parameters.get('payment_intent_data[metadata][automatic_tax_enabled]'),
    ).toBe('false');
    expect(parameters.has('payment_method_types[0]')).toBe(false);
    expect(parameters.has('allow_promotion_codes')).toBe(false);
    expect(parameters.get('success_url')).toBe(
      'https://funapp.world/#/founding-friend/payment?session_id={CHECKOUT_SESSION_ID}',
    );
    expect(parameters.get('cancel_url')).toBe(
      'https://funapp.world/#/founding-friend/payment/cancelled',
    );
    const createHeaders = new Headers(create?.init?.headers);
    expect(createHeaders.get('content-type')).toBe(
      'application/x-www-form-urlencoded',
    );
    expect(createHeaders.get('idempotency-key')).toBe(
      `founding-friend-checkout-v1-${attemptId}`,
    );
    expect(createHeaders.get('authorization')).toBe(
      'Bearer rk_test_REDACTEDSAFEVALUE',
    );
    expect(createHeaders.get('stripe-version')).toBe(
      '2026-08-26.dahlia',
    );
    expect(parameters.get('integration_identifier')).toMatch(
      /^funapp_founding_friend_[a-z]{8}$/,
    );
    const responseBody = (await response.json()) as Record<string, unknown>;
    expect(responseBody).toMatchObject({
      checkoutUrl: 'https://checkout.stripe.com/c/pay/cs_test_safe',
      sessionId,
    });
    expect(responseBody.email).toBeUndefined();
    expect(responseBody.purchaseReference).toBeUndefined();
  });

  it.each([
    ['missing Stripe key', { STRIPE_SECRET_KEY: undefined }],
    ['key and mode mismatch', { STRIPE_SECRET_KEY: 'rk_live_REDACTEDSAFEVALUE' }],
    ['invalid live-mode flag', { STRIPE_EXPECTED_LIVEMODE: 'preview' }],
    ['missing automatic-tax flag', { STRIPE_AUTOMATIC_TAX_ENABLED: undefined }],
    ['invalid automatic-tax flag', { STRIPE_AUTOMATIC_TAX_ENABLED: 'approved' }],
    ['missing Price', { STRIPE_PRICE_ID: undefined }],
    ['unsafe public origin', { PUBLIC_APP_ORIGIN: 'http://funapp.world' }],
    ['short reference secret', { PURCHASE_REFERENCE_SECRET: 'short' }],
  ])('fails closed for %s configuration before provider I/O', async (_, override) => {
    const upstreamFetch = vi.fn();
    const response = await handleRequest(
      createRequest(),
      productionEnv(override),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(response.status).toBe(500);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('fails closed without the required rate limiter binding', async () => {
    const upstreamFetch = vi.fn();
    const response = await handleRequest(
      createRequest(),
      productionEnv(),
      { upstreamFetch },
    );

    expect(response.status).toBe(500);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it.each([
    ['inactive', { active: false }],
    ['wrong currency', { currency: 'usd' }],
    ['wrong amount', { unit_amount: 24_901 }],
    ['recurring', { type: 'recurring', recurring: { interval: 'month' } }],
    ['wrong environment', { livemode: true }],
    ['non-inclusive tax behavior', { tax_behavior: 'exclusive' }],
    ['custom amount', { custom_unit_amount: { minimum: 1 } }],
  ])('rejects %s Price configuration before session creation', async (_, override) => {
    const upstreamFetch = vi.fn(async () =>
      Response.json({ ...validPrice(), ...override }),
    );
    const response = await handleRequest(createRequest(), productionEnv(), {
      upstreamFetch,
      paymentRateLimiter: acceptingRateLimiter,
    });

    expect(response.status).toBe(502);
    expect(upstreamFetch).toHaveBeenCalledTimes(1);
    expect(await response.json()).toMatchObject({
      error: { code: 'provider_validation_failed' },
    });
  });

  it('supports explicitly enabled automatic tax without inheriting account defaults', async () => {
    const upstreamFetch = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      if (input.toString().includes('/v1/prices/')) {
        return Response.json(validPrice());
      }
      const body = new URLSearchParams(init?.body as string);
      return Response.json(
        validCreatedSession(body.get('client_reference_id'), {
          automatic_tax: { enabled: true },
          metadata: {
            purchase_reference: body.get('client_reference_id'),
            automatic_tax_enabled: 'true',
          },
        }),
      );
    });

    const response = await handleRequest(
      createRequest(),
      productionEnv({ STRIPE_AUTOMATIC_TAX_ENABLED: 'true' }),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(response.status).toBe(201);
    const create = upstreamFetch.mock.calls[1]?.[1];
    const parameters = new URLSearchParams(create?.body as string);
    expect(parameters.get('automatic_tax[enabled]')).toBe('true');
    expect(parameters.get('metadata[automatic_tax_enabled]')).toBe('true');
  });

  it.each([
    ['environment', { livemode: true }],
    ['mode', { mode: 'subscription' }],
    ['currency', { currency: 'usd' }],
    ['total', { amount_total: 24_901 }],
    ['Customer creation', { customer_creation: 'if_required' }],
    ['automatic tax', { automatic_tax: { enabled: true } }],
    ['purchase reference', { client_reference_id: 'FF-0000000000000000' }],
    [
      'purchase-reference metadata',
      { metadata: { automatic_tax_enabled: 'false' } },
    ],
    [
      'Price',
      {
        line_items: {
          data: [
            {
              quantity: 1,
              price: { id: 'price_wrong', tax_behavior: 'inclusive' },
            },
          ],
        },
      },
    ],
    [
      'quantity',
      {
        line_items: {
          data: [
            {
              quantity: 2,
              price: {
                id: 'price_test249gbp',
                tax_behavior: 'inclusive',
              },
            },
          ],
        },
      },
    ],
    [
      'inclusive tax behavior',
      {
        line_items: {
          data: [
            {
              quantity: 1,
              price: {
                id: 'price_test249gbp',
                tax_behavior: 'exclusive',
              },
            },
          ],
        },
      },
    ],
  ])('rejects a created Session with mismatched %s before redirect', async (_, override) => {
    const upstreamFetch = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      if (input.toString().includes('/v1/prices/')) {
        return Response.json(validPrice());
      }
      const body = new URLSearchParams(init?.body as string);
      return Response.json(
        validCreatedSession(body.get('client_reference_id'), override),
      );
    });

    const response = await handleRequest(createRequest(), productionEnv(), {
      upstreamFetch,
      paymentRateLimiter: acceptingRateLimiter,
    });

    expect(response.status).toBe(502);
    expect(upstreamFetch).toHaveBeenCalledTimes(2);
    expect(await response.json()).toMatchObject({
      error: { code: 'provider_validation_failed' },
    });
  });

  it('rejects a created Session whose stored tax choice differs from Stripe', async () => {
    const upstreamFetch = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      if (input.toString().includes('/v1/prices/')) {
        return Response.json(validPrice());
      }
      const body = new URLSearchParams(init?.body as string);
      const reference = body.get('client_reference_id');
      return Response.json(
        validCreatedSession(reference, {
          metadata: {
            purchase_reference: reference,
            automatic_tax_enabled: 'true',
          },
        }),
      );
    });

    const response = await handleRequest(createRequest(), productionEnv(), {
      upstreamFetch,
      paymentRateLimiter: acceptingRateLimiter,
    });

    expect(response.status).toBe(502);
    expect(await response.json()).toMatchObject({
      error: { code: 'provider_validation_failed' },
    });
  });

  it('uses stable purchase references, bodies and Stripe idempotency on retry', async () => {
    const creates: RequestInit[] = [];
    const upstreamFetch = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      if (input.toString().includes('/v1/prices/')) {
        return Response.json(validPrice());
      }
      creates.push(init ?? {});
      const body = new URLSearchParams(init?.body as string);
      return Response.json(
        validCreatedSession(body.get('client_reference_id'), {
          url: 'https://checkout.stripe.com/c/pay/cs_test_retry',
        }),
      );
    });

    for (let index = 0; index < 2; index += 1) {
      const response = await handleRequest(createRequest(), productionEnv(), {
        upstreamFetch,
        paymentRateLimiter: acceptingRateLimiter,
      });
      expect(response.status).toBe(201);
    }

    expect(creates).toHaveLength(2);
    expect(creates[0]?.body).toBe(creates[1]?.body);
    expect(new Headers(creates[0]?.headers).get('idempotency-key')).toBe(
      `founding-friend-checkout-v1-${attemptId}`,
    );
    expect(new Headers(creates[1]?.headers).get('idempotency-key')).toBe(
      `founding-friend-checkout-v1-${attemptId}`,
    );
  });

  it('runs every normal local mock without Stripe I/O', async () => {
    for (const scenario of [
      'created',
      'paid',
      'pending',
      'cancelled',
      'expired',
      'refunded',
      'disputed',
    ]) {
      const upstreamFetch = vi.fn();
      const response = await handleRequest(
        createRequest('http://localhost:8788'),
        mockEnv(scenario),
        { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
      );
      expect(response.status, scenario).toBe(201);
      expect(upstreamFetch, scenario).not.toHaveBeenCalled();
      const body = (await response.json()) as Record<string, unknown>;
      expect(body.sessionId).toMatch(/^cs_mock_/);
      expect(body.checkoutUrl).toMatch(/^http:\/\/localhost:7357\/#\//);
    }
  });

  it('replays a duplicate local attempt with a stable idempotent outcome', async () => {
    const upstreamFetch = vi.fn();
    const env = mockEnv('duplicate_attempt');
    const first = await handleRequest(
      createRequest('http://localhost:8788'),
      env,
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );
    const second = await handleRequest(
      createRequest('http://localhost:8788'),
      env,
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );
    const firstBody = (await first.json()) as Record<string, unknown>;
    const secondBody = (await second.json()) as Record<string, unknown>;

    expect(first.status).toBe(201);
    expect(second.status).toBe(201);
    expect(secondBody).toMatchObject({
      checkoutUrl: firstBody.checkoutUrl,
      sessionId: firstBody.sessionId,
    });
    expect(upstreamFetch).not.toHaveBeenCalled();

    const differentAttempt = await handleRequest(
      createRequest('http://localhost:8788', {
        email,
        attemptId: '223e4567-e89b-42d3-a456-426614174000',
      }),
      env,
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );
    expect(await differentAttempt.json()).not.toMatchObject({
      checkoutUrl: firstBody.checkoutUrl,
      sessionId: firstBody.sessionId,
    });
  });

  it.each([
    ['provider_validation_failure', 502, 'provider_validation_failed'],
    ['network_failure', 503, 'service_unavailable'],
    ['provider_unavailable', 503, 'service_unavailable'],
    ['timeout', 503, 'service_unavailable'],
  ])('classifies the %s local scenario', async (scenario, status, code) => {
    const upstreamFetch = vi.fn();
    const response = await handleRequest(
      createRequest('http://localhost:8788'),
      mockEnv(scenario),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );
    expect(response.status).toBe(status);
    expect(upstreamFetch).not.toHaveBeenCalled();
    expect(await response.json()).toMatchObject({ error: { code } });
  });

  it('keeps verification available when creation is disabled', async () => {
    const upstreamFetch = vi.fn(async () =>
      Response.json(validSession({ id: sessionId })),
    );
    const response = await handleRequest(
      verifyRequest(sessionId),
      productionEnv({ PAYMENT_CREATION_ENABLED: 'false' }),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(response.status).toBe(200);
    expect(await response.json()).toMatchObject({
      status: 'confirmed',
      purchaseReference: 'FF-1234567890ABCDEF',
    });
  });

  it('keeps verification tied to the Session when the creation tax flag changes', async () => {
    const upstreamFetch = vi.fn(async () =>
      Response.json(validSession()),
    );
    const response = await handleRequest(
      verifyRequest(sessionId),
      productionEnv({ STRIPE_AUTOMATIC_TAX_ENABLED: 'true' }),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(response.status).toBe(200);
    expect(await response.json()).toMatchObject({ status: 'confirmed' });
  });

  it('confirms a matching explicitly automatic-tax-enabled Session', async () => {
    const upstreamFetch = vi.fn(async () =>
      Response.json(
        validSession({
          automatic_tax: { enabled: true },
          metadata: {
            purchase_reference: 'FF-1234567890ABCDEF',
            automatic_tax_enabled: 'true',
          },
        }),
      ),
    );
    const response = await handleRequest(
      verifyRequest(sessionId),
      productionEnv({ STRIPE_AUTOMATIC_TAX_ENABLED: 'true' }),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(response.status).toBe(200);
    expect(await response.json()).toMatchObject({
      status: 'confirmed',
      purchaseReference: 'FF-1234567890ABCDEF',
    });
  });

  it.each([
    ['pending', 'pending'],
    ['expired', 'expired'],
    ['refunded', 'refunded'],
    ['disputed', 'disputed'],
    ['payment_mismatch', 'invalid'],
  ])('returns sanitized %s verification state', async (scenario, status) => {
    const createResponse = await handleRequest(
      createRequest('http://localhost:8788'),
      mockEnv(scenario),
      { paymentRateLimiter: acceptingRateLimiter },
    );
    const created = (await createResponse.json()) as { sessionId: string };
    const response = await handleRequest(
      verifyRequest(created.sessionId, 'http://localhost:8788'),
      mockEnv(scenario),
      { paymentRateLimiter: acceptingRateLimiter },
    );
    const body = (await response.json()) as Record<string, unknown>;

    expect(response.status).toBe(200);
    expect(body).toMatchObject({ status });
    expect(JSON.stringify(body)).not.toContain(email);
    expect(JSON.stringify(body)).not.toContain('latest_charge');
    expect(JSON.stringify(body)).not.toContain('payment_intent');
  });

  it('returns a purchase reference only for a verified paid session', async () => {
    const createResponse = await handleRequest(
      createRequest('http://localhost:8788'),
      mockEnv('paid'),
      { paymentRateLimiter: acceptingRateLimiter },
    );
    const created = (await createResponse.json()) as { sessionId: string };
    const response = await handleRequest(
      verifyRequest(created.sessionId, 'http://localhost:8788'),
      mockEnv('paid'),
      { paymentRateLimiter: acceptingRateLimiter },
    );
    const body = (await response.json()) as Record<string, unknown>;

    expect(body.status).toBe('confirmed');
    expect(body.purchaseReference).toMatch(/^FF-[A-F0-9]{16}$/);
    expect(Object.keys(body).sort()).toEqual(
      ['purchaseReference', 'requestId', 'status'].sort(),
    );
  });

  it.each([
    ['environment', { livemode: true }],
    ['mode', { mode: 'subscription' }],
    ['Customer creation', { customer_creation: 'if_required' }],
    ['missing Customer', { customer: null }],
    ['malformed Customer', { customer: 'not_a_customer' }],
    ['currency', { currency: 'usd' }],
    ['total', { amount_total: 24_901 }],
    ['automatic tax', { automatic_tax: { enabled: true } }],
    [
      'stored automatic-tax configuration',
      {
        metadata: {
          purchase_reference: 'FF-1234567890ABCDEF',
          automatic_tax_enabled: 'true',
        },
      },
    ],
    [
      'purchase reference',
      {
        metadata: {
          purchase_reference: 'FF-0000000000000000',
          automatic_tax_enabled: 'false',
        },
      },
    ],
    ['payment status', { payment_status: 'no_payment_required' }],
    ['completion status', { status: 'open' }],
    [
      'Price',
      {
        line_items: {
          data: [
            {
              quantity: 1,
              price: { id: 'price_wrong', tax_behavior: 'inclusive' },
            },
          ],
        },
      },
    ],
    [
      'quantity',
      {
        line_items: {
          data: [
            {
              quantity: 2,
              price: {
                id: 'price_test249gbp',
                tax_behavior: 'inclusive',
              },
            },
          ],
        },
      },
    ],
    [
      'inclusive tax behavior',
      {
        line_items: {
          data: [
            {
              quantity: 1,
              price: {
                id: 'price_test249gbp',
                tax_behavior: 'exclusive',
              },
            },
          ],
        },
      },
    ],
  ])('does not confirm a Session with mismatched %s', async (_, override) => {
    const upstreamFetch = vi.fn(async () =>
      Response.json(validSession(override)),
    );
    const response = await handleRequest(
      verifyRequest(sessionId),
      productionEnv(),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );
    const body = (await response.json()) as Record<string, unknown>;

    expect(response.status).toBe(200);
    expect(body.status).toBe('invalid');
    expect(body.purchaseReference).toBeUndefined();
  });

  it('keeps a pre-completion Session pending without requiring a Customer yet', async () => {
    const upstreamFetch = vi.fn(async () =>
      Response.json(
        validSession({
          status: 'open',
          payment_status: 'unpaid',
          customer: null,
        }),
      ),
    );
    const response = await handleRequest(
      verifyRequest(sessionId),
      productionEnv(),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(response.status).toBe(200);
    expect(await response.json()).toMatchObject({ status: 'pending' });
  });

  it('rejects malformed and extra request fields', async () => {
    const response = await handleRequest(
      createRequest('https://payment.example', {
        email,
        attemptId,
        amount: 1,
      }),
      productionEnv(),
      { paymentRateLimiter: acceptingRateLimiter },
    );
    expect(response.status).toBe(400);
  });

  it('rejects oversized bodies before parsing', async () => {
    const response = await handleRequest(
      createRequest('https://payment.example', {
        email: `${'a'.repeat(5000)}@example.com`,
        attemptId,
      }),
      productionEnv(),
      { paymentRateLimiter: acceptingRateLimiter },
    );
    expect(response.status).toBe(400);
  });

  it('maps rate limiting to a provider-neutral response', async () => {
    const response = await handleRequest(createRequest(), productionEnv(), {
      paymentRateLimiter: {
        async limit() {
          return { success: false };
        },
      },
    });
    expect(response.status).toBe(429);
    expect(await response.json()).toMatchObject({
      error: { code: 'rate_limited' },
    });
  });

  it('rejects local mocks on a deployed hostname without I/O', async () => {
    const upstreamFetch = vi.fn();
    const response = await handleRequest(
      createRequest(),
      mockEnv('paid'),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );
    expect(response.status).toBe(500);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('classifies Stripe timeouts without exposing provider data', async () => {
    const upstreamFetch = vi.fn(
      async (_input: RequestInfo | URL, init?: RequestInit) =>
        new Promise<Response>((_resolve, reject) => {
          init?.signal?.addEventListener('abort', () => {
            reject(new DOMException('secret provider body', 'AbortError'));
          });
        }),
    );
    const response = await handleRequest(createRequest(), productionEnv(), {
      upstreamFetch,
      stripeTimeoutMs: 1,
      paymentRateLimiter: acceptingRateLimiter,
    });
    const body = JSON.stringify(await response.json());
    expect(response.status).toBe(503);
    expect(body).not.toContain('secret provider body');
    expect(body).not.toContain(email);
  });

  it('keeps the Stripe deadline active while reading the response body', async () => {
    const upstreamFetch = vi.fn(
      async (_input: RequestInfo | URL, init?: RequestInit) =>
        new Response(
          new ReadableStream({
            start(controller) {
              init?.signal?.addEventListener('abort', () => {
                controller.error(new DOMException('late body', 'AbortError'));
              });
            },
          }),
        ),
    );
    const response = await handleRequest(createRequest(), productionEnv(), {
      upstreamFetch,
      stripeTimeoutMs: 1,
      paymentRateLimiter: acceptingRateLimiter,
    });

    expect(response.status).toBe(503);
    expect(JSON.stringify(await response.json())).not.toContain('late body');
  });
});

function createRequest(
  origin = 'https://payment.example',
  body: Record<string, unknown> = { email, attemptId },
): Request {
  return new Request(`${origin}${createPath}`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      origin: 'http://localhost:7357',
    },
    body: JSON.stringify(body),
  });
}

function verifyRequest(
  id: string,
  origin = 'https://payment.example',
): Request {
  return new Request(`${origin}${verifyPath}`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      origin: 'http://localhost:7357',
    },
    body: JSON.stringify({ sessionId: id }),
  });
}

function productionEnv(override: Partial<Env> = {}): Env {
  return {
    PAYMENT_CREATION_ENABLED: 'true',
    STRIPE_SECRET_KEY: 'rk_test_REDACTEDSAFEVALUE',
    STRIPE_PRICE_ID: 'price_test249gbp',
    STRIPE_EXPECTED_LIVEMODE: 'false',
    STRIPE_AUTOMATIC_TAX_ENABLED: 'false',
    PUBLIC_APP_ORIGIN: 'https://funapp.world',
    PURCHASE_REFERENCE_SECRET: 'test-reference-secret-at-least-32-characters',
    ...override,
  };
}

function mockEnv(scenario: string): Env {
  return {
    PAYMENT_CREATION_ENABLED: 'true',
    STRIPE_AUTOMATIC_TAX_ENABLED: 'false',
    LOCAL_DEVELOPMENT_ALLOWED_ORIGIN: 'http://localhost:7357',
    PUBLIC_APP_ORIGIN: 'http://localhost:7357',
    PURCHASE_REFERENCE_SECRET: 'local-development-only-reference-secret',
    STRIPE_MOCK_SCENARIO: scenario,
  };
}

function validPrice(): Record<string, unknown> {
  return {
    id: 'price_test249gbp',
    object: 'price',
    active: true,
    currency: 'gbp',
    livemode: false,
    type: 'one_time',
    unit_amount: 24_900,
    billing_scheme: 'per_unit',
    custom_unit_amount: null,
    tax_behavior: 'inclusive',
  };
}

function validCreatedSession(
  reference: string | null,
  override: Record<string, unknown> = {},
): Record<string, unknown> {
  return {
    id: sessionId,
    object: 'checkout.session',
    url: 'https://checkout.stripe.com/c/pay/cs_test_safe',
    mode: 'payment',
    currency: 'gbp',
    amount_total: 24_900,
    livemode: false,
    customer_creation: 'always',
    automatic_tax: { enabled: false },
    client_reference_id: reference,
    metadata: {
      purchase_reference: reference,
      automatic_tax_enabled: 'false',
    },
    line_items: {
      data: [
        {
          quantity: 1,
          price: {
            id: 'price_test249gbp',
            tax_behavior: 'inclusive',
          },
        },
      ],
    },
    ...override,
  };
}

function validSession(
  override: Record<string, unknown> = {},
): Record<string, unknown> {
  return {
    id: sessionId,
    object: 'checkout.session',
    mode: 'payment',
    status: 'complete',
    payment_status: 'paid',
    currency: 'gbp',
    amount_total: 24_900,
    livemode: false,
    customer_creation: 'always',
    customer: 'cus_test12345678',
    automatic_tax: { enabled: false },
    client_reference_id: 'FF-1234567890ABCDEF',
    metadata: {
      purchase_reference: 'FF-1234567890ABCDEF',
      automatic_tax_enabled: 'false',
    },
    line_items: {
      data: [
        {
          quantity: 1,
          price: {
            id: 'price_test249gbp',
            tax_behavior: 'inclusive',
          },
        },
      ],
    },
    payment_intent: {
      latest_charge: {
        disputed: false,
        refunded: false,
        amount_refunded: 0,
      },
    },
    ...override,
  };
}
