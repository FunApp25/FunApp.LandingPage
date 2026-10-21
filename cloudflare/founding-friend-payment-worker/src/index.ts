export interface RateLimiter {
  limit(options: { key: string }): Promise<{ success: boolean }>;
}

export interface Env {
  PAYMENT_CREATION_ENABLED?: string;
  PAYMENT_RATE_LIMITER?: RateLimiter;
  STRIPE_SECRET_KEY?: string;
  STRIPE_PRICE_ID?: string;
  STRIPE_EXPECTED_LIVEMODE?: string;
  STRIPE_AUTOMATIC_TAX_ENABLED?: string;
  PUBLIC_APP_ORIGIN?: string;
  PURCHASE_REFERENCE_SECRET?: string;
  LOCAL_DEVELOPMENT_ALLOWED_ORIGIN?: string;
  STRIPE_MOCK_SCENARIO?: string;
}

export type UpstreamFetch = (
  input: RequestInfo | URL,
  init?: RequestInit,
) => Promise<Response>;

export interface WorkerDependencies {
  upstreamFetch?: UpstreamFetch;
  stripeTimeoutMs?: number;
  paymentRateLimiter?: RateLimiter;
}

type MockScenario =
  | 'created'
  | 'paid'
  | 'pending'
  | 'cancelled'
  | 'expired'
  | 'provider_validation_failure'
  | 'payment_mismatch'
  | 'network_failure'
  | 'provider_unavailable'
  | 'timeout'
  | 'duplicate_attempt'
  | 'refunded'
  | 'disputed';

type Endpoint = 'create' | 'verify';
type PaymentStatus =
  | 'confirmed'
  | 'pending'
  | 'expired'
  | 'refunded'
  | 'disputed'
  | 'invalid';

interface CreateCheckoutRequest {
  email: string;
  attemptId: string;
}

interface VerifyCheckoutRequest {
  sessionId: string;
}

interface StripePrice {
  id?: unknown;
  object?: unknown;
  active?: unknown;
  currency?: unknown;
  livemode?: unknown;
  type?: unknown;
  unit_amount?: unknown;
  billing_scheme?: unknown;
  custom_unit_amount?: unknown;
  tax_behavior?: unknown;
}

interface StripeCheckoutSession {
  id?: unknown;
  object?: unknown;
  url?: unknown;
  mode?: unknown;
  status?: unknown;
  payment_status?: unknown;
  currency?: unknown;
  amount_total?: unknown;
  livemode?: unknown;
  customer_creation?: unknown;
  customer?: unknown;
  automatic_tax?: unknown;
  client_reference_id?: unknown;
  metadata?: unknown;
  line_items?: unknown;
  payment_intent?: unknown;
}

const createEndpointPath =
  '/api/founding-friend-payments/checkout-sessions';
const verifyEndpointPath =
  '/api/founding-friend-payments/checkout-sessions/verify';
