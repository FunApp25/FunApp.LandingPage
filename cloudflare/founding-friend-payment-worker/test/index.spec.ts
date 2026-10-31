import { describe, expect, it, vi } from 'vitest';

import {
  type Env,
  type RateLimiter,
  type UpstreamFetch,
  handleRequest,
} from '../src/index';
import { handleStagingRequest } from '../src/staging';

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
          payment_intent: {
            ...(validSession().payment_intent as Record<string, unknown>),
            metadata: {
              purchase_reference: 'FF-1234567890ABCDEF',
              automatic_tax_enabled: 'true',
            },
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

  it.each(['open', 'complete'])('preserves the old %s/unpaid verification response for older clients', async (status) => {
    const request = verifyRequest(sessionId);
    request.headers.delete('accept');
    const response = await handleRequest(request, productionEnv(), {
      upstreamFetch: async () => Response.json(validSession({
        status, payment_status: 'unpaid', customer: null, payment_intent: null,
      })),
      paymentRateLimiter: acceptingRateLimiter,
    });
    const body = await response.json() as Record<string, unknown>;
    expect(response.status).toBe(200);
    expect(body.status).toBe('pending');
    expect(Object.keys(body).sort()).toEqual(['requestId', 'status']);
  });

  it('does not authorize an expiry retry for a contradictory paid Session', async () => {
    const response = await handleRequest(
      verifyRequest(sessionId),
      productionEnv(),
      {
        upstreamFetch: async () => Response.json(validSession({ status: 'expired' })),
        paymentRateLimiter: acceptingRateLimiter,
      },
    );
    expect(response.status).toBe(200);
    expect(await response.json()).toMatchObject({ status: 'invalid' });
  });

  it('keeps a pre-completion Session pending without requiring a Customer yet', async () => {
    const upstreamFetch = vi.fn(async () =>
      Response.json(
        validSession({
          status: 'open',
          payment_status: 'unpaid',
          customer: null,
          payment_intent: null,
        }),
      ),
    );
    const response = await handleRequest(
      verifyRequest(sessionId),
      productionEnv(),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );

    expect(response.status).toBe(200);
    expect(await response.json()).toMatchObject({ status: 'pending', canResumeCheckout: true });
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
      accept: 'application/json; checkout-recovery=1',
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
  const reference = 'FF-1234567890ABCDEF';
  return {
    ...validCreatedSession(reference),
    status: 'complete',
    payment_status: 'paid',
    customer: 'cus_test12345678',
    amount_subtotal: 24_900,
    total_details: { amount_discount: 0, amount_shipping: 0, amount_tax: 0 },
    line_items: {
      has_more: false,
      data: [{
        quantity: 1,
        currency: 'gbp',
        amount_total: 24_900,
        amount_subtotal: 24_900,
        amount_discount: 0,
        amount_tax: 0,
        price: validPrice(),
      }],
    },
    payment_intent: {
      id: 'pi_test12345678',
      object: 'payment_intent',
      currency: 'gbp',
      amount: 24_900,
      amount_received: 24_900,
      status: 'succeeded',
      livemode: false,
      customer: 'cus_test12345678',
      metadata: { purchase_reference: reference, automatic_tax_enabled: 'false' },
      latest_charge: {
        id: 'ch_test12345678',
        object: 'charge',
        payment_intent: 'pi_test12345678',
        customer: 'cus_test12345678',
        currency: 'gbp',
        amount: 24_900,
        amount_captured: 24_900,
        paid: true,
        captured: true,
        status: 'succeeded',
        livemode: false,
        disputed: false,
        refunded: false,
        amount_refunded: 0,
      },
    },
    ...override,
  };
}

// Synthetic values model the read-only sandbox shape; no customer or transaction data.
function localizedSession(currency = 'eur', amount = 29_900, presentment = false) {
  const session = validSession();
  const items = session.line_items as { data: Record<string, unknown>[] };
  const intent = session.payment_intent as Record<string, unknown>;
  const charge = intent.latest_charge as Record<string, unknown>;
  session.adaptive_pricing = { enabled: true };
  if (presentment) {
    for (const object of [session, intent, charge]) {
      object.presentment_details = {
        presentment_currency: currency,
        presentment_amount: amount,
      };
    }
  } else {
    Object.assign(session, { currency, amount_total: amount, amount_subtotal: amount });
    Object.assign(items.data[0]!, { currency, amount_total: amount, amount_subtotal: amount });
    Object.assign(intent, { currency, amount, amount_received: amount });
    Object.assign(charge, { currency, amount, amount_captured: amount });
  }
  return session;
}

function changeField(session: Record<string, unknown>, path: string, value: unknown) {
  const parts = path.split('.');
  let object = session;
  for (const part of parts.slice(0, -1)) {
    object = object[part] as Record<string, unknown>;
  }
  object[parts.at(-1)!] = value;
}

describe.each(['production', 'staging'])('%s Adaptive Pricing verification', (entrypoint) => {
  async function verify(session: Record<string, unknown>) {
    const upstreamFetch = vi.fn<UpstreamFetch>(async () => Response.json(session));
    const handler = entrypoint === 'staging' ? handleStagingRequest : handleRequest;
    const origin = entrypoint === 'staging'
      ? 'https://staging.funapp.world'
      : 'https://funapp.world';
    const response = await handler(
      verifyRequest(sessionId, origin),
      productionEnv({ PUBLIC_APP_ORIGIN: origin, PAYMENT_CREATION_ENABLED: 'false' }),
      { upstreamFetch, paymentRateLimiter: acceptingRateLimiter },
    );
    expect(response.status).toBe(200);
    expect(upstreamFetch).toHaveBeenCalledTimes(1);
    const [url, init] = upstreamFetch.mock.calls[0]!;
    expect(url).toContain(`/v1/checkout/sessions/${sessionId}`);
    expect(url).toContain('expand[]=line_items.data.price');
    expect(url).toContain('expand[]=payment_intent.latest_charge');
    expect(init?.method).toBe('GET');
    expect(new Headers(init?.headers).get('stripe-version')).toBe('2026-08-26.dahlia');
    const body = await response.json() as Record<string, unknown>;
    expect(Object.keys(body).sort()).toEqual(
      body.status === 'confirmed'
        ? ['purchaseReference', 'requestId', 'status']
        : body.status === 'pending'
          ? ['canResumeCheckout', 'requestId', 'status']
          : ['requestId', 'status'],
    );
    return body;
  }

  it('keeps the original GBP payment valid', async () => {
    expect(await verify(validSession())).toMatchObject({ status: 'confirmed' });
  });

  it.each([
    ['eur', 29_900],
    ['jpy', 48_731],
  ])('confirms Stripe-reconciled %s totals without calculating FX', async (currency, amount) => {
    expect(await verify(localizedSession(currency as string, amount as number)))
      .toMatchObject({ status: 'confirmed', purchaseReference: 'FF-1234567890ABCDEF' });
    expect(await verify(localizedSession(currency as string, amount as number, true)))
      .toMatchObject({ status: 'confirmed' });
  });

  it('rejects an unsupported currency even when all monetary fields agree', async () => {
    expect(await verify(localizedSession('zzz', 123))).toMatchObject({ status: 'invalid' });
  });

  it('accepts reconciled inclusive tax in localized totals', async () => {
    const session = localizedSession();
    changeField(session, 'automatic_tax.enabled', true);
    changeField(session, 'metadata.automatic_tax_enabled', 'true');
    changeField(session, 'payment_intent.metadata.automatic_tax_enabled', 'true');
    changeField(session, 'line_items.data.0.amount_tax', 4_000);
    changeField(session, 'total_details.amount_tax', 4_000);
    expect(await verify(session)).toMatchObject({ status: 'confirmed' });
  });

  it('does not treat an unpaid Session with a successful PaymentIntent as pending', async () => {
    const session = localizedSession();
    session.payment_status = 'unpaid';
    expect(await verify(session)).toMatchObject({ status: 'invalid' });
  });

  it('preserves pending payment processing with a matching expanded intent', async () => {
    const session = localizedSession();
    session.payment_status = 'unpaid';
    changeField(session, 'payment_intent.status', 'processing');
    changeField(session, 'payment_intent.amount_received', 0);
    changeField(session, 'payment_intent.latest_charge', null);
    expect(await verify(session)).toMatchObject({ status: 'pending', canResumeCheckout: false });
    const failedCharge = {
      id: 'ch_testfailed123', object: 'charge', payment_intent: 'pi_test12345678',
      customer: 'cus_test12345678', currency: 'eur', amount: 29_900,
      livemode: false, paid: false, captured: false, amount_captured: 0,
      refunded: false, disputed: false, amount_refunded: 0, status: 'failed',
    };
    changeField(session, 'payment_intent.latest_charge', failedCharge);
    expect(await verify(session)).toMatchObject({ status: 'pending', canResumeCheckout: false });
    changeField(session, 'payment_intent.latest_charge.currency', 'gbp');
    expect(await verify(session)).toMatchObject({ status: 'invalid' });
    changeField(session, 'payment_intent.latest_charge', null);
    changeField(session, 'payment_intent.amount', 1);
    expect(await verify(session)).toMatchObject({ status: 'invalid' });
  });

  it('accepts consistent optional presentment details on a localized Session', async () => {
    const session = localizedSession();
    session.presentment_details = { presentment_currency: 'eur', presentment_amount: 29_900 };
    expect(await verify(session)).toMatchObject({ status: 'confirmed' });
  });

  it('accepts presentment details supplied only on the PaymentIntent', async () => {
    const session = localizedSession('jpy', 48_731, true);
    session.presentment_details = null;
    changeField(session, 'payment_intent.latest_charge.presentment_details', null);
    expect(await verify(session)).toMatchObject({ status: 'confirmed' });
  });

  it.each([
    ['currency', 'usd'],
    ['currency', 'EUR'],
    ['currency', 'zzz'],
    ['amount_total', 0],
    ['amount_total', -1],
    ['amount_total', 29_900.5],
    ['amount_total', Number.MAX_SAFE_INTEGER + 1],
    ['amount_subtotal', 29_901],
    ['adaptive_pricing', null],
    ['adaptive_pricing.enabled', false],
    ['currency_conversion', { source_currency: 'gbp', amount_total: 24_900 }],
    ['livemode', true],
    ['id', 'cs_test_other1234567890123456'],
    ['mode', 'subscription'],
    ['metadata.purchase_reference', 'FF-0000000000000000'],
    ['client_reference_id', 'FF-0000000000000000'],
    ['metadata.automatic_tax_enabled', 'true'],
    ['automatic_tax.enabled', true],
    ['line_items', null],
    ['line_items.has_more', true],
    ['line_items.data', []],
    ['line_items.data', [null]],
    ['line_items.data.0.price', 'price_test249gbp'],
    ['line_items.data.0.price.id', 'price_wrong'],
    ['line_items.data.0.price.currency', 'eur'],
    ['line_items.data.0.price.unit_amount', 24_901],
    ['line_items.data.0.price.tax_behavior', 'exclusive'],
    ['line_items.data.0.price.livemode', true],
    ['line_items.data.0.price.type', 'recurring'],
    ['line_items.data.0.quantity', 2],
    ['line_items.data.0.currency', 'gbp'],
    ['line_items.data.0.amount_total', 29_901],
    ['line_items.data.0.amount_subtotal', 29_901],
    ['line_items.data.0.amount_discount', 1],
    ['line_items.data.0.amount_tax', 1],
    ['total_details.amount_discount', 1],
    ['total_details.amount_shipping', 1],
    ['presentment_details', {}],
    ['presentment_details', { presentment_currency: 'eur', presentment_amount: 29_901 }],
    ['presentment_details', { presentment_currency: 'usd', presentment_amount: 29_900 }],
    ['payment_intent', null],
    ['payment_intent', 'pi_unexpanded'],
    ['payment_intent.currency', 'gbp'],
    ['payment_intent.amount', 29_901],
    ['payment_intent.amount_received', 29_899],
    ['payment_intent.status', 'processing'],
    ['payment_intent.livemode', true],
    ['payment_intent.metadata.purchase_reference', 'FF-0000000000000000'],
    ['payment_intent.metadata.automatic_tax_enabled', 'true'],
    ['payment_intent.customer', 'cus_different1234'],
    ['payment_intent.latest_charge', null],
    ['payment_intent.latest_charge', 'ch_unexpanded'],
    ['payment_intent.latest_charge.payment_intent', 'pi_other'],
    ['payment_intent.latest_charge.customer', 'cus_different1234'],
    ['payment_intent.latest_charge.currency', 'gbp'],
    ['payment_intent.latest_charge.amount', 29_899],
    ['payment_intent.latest_charge.amount_captured', 29_899],
    ['payment_intent.latest_charge.paid', false],
    ['payment_intent.latest_charge.captured', false],
    ['payment_intent.latest_charge.status', 'pending'],
    ['payment_intent.latest_charge.livemode', true],
    ['payment_intent.latest_charge.amount_refunded', -1],
    ['payment_intent.latest_charge.amount_refunded', 29_901],
    ['payment_intent.latest_charge.amount_refunded', 29_900],
    ['payment_intent.latest_charge.refunded', true],
    ['payment_intent.latest_charge.disputed', undefined],
    ['payment_status', 'no_payment_required'],
  ])('rejects contradictory or missing %s (%j)', async (path, value) => {
    const session = localizedSession();
    changeField(session, path as string, value);
    expect(await verify(session)).toMatchObject({ status: 'invalid' });
  });

  it.each([
    ['presentment_details.presentment_amount', 0],
    ['payment_intent.presentment_details.presentment_amount', 29_901],
    ['payment_intent.latest_charge.presentment_details.presentment_currency', 'usd'],
    ['adaptive_pricing.enabled', false],
    ['amount_total', 24_901],
    ['line_items.data.0.amount_total', 29_900],
    ['payment_intent.currency', 'eur'],
    ['payment_intent.latest_charge.amount', 29_900],
  ])('rejects contradictory documented presentment %s', async (path, value) => {
    const session = localizedSession('eur', 29_900, true);
    changeField(session, path as string, value);
    expect(await verify(session)).toMatchObject({ status: 'invalid' });
  });

  it.each(['pending', 'expired', 'refunded', 'disputed', 'partial refund'])('preserves localized %s', async (state) => {
    const session = localizedSession();
    if (state === 'pending' || state === 'expired') {
      Object.assign(session, {
        status: state === 'expired' ? 'expired' : 'complete',
        payment_status: 'unpaid',
        payment_intent: null,
        customer: null,
      });
    } else if (state === 'disputed') {
      changeField(session, 'payment_intent.latest_charge.disputed', true);
    } else {
      changeField(session, 'payment_intent.latest_charge.refunded', state === 'refunded');
      changeField(session, 'payment_intent.latest_charge.amount_refunded', state === 'refunded' ? 29_900 : 1);
    }
    expect(await verify(session)).toMatchObject({ status: state === 'partial refund' ? 'refunded' : state });
  });
});

describe('Adaptive Pricing creation contract', () => {
  it.each([false, true])('preserves GBP creation checks with presentment=%s', async (presentment) => {
    const upstreamFetch = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      expect(new Headers(init?.headers).get('stripe-version')).toBe('2026-08-26.dahlia');
      if (input.toString().includes('/v1/prices/')) {
        expect(init?.method).toBe('GET');
        return Response.json(validPrice());
      }
      expect(init?.method).toBe('POST');
      const body = new URLSearchParams(init?.body as string);
      expect(body.has('adaptive_pricing[enabled]')).toBe(false);
      expect(body.has('currency')).toBe(false);
      return Response.json(validCreatedSession(body.get('client_reference_id'), {
        adaptive_pricing: { enabled: true },
        ...(presentment ? { presentment_details: { presentment_currency: 'eur', presentment_amount: 29_900 } } : {}),
      }));
    });
    const response = await handleRequest(createRequest(), productionEnv(), {
      upstreamFetch, paymentRateLimiter: acceptingRateLimiter,
    });
    expect(response.status).toBe(201);
    expect(upstreamFetch).toHaveBeenCalledTimes(2);
  });

  it('still rejects a localized creation response', async () => {
    const upstreamFetch = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      if (input.toString().includes('/v1/prices/')) return Response.json(validPrice());
      const body = new URLSearchParams(init?.body as string);
      return Response.json(validCreatedSession(body.get('client_reference_id'), {
        currency: 'eur', amount_total: 29_900, adaptive_pricing: { enabled: true },
      }));
    });
    const response = await handleRequest(createRequest(), productionEnv(), {
      upstreamFetch, paymentRateLimiter: acceptingRateLimiter,
    });
    expect(response.status).toBe(502);
  });
});