const expectedCurrency = 'gbp';
const expectedAmount = 24_900;
const maxRequestBodyBytes = 4 * 1024;
const stripeTimeoutMs = 10_000;
const stripeApiOrigin = 'https://api.stripe.com';
const stripeApiVersion = '2026-08-26.dahlia';
const createFields = new Set(['email', 'attemptId']);
const verifyFields = new Set(['sessionId']);
const emailPattern = /^(?!.*\.\.)(?!\.)[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]{1,64}(?<!\.)@(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$/;
const attemptIdPattern =
  /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const stripeSessionIdPattern = /^cs_(?:test|live)_[A-Za-z0-9]{16,240}$/;
const mockSessionIdPattern = /^cs_mock_[a-z_]+_[0-9a-f]{32}$/;
const purchaseReferencePattern = /^FF-[A-F0-9]{16}$/;
const stripeCustomerIdPattern = /^cus_[A-Za-z0-9]{8,240}$/;
const mockScenarios = new Set<MockScenario>([
  'created',
  'paid',
  'pending',
  'cancelled',
  'expired',
  'provider_validation_failure',
  'payment_mismatch',
  'network_failure',
  'provider_unavailable',
  'timeout',
  'duplicate_attempt',
  'refunded',
  'disputed',
]);

class InvalidRequestError extends Error {}
class RequestBodyTooLargeError extends Error {}
class StripeConfigurationError extends Error {}
class StripeProviderError extends Error {
  constructor(readonly kind: 'unavailable' | 'invalid') {
    super(kind);
  }
}

/** Handles payment creation and read-only Checkout verification. */
export async function handleRequest(
  request: Request,
  env: Env,
  dependencies: WorkerDependencies = {},
): Promise<Response> {
  const requestId = crypto.randomUUID();
  const url = new URL(request.url);
  const endpoint = endpointForPath(url.pathname);
  const corsHeaders = localDevelopmentCorsHeaders(request, env, url);

  if (endpoint === null) {
    return errorResponse(404, 'not_found', requestId);
  } else if (request.method === 'OPTIONS' && corsHeaders !== null) {
    return new Response(null, { status: 204, headers: corsHeaders });
  } else if (request.method !== 'POST') {
    return errorResponse(
      405,
      'method_not_allowed',
      requestId,
      { Allow: 'POST' },
      corsHeaders,
    );
  }

  const mockConfiguration = mockConfigurationFor(env, url);
  if (mockConfiguration === 'invalid') {
    return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
  }

  if (endpoint === 'create') {
    const availability = creationAvailability(env.PAYMENT_CREATION_ENABLED);
    if (availability === 'disabled') {
      return errorResponse(
        503,
        'service_unavailable',
        requestId,
        {},
        corsHeaders,
      );
    } else if (availability === 'invalid') {
      return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
    }
  }

  const rateLimiter =
    dependencies.paymentRateLimiter ?? env.PAYMENT_RATE_LIMITER;
  if (rateLimiter === undefined) {
    return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
  }

  try {
    const result = await rateLimiter.limit({
      key: rateLimitKey(request, url.pathname),
    });
    if (!result.success) {
      return errorResponse(429, 'rate_limited', requestId, {}, corsHeaders);
    }
  } catch {
    return errorResponse(
      503,
      'service_unavailable',
      requestId,
      {},
      corsHeaders,
    );
  }

  if (!isJsonContentType(request.headers.get('content-type'))) {
    return errorResponse(400, 'invalid_request', requestId, {}, corsHeaders);
  }

  try {
    const body = await readLimitedBody(request);
    if (endpoint === 'create') {
      const input = parseCreateRequest(body);
      return await createCheckoutSession(
        input,
        env,
        dependencies,
        mockConfiguration,
        requestId,
        corsHeaders,
      );
    } else {
      const input = parseVerifyRequest(body, mockConfiguration === 'valid');
      return await verifyCheckoutSession(
        input,
        env,
        dependencies,
        mockConfiguration,
        requestId,
        corsHeaders,
      );
    }
  } catch (error) {
    if (
      error instanceof InvalidRequestError ||
      error instanceof RequestBodyTooLargeError
    ) {
      return errorResponse(400, 'invalid_request', requestId, {}, corsHeaders);
    } else if (error instanceof StripeConfigurationError) {
      return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
    } else if (error instanceof StripeProviderError) {
      const status = error.kind === 'unavailable' ? 503 : 502;
      const code =
        error.kind === 'unavailable'
          ? 'service_unavailable'
          : 'provider_validation_failed';
      return errorResponse(status, code, requestId, {}, corsHeaders);
    } else {
      return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
    }
  }
}

export const worker = {
  fetch(request: Request, env: Env): Promise<Response> {
    return handleRequest(request, env);
  },
};

export default worker;

async function createCheckoutSession(
  input: CreateCheckoutRequest,
  env: Env,
  dependencies: WorkerDependencies,
  mockConfiguration: 'valid' | 'absent',
  requestId: string,
  corsHeaders: Headers | null,
): Promise<Response> {
  const appOrigin = validatedAppOrigin(env, mockConfiguration === 'valid');
  const automaticTaxEnabled = requiredAutomaticTaxEnabled(
    env.STRIPE_AUTOMATIC_TAX_ENABLED,
  );
  const purchaseReference = await createPurchaseReference(
    input.attemptId,
    requiredSecret(env.PURCHASE_REFERENCE_SECRET),
  );
  const integrationSuffix = integrationIdentifierSuffix(purchaseReference);

  if (mockConfiguration === 'valid') {
    const scenario = env.STRIPE_MOCK_SCENARIO as MockScenario;
    if (scenario === 'provider_validation_failure') {
      throw new StripeProviderError('invalid');
    } else if (
      scenario === 'network_failure' ||
      scenario === 'provider_unavailable' ||
      scenario === 'timeout'
    ) {
      throw new StripeProviderError('unavailable');
    }

    const sessionId = mockSessionId(scenario, input.attemptId);
    const checkoutUrl = mockCheckoutUrl(
      appOrigin,
      scenario,
      sessionId,
    );
    return jsonResponse(
      201,
      { checkoutUrl, sessionId },
      requestId,
      corsHeaders,
    );
  }

  const config = productionStripeConfig(env, appOrigin);
  const price = await stripeJson<StripePrice>(
    `/v1/prices/${encodeURIComponent(config.priceId)}`,
    { method: 'GET' },
    config.secretKey,
    dependencies,
  );
  assertValidPrice(price, config);

  const successUrl =
    `${appOrigin.origin}/#/founding-friend/payment` +
    '?session_id={CHECKOUT_SESSION_ID}';
  const cancelUrl =
    `${appOrigin.origin}/#/founding-friend/payment/cancelled`;

  const parameters = new URLSearchParams({
    mode: 'payment',
    success_url: successUrl,
    cancel_url: cancelUrl,
    customer_email: input.email,
    customer_creation: 'always',
    'automatic_tax[enabled]': String(automaticTaxEnabled),
    client_reference_id: purchaseReference,
    'metadata[purchase_reference]': purchaseReference,
    'metadata[automatic_tax_enabled]': String(automaticTaxEnabled),
    'payment_intent_data[metadata][purchase_reference]': purchaseReference,
    'payment_intent_data[metadata][automatic_tax_enabled]': String(
      automaticTaxEnabled,
    ),
    'line_items[0][price]': config.priceId,
    'line_items[0][quantity]': '1',
    'expand[]': 'line_items.data.price',
    integration_identifier: `funapp_founding_friend_${integrationSuffix}`,
  });
  const session = await stripeJson<StripeCheckoutSession>(
    '/v1/checkout/sessions',
    {
      method: 'POST',
      headers: {
        'content-type': 'application/x-www-form-urlencoded',
        'idempotency-key': `founding-friend-checkout-v1-${input.attemptId}`,
      },
      body: parameters.toString(),
    },
    config.secretKey,
    dependencies,
  );

  if (
    typeof session.id !== 'string' ||
    !stripeSessionIdPattern.test(session.id) ||
    session.object !== 'checkout.session' ||
    typeof session.url !== 'string' ||
    !isStripeHostedCheckoutUrl(session.url) ||
    session.mode !== 'payment' ||
    session.livemode !== config.expectedLivemode ||
    session.currency !== expectedCurrency ||
    session.amount_total !== expectedAmount ||
    session.customer_creation !== 'always' ||
    !hasExpectedAutomaticTax(
      session.automatic_tax,
      automaticTaxEnabled,
    ) ||
    !hasMatchingStoredAutomaticTax(session) ||
    validPurchaseReference(session) !== purchaseReference ||
    !hasExpectedSingleLineItem(session.line_items, config.priceId)
  ) {
    throw new StripeProviderError('invalid');
  }

  return jsonResponse(
    201,
    { checkoutUrl: session.url, sessionId: session.id },
    requestId,
    corsHeaders,
  );
}

async function verifyCheckoutSession(
  input: VerifyCheckoutRequest,
  env: Env,
  dependencies: WorkerDependencies,
  mockConfiguration: 'valid' | 'absent',
  requestId: string,
  corsHeaders: Headers | null,
): Promise<Response> {
  let session: StripeCheckoutSession;
  let expectedLivemode: boolean;
  let expectedPriceId: string;

  if (mockConfiguration === 'valid') {
    const expectedAutomaticTaxEnabled = requiredAutomaticTaxEnabled(
      env.STRIPE_AUTOMATIC_TAX_ENABLED,
    );
    const scenario = env.STRIPE_MOCK_SCENARIO as MockScenario;
    if (scenario === 'provider_validation_failure') {
      throw new StripeProviderError('invalid');
    } else if (
      scenario === 'network_failure' ||
      scenario === 'provider_unavailable' ||
      scenario === 'timeout'
    ) {
      throw new StripeProviderError('unavailable');
    }
    session = mockStripeSession(
      input.sessionId,
      scenario,
      expectedAutomaticTaxEnabled,
    );
    expectedLivemode = false;
    expectedPriceId = 'price_mock_founding_friend_249_gbp';
  } else {
    const appOrigin = validatedAppOrigin(env, false);
    const config = productionStripeConfig(env, appOrigin);
    expectedLivemode = config.expectedLivemode;
    expectedPriceId = config.priceId;
    session = await stripeJson<StripeCheckoutSession>(
      `/v1/checkout/sessions/${encodeURIComponent(input.sessionId)}` +
        '?expand[]=line_items.data.price&expand[]=payment_intent.latest_charge',
      { method: 'GET' },
      config.secretKey,
      dependencies,
    );
  }

  const result = classifySession(
    session,
    input.sessionId,
    expectedPriceId,
    expectedLivemode,
  );
  return jsonResponse(200, result, requestId, corsHeaders);
}

function classifySession(
  session: StripeCheckoutSession,
  requestedSessionId: string,
  expectedPriceId: string,
  expectedLivemode: boolean,
): { status: PaymentStatus; purchaseReference?: string } {
  const reference = validPurchaseReference(session);
  const validBase =
    session.object === 'checkout.session' &&
    session.id === requestedSessionId &&
    session.mode === 'payment' &&
    session.livemode === expectedLivemode &&
    session.customer_creation === 'always' &&
    hasMatchingStoredAutomaticTax(session) &&
    session.currency === expectedCurrency &&
    session.amount_total === expectedAmount &&
    reference !== null &&
    hasExpectedSingleLineItem(session.line_items, expectedPriceId);

  if (!validBase) {
    return { status: 'invalid' };
  }

  const charge = latestCharge(session.payment_intent);
  const hasPaidOutcome =
    session.payment_status === 'paid' ||
    charge?.disputed === true ||
    charge?.refunded === true ||
    (typeof charge?.amount_refunded === 'number' && charge.amount_refunded > 0);
  if (hasPaidOutcome && !hasValidCustomer(session.customer)) {
    return { status: 'invalid' };
  } else if (charge?.disputed === true) {
    return { status: 'disputed' };
  } else if (
    charge?.refunded === true ||
    (typeof charge?.amount_refunded === 'number' && charge.amount_refunded > 0)
  ) {
    return { status: 'refunded' };
  } else if (session.status === 'expired') {
    return { status: 'expired' };
  } else if (
    session.status === 'complete' &&
    session.payment_status === 'paid'
  ) {
    return { status: 'confirmed', purchaseReference: reference };
  } else if (
    (session.status === 'open' || session.status === 'complete') &&
    session.payment_status === 'unpaid'
  ) {
    return { status: 'pending' };
  } else {
    return { status: 'invalid' };
  }
}

function endpointForPath(pathname: string): Endpoint | null {
  if (pathname === createEndpointPath) {
    return 'create';
  } else if (pathname === verifyEndpointPath) {
    return 'verify';
  } else {
    return null;
  }
}

function creationAvailability(
  value: string | undefined,
): 'enabled' | 'disabled' | 'invalid' {
  if (value === undefined || value.trim() === '' || value === 'false') {
    return 'disabled';
  } else if (value === 'true') {
    return 'enabled';
  } else {
    return 'invalid';
  }
}

function requiredAutomaticTaxEnabled(value: string | undefined): boolean {
  if (value === 'true') {
    return true;
  } else if (value === 'false') {
    return false;
  } else {
    throw new StripeConfigurationError();
  }
}

function mockConfigurationFor(
  env: Env,
  workerUrl: URL,
): 'valid' | 'absent' | 'invalid' {
  const scenario = env.STRIPE_MOCK_SCENARIO;
  const localOrigin = env.LOCAL_DEVELOPMENT_ALLOWED_ORIGIN;
  const isLocalWorker = isLoopbackHostname(workerUrl.hostname);

  if (!isLocalWorker) {
    return scenario === undefined && localOrigin === undefined
      ? 'absent'
      : 'invalid';
  } else if (scenario === undefined && localOrigin === undefined) {
    return 'absent';
  } else if (
    scenario === undefined ||
    localOrigin === undefined ||
    !mockScenarios.has(scenario as MockScenario) ||
    !isValidOrigin(localOrigin, true)
  ) {
    return 'invalid';
  } else {
    return 'valid';
  }
}

function validatedAppOrigin(env: Env, requireLoopback: boolean): URL {
  const value = env.PUBLIC_APP_ORIGIN;
  if (value === undefined || !isValidOrigin(value, requireLoopback)) {
    throw new StripeConfigurationError();
  }
  return new URL(value);
}

function productionStripeConfig(
  env: Env,
  appOrigin: URL,
): {
  secretKey: string;
  priceId: string;
  expectedLivemode: boolean;
  appOrigin: URL;
} {
  const secretKey = env.STRIPE_SECRET_KEY;
  const priceId = env.STRIPE_PRICE_ID;
  const mode = env.STRIPE_EXPECTED_LIVEMODE;
  const expectedLivemode = mode === 'true';

  if (
    (mode !== 'true' && mode !== 'false') ||
    typeof secretKey !== 'string' ||
    !/^[rs]k_(?:test|live)_[A-Za-z0-9]+$/.test(secretKey) ||
    typeof priceId !== 'string' ||
    !/^price_[A-Za-z0-9]+$/.test(priceId) ||
    secretKey.includes('_live_') !== expectedLivemode
  ) {
    throw new StripeConfigurationError();
  }

  return {
    secretKey,
    priceId,
    expectedLivemode,
    appOrigin,
  };
}

function assertValidPrice(
  price: StripePrice,
  config: { priceId: string; expectedLivemode: boolean },
): void {
  if (
    price.object !== 'price' ||
    price.id !== config.priceId ||
    price.active !== true ||
    price.currency !== expectedCurrency ||
    price.livemode !== config.expectedLivemode ||
    price.type !== 'one_time' ||
    price.unit_amount !== expectedAmount ||
    price.billing_scheme !== 'per_unit' ||
    price.tax_behavior !== 'inclusive' ||
    (price.custom_unit_amount !== null &&
      price.custom_unit_amount !== undefined)
  ) {
    throw new StripeProviderError('invalid');
  }
}

async function stripeJson<T>(
  path: string,
  init: RequestInit,
  secretKey: string,
  dependencies: WorkerDependencies,
): Promise<T> {
  const controller = new AbortController();
  const timeout = setTimeout(
    () => controller.abort(),
    dependencies.stripeTimeoutMs ?? stripeTimeoutMs,
  );
  const headers = new Headers(init.headers);
  headers.set('authorization', `Bearer ${secretKey}`);
  headers.set('stripe-version', stripeApiVersion);
  const upstreamFetch = dependencies.upstreamFetch ?? fetch;
  let response: Response;

  try {
    try {
      response = await upstreamFetch(`${stripeApiOrigin}${path}`, {
        ...init,
        headers,
        signal: controller.signal,
      });
    } catch {
      throw new StripeProviderError('unavailable');
    }

    if (response.status === 429 || response.status >= 500) {
      throw new StripeProviderError('unavailable');
    } else if (!response.ok) {
      throw new StripeProviderError('invalid');
    }

    try {
      return (await response.json()) as T;
    } catch {
      if (controller.signal.aborted) {
        throw new StripeProviderError('unavailable');
      } else {
        throw new StripeProviderError('invalid');
      }
    }
  } finally {
    clearTimeout(timeout);
  }
}

function parseCreateRequest(body: string): CreateCheckoutRequest {
  const parsed = parseJsonObject(body, createFields);
  const email = requiredSingleLineText(parsed, 'email', 254);
  const attemptId = requiredSingleLineText(parsed, 'attemptId', 36);
  if (!emailPattern.test(email) || !attemptIdPattern.test(attemptId)) {
    throw new InvalidRequestError();
  }
  return { email, attemptId };
}

function parseVerifyRequest(
  body: string,
  allowMockId: boolean,
): VerifyCheckoutRequest {
  const parsed = parseJsonObject(body, verifyFields);
  const sessionId = requiredSingleLineText(parsed, 'sessionId', 255);
  if (
    !stripeSessionIdPattern.test(sessionId) &&
    !(allowMockId && mockSessionIdPattern.test(sessionId))
  ) {
    throw new InvalidRequestError();
  }
  return { sessionId };
}

function parseJsonObject(
  body: string,
  allowedFields: ReadonlySet<string>,
): Record<string, unknown> {
  let parsed: unknown;
  try {
    parsed = JSON.parse(body);
  } catch {
    throw new InvalidRequestError();
  }
  if (typeof parsed !== 'object' || parsed === null || Array.isArray(parsed)) {
    throw new InvalidRequestError();
  }
  for (const key of Object.keys(parsed)) {
    if (!allowedFields.has(key)) {
      throw new InvalidRequestError();
    }
  }
  return parsed as Record<string, unknown>;
}

function requiredSingleLineText(
  body: Record<string, unknown>,
  field: string,
  maximumLength: number,
): string {
  const value = body[field];
  if (
    typeof value !== 'string' ||
    value.trim().length === 0 ||
    value.length > maximumLength ||
    /[\r\n]/.test(value)
  ) {
    throw new InvalidRequestError();
  }
  return value;
}

async function readLimitedBody(request: Request): Promise<string> {
  const declared = request.headers.get('content-length');
  if (declared !== null) {
    const bytes = Number(declared);
    if (Number.isFinite(bytes) && bytes > maxRequestBodyBytes) {
      throw new RequestBodyTooLargeError();
    }
  }
  if (request.body === null) {
    return '';
  }

  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let total = 0;
  try {
    let chunk = await reader.read();
    while (!chunk.done) {
      total += chunk.value.byteLength;
      if (total > maxRequestBodyBytes) {
        await reader.cancel();
        throw new RequestBodyTooLargeError();
      }
      chunks.push(chunk.value);
      chunk = await reader.read();
    }
  } finally {
    reader.releaseLock();
  }

  const bytes = new Uint8Array(total);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.byteLength;
  }
  try {
    return new TextDecoder('utf-8', { fatal: true }).decode(bytes);
  } catch {
    throw new InvalidRequestError();
  }
}

async function createPurchaseReference(
  attemptId: string,
  secret: string,
): Promise<string> {
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign(
    'HMAC',
    key,
    new TextEncoder().encode(`founding-friend-v1:${attemptId}`),
  );
  const hex = [...new Uint8Array(signature)]
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('')
    .slice(0, 16)
    .toUpperCase();
  return `FF-${hex}`;
}

function requiredSecret(value: string | undefined): string {
  if (typeof value !== 'string' || value.length < 32 || /[\r\n]/.test(value)) {
    throw new StripeConfigurationError();
  }
  return value;
}

function validPurchaseReference(session: StripeCheckoutSession): string | null {
  const metadata = session.metadata;
  const metadataReference =
    typeof metadata === 'object' && metadata !== null
      ? (metadata as Record<string, unknown>).purchase_reference
      : null;
  if (
    typeof session.client_reference_id === 'string' &&
    purchaseReferencePattern.test(session.client_reference_id) &&
    metadataReference === session.client_reference_id
  ) {
    return session.client_reference_id;
  }
  return null;
}

function integrationIdentifierSuffix(purchaseReference: string): string {
  const referenceBytes = purchaseReference.slice(3).match(/.{2}/g) ?? [];
  return referenceBytes
    .map((value) => String.fromCharCode(97 + (Number.parseInt(value, 16) % 26)))
    .join('');
}

function hasExpectedSingleLineItem(
  lineItems: unknown,
  expectedPriceId: string,
): boolean {
  if (typeof lineItems !== 'object' || lineItems === null) {
    return false;
  }
  const container = lineItems as Record<string, unknown>;
  if (!Array.isArray(container.data) || container.data.length !== 1) {
    return false;
  }
  const item = container.data[0] as Record<string, unknown>;
  const price = item.price as Record<string, unknown> | undefined;
  return (
    item.quantity === 1 &&
    price?.id === expectedPriceId &&
    price.tax_behavior === 'inclusive'
  );
}

function hasExpectedAutomaticTax(
  automaticTax: unknown,
  expectedEnabled: boolean,
): boolean {
  if (typeof automaticTax !== 'object' || automaticTax === null) {
    return false;
  }
  return (automaticTax as Record<string, unknown>).enabled === expectedEnabled;
}

function hasMatchingStoredAutomaticTax(
  session: StripeCheckoutSession,
): boolean {
  const metadata = session.metadata;
  const storedValue =
    typeof metadata === 'object' && metadata !== null
      ? (metadata as Record<string, unknown>).automatic_tax_enabled
      : null;
  if (storedValue !== 'true' && storedValue !== 'false') {
    return false;
  }
  return hasExpectedAutomaticTax(
    session.automatic_tax,
    storedValue === 'true',
  );
}

function hasValidCustomer(customer: unknown): boolean {
  return typeof customer === 'string' && stripeCustomerIdPattern.test(customer);
}

function latestCharge(
  paymentIntent: unknown,
): { disputed?: unknown; refunded?: unknown; amount_refunded?: unknown } | null {
  if (typeof paymentIntent !== 'object' || paymentIntent === null) {
    return null;
  }
  const value = (paymentIntent as Record<string, unknown>).latest_charge;
  return typeof value === 'object' && value !== null
    ? (value as {
        disputed?: unknown;
        refunded?: unknown;
        amount_refunded?: unknown;
      })
    : null;
}

function mockStripeSession(
  sessionId: string,
  scenario: MockScenario,
  automaticTaxEnabled: boolean,
): StripeCheckoutSession {
  const reference = `FF-${sessionId.slice(-16).toUpperCase()}`;
  const valid = scenario !== 'payment_mismatch';
  const status = scenario === 'expired' ? 'expired' : 'complete';
  const paymentStatus = scenario === 'pending' ||
    scenario === 'created' ||
    scenario === 'cancelled'
    ? 'unpaid'
    : 'paid';
  const charge = {
    disputed: scenario === 'disputed',
    refunded: scenario === 'refunded',
    amount_refunded: scenario === 'refunded' ? expectedAmount : 0,
  };
  return {
    id: sessionId,
    object: 'checkout.session',
    mode: 'payment',
    status,
    payment_status: paymentStatus,
    currency: expectedCurrency,
    amount_total: valid ? expectedAmount : 1,
    livemode: false,
    customer_creation: 'always',
    customer: paymentStatus === 'paid' ? 'cus_mock12345678' : null,
    automatic_tax: { enabled: automaticTaxEnabled },
    client_reference_id: reference,
    metadata: {
      purchase_reference: reference,
      automatic_tax_enabled: String(automaticTaxEnabled),
    },
    line_items: {
      data: [
        {
          quantity: 1,
          price: {
            id: 'price_mock_founding_friend_249_gbp',
            tax_behavior: 'inclusive',
          },
        },
      ],
    },
    payment_intent: { latest_charge: charge },
  };
}

function mockSessionId(scenario: MockScenario, attemptId: string): string {
  const compactAttempt = attemptId.replaceAll('-', '').toLowerCase();
  return `cs_mock_${scenario}_${compactAttempt}`;
}

function mockCheckoutUrl(
  appOrigin: URL,
  scenario: MockScenario,
  sessionId: string,
): string {
  if (scenario === 'cancelled') {
    return `${appOrigin.origin}/#/founding-friend/payment/cancelled`;
  }
  return (
    `${appOrigin.origin}/#/founding-friend/payment` +
    `?session_id=${sessionId}`
  );
}

function isStripeHostedCheckoutUrl(value: string): boolean {
  try {
    const url = new URL(value);
    return (
      url.protocol === 'https:' &&
      url.hostname === 'checkout.stripe.com' &&
      url.username === '' &&
      url.password === ''
    );
  } catch {
    return false;
  }
}

function localDevelopmentCorsHeaders(
  request: Request,
  env: Env,
  workerUrl: URL,
): Headers | null {
  const configuredOrigin = env.LOCAL_DEVELOPMENT_ALLOWED_ORIGIN;
  const requestOrigin = request.headers.get('origin');
  if (
    configuredOrigin !== undefined &&
    requestOrigin === configuredOrigin &&
    mockConfigurationFor(env, workerUrl) === 'valid'
  ) {
    const headers = new Headers();
    headers.set('access-control-allow-origin', configuredOrigin);
    headers.set('access-control-allow-methods', 'POST, OPTIONS');
    headers.set('access-control-allow-headers', 'content-type');
    headers.set('vary', 'Origin');
    return headers;
  }
  return null;
}

function isValidOrigin(value: string, requireLoopback: boolean): boolean {
  try {
    const url = new URL(value);
    const validScheme = url.protocol === 'https:' ||
      (url.protocol === 'http:' && isLoopbackHostname(url.hostname));
    return (
      url.origin === value &&
      validScheme &&
      url.username === '' &&
      url.password === '' &&
      (!requireLoopback || isLoopbackHostname(url.hostname))
    );
  } catch {
    return false;
  }
}

function isLoopbackHostname(hostname: string): boolean {
  return (
    hostname === 'localhost' || hostname === '127.0.0.1' || hostname === '[::1]'
  );
}

function rateLimitKey(request: Request, pathname: string): string {
  const connectingIp = request.headers.get('cf-connecting-ip') ?? 'unknown';
  return `${pathname}:${connectingIp}`;
}

function isJsonContentType(value: string | null): boolean {
  return (
    value?.split(';', 1)[0]?.trim().toLowerCase() === 'application/json'
  );
}

function jsonResponse(
  status: number,
  body: Record<string, unknown>,
  requestId: string,
  corsHeaders: Headers | null,
): Response {
  const headers = new Headers(corsHeaders ?? undefined);
  headers.set('content-type', 'application/json; charset=utf-8');
  headers.set('cache-control', 'no-store');
  return Response.json({ ...body, requestId }, { status, headers });
}

function errorResponse(
  status: number,
  code: string,
  requestId: string,
  headers: HeadersInit = {},
  corsHeaders: Headers | null = null,
): Response {
  const responseHeaders = new Headers(headers);
  if (corsHeaders !== null) {
    corsHeaders.forEach((value, key) => responseHeaders.set(key, value));
  }
  responseHeaders.set('content-type', 'application/json; charset=utf-8');
  responseHeaders.set('cache-control', 'no-store');
  return Response.json(
    { error: { code, requestId } },
    { status, headers: responseHeaders },
  );
}
