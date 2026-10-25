import { hubSpotCountryValues } from './hubspot-country-values';

export interface RateLimiter {
  limit(options: { key: string }): Promise<{ success: boolean }>;
}

export interface Env {
  HUBSPOT_PORTAL_ID?: string;
  HUBSPOT_FORM_GUID?: string;
  HUBSPOT_VENUE_FORM_GUID?: string;
  HUBSPOT_HERE_AND_NOW_FORM_GUID?: string;
  HUBSPOT_FOUNDING_FRIEND_FORM_GUID?: string;
  REGISTRATION_SUBMISSIONS_ENABLED?: string;
  REGISTRATION_RATE_LIMITER?: RateLimiter;
  LOCAL_DEVELOPMENT_ALLOWED_ORIGIN?: string;
  HUBSPOT_MOCK_SCENARIO?: string;
}

export type UpstreamFetch = (
  input: RequestInfo | URL,
  init?: RequestInit,
) => Promise<Response>;

export interface WorkerDependencies {
  upstreamFetch?: UpstreamFetch;
  submissionTimeoutMs?: number;
  registrationRateLimiter?: RateLimiter;
  registrationProvider?: 'hubspot' | 'staging_mock';
}

const venueEndpointPath = '/api/venue-interest';
const hereAndNowEndpointPath = '/api/registrations/here-and-now';
const foundingFriendEndpointPath = '/api/registrations/founding-friend';
const maxRequestBodyBytes = 16 * 1024;
const hubSpotSubmissionTimeoutMs = 10_000;

const venueAllowedFields = new Set([
  'venueName',
  'venueType',
  'chainStatus',
  'venueCount',
  'venueCapacity',
  'website',
  'firstName',
  'lastName',
  'role',
  'email',
  'phoneNumber',
]);
const registrationSharedFields = [
  'firstName',
  'lastName',
  'email',
  'age',
  'gender',
  'usageReason',
  'marketingConsent',
] as const;
const hereAndNowAllowedFields = new Set(registrationSharedFields);
const foundingFriendAllowedFields = new Set([
  ...registrationSharedFields,
  'country',
]);
const genderValues = new Set([
  'Man',
  'Woman',
  'Non-binary',
  'Prefer not to answer',
]);
const mockScenarios = new Set([
  'success',
  'provider_rejection',
  'rate_limited',
  'provider_unavailable',
  'network_failure',
  'timeout',
]);

const venueEmailPattern = /^(?!.*\.\.)[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]{1,64}@(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$/;
const registrationEmailPattern = /^(?!.*\.\.)(?!\.)[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]{1,64}(?<!\.)@(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$/;
const websiteHostPattern = /^(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$/;
const guidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const lineBreakPattern = /[\r\n]/;
const whitespacePattern = /\s/;

class InvalidRequestError extends Error {}
class RequestBodyTooLargeError extends Error {}

interface VenueInterest {
  venueName: string;
  venueType?: string;
  chainStatus?: 'Independent' | 'Part of chain';
  venueCount?: number;
  venueCapacity?: number;
  website: string;
  firstName: string;
  lastName: string;
  role: string;
  email: string;
  phoneNumber?: string;
}

interface UserRegistration {
  firstName: string;
  lastName: string;
  email: string;
  age: number;
  gender?: string;
  usageReason?: string;
  marketingConsent: boolean;
  country?: string;
}

interface HubSpotField {
  name: string;
  value: string;
}

type Endpoint =
  | { kind: 'venue' }
  | { kind: 'registration'; workflow: 'here-and-now' | 'founding-friend' };

type RegistrationAvailability = 'enabled' | 'disabled' | 'invalid';

/** Handles all first-party form endpoints owned by the existing Worker. */
export async function handleRequest(
  request: Request,
  env: Env,
  dependencies: WorkerDependencies = {},
): Promise<Response> {
  const requestId = crypto.randomUUID();
  const url = new URL(request.url);
  const endpoint = endpointForPath(url.pathname);
  const corsHeaders = localDevelopmentCorsHeaders(request, env);

  if (endpoint === null) {
    return errorResponse(404, 'not_found', requestId);
  } else if (
    request.method === 'OPTIONS' &&
    endpoint.kind === 'registration' &&
    corsHeaders !== null
  ) {
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

  if (endpoint.kind === 'registration') {
    const availability = registrationAvailability(env);

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

    if (!hasValidMockConfiguration(env, url)) {
      return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
    }

    const registrationConfiguration = registrationFormGuid(endpoint, env);
    const rateLimiter =
      dependencies.registrationRateLimiter ?? env.REGISTRATION_RATE_LIMITER;
    const usesStagingMock =
      dependencies.registrationProvider === 'staging_mock';

    if (
      rateLimiter === undefined ||
      (!usesStagingMock &&
        (registrationConfiguration === null ||
          !hasValidPortalId(env.HUBSPOT_PORTAL_ID)))
    ) {
      return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
    }

    let rateLimitSucceeded: boolean;

    try {
      const rateLimitResult = await rateLimiter.limit({
        key: registrationRateLimitKey(request, url.pathname),
      });
      rateLimitSucceeded = rateLimitResult.success;
    } catch {
      return errorResponse(
        503,
        'service_unavailable',
        requestId,
        {},
        corsHeaders,
      );
    }

    if (!rateLimitSucceeded) {
      return errorResponse(429, 'rate_limited', requestId, {}, corsHeaders);
    }
  } else if (!hasValidMockConfiguration(env, url)) {
    return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
  }

  if (!isJsonContentType(request.headers.get('content-type'))) {
    return errorResponse(
      400,
      'invalid_request',
      requestId,
      {},
      corsHeaders,
    );
  }

  let fields: HubSpotField[];
  let formGuid: string | null;

  try {
    const body = await readLimitedBody(request);

    if (endpoint.kind === 'venue') {
      fields = venueToHubSpotFields(parseVenueInterest(body));
      formGuid = venueFormGuid(env);
    } else {
      const registration = parseRegistration(body, endpoint.workflow);
      fields = registrationToHubSpotFields(registration);
      formGuid = registrationFormGuid(endpoint, env);
    }
  } catch (error) {
    if (
      error instanceof InvalidRequestError ||
      error instanceof RequestBodyTooLargeError
    ) {
      return errorResponse(
        400,
        'invalid_request',
        requestId,
        {},
        corsHeaders,
      );
    } else {
      return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
    }
  }

  if (
    endpoint.kind === 'registration' &&
    dependencies.registrationProvider === 'staging_mock'
  ) {
    return new Response(null, { status: 204, headers: corsHeaders ?? {} });
  }

  const portalId = env.HUBSPOT_PORTAL_ID;

  if (formGuid === null || !hasConfiguredText(portalId)) {
    return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
  } else if (endpoint.kind === 'registration' && !hasValidPortalId(portalId)) {
    return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
  }

  const mockResponse = localMockResponse(env, requestId, corsHeaders);

  if (mockResponse !== null) {
    return mockResponse;
  }

  const controller = new AbortController();
  const timeoutMs =
    dependencies.submissionTimeoutMs ?? hubSpotSubmissionTimeoutMs;
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  const upstreamFetch = dependencies.upstreamFetch ?? fetch;
  let hubSpotResponse: Response;

  try {
    hubSpotResponse = await upstreamFetch(
      buildHubSpotEndpoint(portalId, formGuid),
      {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ fields }),
        signal: controller.signal,
      },
    );
  } catch {
    return errorResponse(
      503,
      'service_unavailable',
      requestId,
      {},
      corsHeaders,
    );
  } finally {
    clearTimeout(timeout);
  }

  if (hubSpotResponse.status === 200) {
    return new Response(null, { status: 204, headers: corsHeaders ?? {} });
  } else if (hubSpotResponse.status === 400) {
    return errorResponse(
      422,
      'submission_rejected',
      requestId,
      {},
      corsHeaders,
    );
  } else if (hubSpotResponse.status === 429) {
    return errorResponse(429, 'rate_limited', requestId, {}, corsHeaders);
  } else if (hubSpotResponse.status >= 500 && hubSpotResponse.status <= 599) {
    return errorResponse(
      503,
      'service_unavailable',
      requestId,
      {},
      corsHeaders,
    );
  } else {
    return errorResponse(500, 'unexpected', requestId, {}, corsHeaders);
  }
}

/** Backwards-compatible export retained for existing Worker tests/users. */
export const handleVenueInterestRequest = handleRequest;

export const worker = {
  fetch(request: Request, env: Env): Promise<Response> {
    return handleRequest(request, env);
  },
};

export default worker;

function endpointForPath(pathname: string): Endpoint | null {
  if (pathname === venueEndpointPath) {
    return { kind: 'venue' };
  } else if (pathname === hereAndNowEndpointPath) {
    return { kind: 'registration', workflow: 'here-and-now' };
  } else if (pathname === foundingFriendEndpointPath) {
    return { kind: 'registration', workflow: 'founding-friend' };
  } else {
    return null;
  }
}

function registrationAvailability(env: Env): RegistrationAvailability {
  const configuredValue = env.REGISTRATION_SUBMISSIONS_ENABLED;

  if (configuredValue === undefined || configuredValue.trim() === '') {
    return 'disabled';
  } else if (configuredValue === 'true') {
    return 'enabled';
  } else if (configuredValue === 'false') {
    return 'disabled';
  } else {
    return 'invalid';
  }
}

function registrationFormGuid(endpoint: Endpoint, env: Env): string | null {
  if (endpoint.kind !== 'registration') {
    return null;
  }

  const formGuid =
    endpoint.workflow === 'here-and-now'
      ? env.HUBSPOT_HERE_AND_NOW_FORM_GUID
      : env.HUBSPOT_FOUNDING_FRIEND_FORM_GUID;

  return typeof formGuid === 'string' && guidPattern.test(formGuid)
    ? formGuid
    : null;
}

function venueFormGuid(env: Env): string | null {
  const formGuid = env.HUBSPOT_FORM_GUID ?? env.HUBSPOT_VENUE_FORM_GUID;
  return typeof formGuid === 'string' && formGuid.trim().length > 0
    ? formGuid
    : null;
}

function hasValidPortalId(value: string | undefined): value is string {
  return typeof value === 'string' && /^\d+$/.test(value);
}

function hasConfiguredText(value: string | undefined): value is string {
  return typeof value === 'string' && value.trim().length > 0;
}

function hasValidMockConfiguration(env: Env, workerUrl: URL): boolean {
  const origin = env.LOCAL_DEVELOPMENT_ALLOWED_ORIGIN;
  const scenario = env.HUBSPOT_MOCK_SCENARIO;
  const isLocalWorker = isLoopbackHostname(workerUrl.hostname);

  if (!isLocalWorker) {
    return origin === undefined && scenario === undefined;
  } else if (origin === undefined || scenario === undefined) {
    return false;
  }

  try {
    const url = new URL(origin);
    return (
      url.origin === origin &&
      isLoopbackHostname(url.hostname) &&
      (url.protocol === 'http:' || url.protocol === 'https:') &&
      mockScenarios.has(scenario)
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

function localDevelopmentCorsHeaders(
  request: Request,
  env: Env,
): Headers | null {
  const configuredOrigin = env.LOCAL_DEVELOPMENT_ALLOWED_ORIGIN;
  const requestOrigin = request.headers.get('origin');

  if (
    configuredOrigin !== undefined &&
    requestOrigin === configuredOrigin &&
    hasValidMockConfiguration(env, new URL(request.url))
  ) {
    const headers = new Headers();
    headers.set('access-control-allow-origin', configuredOrigin);
    headers.set('access-control-allow-methods', 'POST, OPTIONS');
    headers.set('access-control-allow-headers', 'content-type');
    headers.set('vary', 'Origin');
    return headers;
  } else {
    return null;
  }
}

function localMockResponse(
  env: Env,
  requestId: string,
  corsHeaders: Headers | null,
): Response | null {
  const scenario = env.HUBSPOT_MOCK_SCENARIO;

  if (scenario === undefined) {
    return null;
  } else if (scenario === 'success') {
    return new Response(null, { status: 204, headers: corsHeaders ?? {} });
  } else if (scenario === 'provider_rejection') {
    return errorResponse(
      422,
      'submission_rejected',
      requestId,
      {},
      corsHeaders,
    );
  } else if (scenario === 'rate_limited') {
    return errorResponse(429, 'rate_limited', requestId, {}, corsHeaders);
  } else {
    return errorResponse(
      503,
      'service_unavailable',
      requestId,
      {},
      corsHeaders,
    );
  }
}

function registrationRateLimitKey(request: Request, pathname: string): string {
  const connectingIp = request.headers.get('cf-connecting-ip') ?? 'unknown';
  return `${pathname}:${connectingIp}`;
}

function isJsonContentType(contentType: string | null): boolean {
  return (
    contentType?.split(';', 1)[0]?.trim().toLowerCase() ===
    'application/json'
  );
}

async function readLimitedBody(request: Request): Promise<string> {
  const contentLength = request.headers.get('content-length');
  const declaredLength = contentLength === null ? null : Number(contentLength);

  if (
    declaredLength !== null &&
    Number.isFinite(declaredLength) &&
    declaredLength > maxRequestBodyBytes
  ) {
    throw new RequestBodyTooLargeError();
  }

  if (request.body === null) {
    return '';
  }

  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let totalBytes = 0;

  try {
    let chunk = await reader.read();

    while (!chunk.done) {
      totalBytes += chunk.value.byteLength;

      if (totalBytes > maxRequestBodyBytes) {
        await reader.cancel();
        throw new RequestBodyTooLargeError();
      } else {
        chunks.push(chunk.value);
        chunk = await reader.read();
      }
    }
  } finally {
    reader.releaseLock();
  }

  const body = new Uint8Array(totalBytes);
  let offset = 0;

  for (const chunk of chunks) {
    body.set(chunk, offset);
    offset += chunk.byteLength;
  }

  try {
    return new TextDecoder('utf-8', { fatal: true }).decode(body);
  } catch {
    throw new InvalidRequestError();
  }
}

function parseVenueInterest(body: string): VenueInterest {
  const parsed = parseJsonObject(body, venueAllowedFields);
  const venueName = requiredSingleLineText(parsed, 'venueName', 512);
  const venueType = optionalSingleLineText(parsed, 'venueType', 256);
  const chainStatus = optionalChainStatus(parsed);
  const venueCount = optionalPositiveInteger(parsed, 'venueCount');
  const venueCapacity = optionalPositiveInteger(parsed, 'venueCapacity');
  const website = requiredSingleLineText(parsed, 'website', 2048);
  const firstName = requiredSingleLineText(parsed, 'firstName', 256);
  const lastName = requiredSingleLineText(parsed, 'lastName', 256);
  const role = requiredSingleLineText(parsed, 'role', 256);
  const email = requiredSingleLineText(parsed, 'email', 320);
  const phoneNumber = optionalSingleLineText(parsed, 'phoneNumber', 64);

  if (!isWebsite(website) || !venueEmailPattern.test(email)) {
    throw new InvalidRequestError();
  } else if (phoneNumber !== undefined && !/^\d+$/.test(phoneNumber)) {
    throw new InvalidRequestError();
  } else if (venueCount !== undefined && chainStatus !== 'Part of chain') {
    throw new InvalidRequestError();
  }

  return {
    venueName,
    venueType,
    chainStatus,
    venueCount,
    venueCapacity,
    website,
    firstName,
    lastName,
    role,
    email,
    phoneNumber,
  };
}

function parseRegistration(
  body: string,
  workflow: 'here-and-now' | 'founding-friend',
): UserRegistration {
  const allowedFields =
    workflow === 'here-and-now'
      ? hereAndNowAllowedFields
      : foundingFriendAllowedFields;
  const parsed = parseJsonObject(body, allowedFields);
  const firstName = requiredSingleLineText(parsed, 'firstName');
  const lastName = requiredSingleLineText(parsed, 'lastName');
  const email = requiredSingleLineText(parsed, 'email');
  const age = requiredInteger(parsed, 'age');
  const gender = optionalSingleLineText(parsed, 'gender');
  const usageReason = optionalText(parsed, 'usageReason');
  const marketingConsent = requiredBoolean(parsed, 'marketingConsent');
  const country =
    workflow === 'founding-friend'
      ? requiredSingleLineText(parsed, 'country')
      : undefined;

  if (!registrationEmailPattern.test(email)) {
    throw new InvalidRequestError();
  } else if (gender !== undefined && !genderValues.has(gender)) {
    throw new InvalidRequestError();
  } else if (country !== undefined && !hubSpotCountryValues.has(country)) {
    throw new InvalidRequestError();
  }

  return {
    firstName,
    lastName,
    email,
    age,
    gender,
    usageReason,
    marketingConsent,
    country,
  };
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

  if (!isJsonObject(parsed)) {
    throw new InvalidRequestError();
  }

  for (const fieldName of Object.keys(parsed)) {
    if (!allowedFields.has(fieldName)) {
      throw new InvalidRequestError();
    }
  }

  return parsed;
}

function isJsonObject(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function requiredSingleLineText(
  body: Record<string, unknown>,
  fieldName: string,
  maximumLength = maxRequestBodyBytes,
): string {
  const value = body[fieldName];

  if (
    typeof value !== 'string' ||
    value.trim().length === 0 ||
    value.length > maximumLength ||
    lineBreakPattern.test(value)
  ) {
    throw new InvalidRequestError();
  }

  return value;
}

function optionalSingleLineText(
  body: Record<string, unknown>,
  fieldName: string,
  maximumLength = maxRequestBodyBytes,
): string | undefined {
  const value = optionalText(body, fieldName);

  if (
    value !== undefined &&
    (value.length > maximumLength || lineBreakPattern.test(value))
  ) {
    throw new InvalidRequestError();
  }

  return value;
}

function optionalText(
  body: Record<string, unknown>,
  fieldName: string,
): string | undefined {
  if (!(fieldName in body)) {
    return undefined;
  }

  const value = body[fieldName];

  if (typeof value !== 'string') {
    throw new InvalidRequestError();
  } else if (value.trim().length === 0) {
    return undefined;
  } else {
    return value;
  }
}

function requiredInteger(
  body: Record<string, unknown>,
  fieldName: string,
): number {
  const value = body[fieldName];

  if (typeof value === 'number' && Number.isSafeInteger(value)) {
    return value;
  } else {
    throw new InvalidRequestError();
  }
}

function requiredBoolean(
  body: Record<string, unknown>,
  fieldName: string,
): boolean {
  const value = body[fieldName];

  if (typeof value === 'boolean') {
    return value;
  } else {
    throw new InvalidRequestError();
  }
}

function optionalChainStatus(
  body: Record<string, unknown>,
): 'Independent' | 'Part of chain' | undefined {
  const chainStatus = optionalSingleLineText(body, 'chainStatus', 32);

  if (
    chainStatus === undefined ||
    chainStatus === 'Independent' ||
    chainStatus === 'Part of chain'
  ) {
    return chainStatus;
  } else {
    throw new InvalidRequestError();
  }
}

function optionalPositiveInteger(
  body: Record<string, unknown>,
  fieldName: string,
): number | undefined {
  if (!(fieldName in body)) {
    return undefined;
  }

  const value = body[fieldName];

  if (typeof value === 'number' && Number.isSafeInteger(value) && value >= 1) {
    return value;
  } else {
    throw new InvalidRequestError();
  }
}

function isWebsite(value: string): boolean {
  if (whitespacePattern.test(value) || value.includes('@')) {
    return false;
  }

  const candidate = value.includes('://') ? value : `https://${value}`;

  try {
    const url = new URL(candidate);
    return (
      (url.protocol === 'http:' || url.protocol === 'https:') &&
      websiteHostPattern.test(url.hostname)
    );
  } catch {
    return false;
  }
}

function buildHubSpotEndpoint(portalId: string, formGuid: string): URL {
  return new URL(
    `https://api.hsforms.com/submissions/v3/integration/submit/${encodeURIComponent(portalId)}/${encodeURIComponent(formGuid)}`,
  );
}

function venueToHubSpotFields(venueInterest: VenueInterest): HubSpotField[] {
  const fields: HubSpotField[] = [
    field('your_venue_s_name', venueInterest.venueName),
  ];

  addOptionalField(fields, 'type_of_venue', venueInterest.venueType);
  addOptionalField(
    fields,
    'independent_or_part_of_chain_',
    venueInterest.chainStatus,
  );
  addOptionalField(
    fields,
    'if_chain__number_of_venues',
    venueInterest.venueCount?.toString(),
  );
  addOptionalField(
    fields,
    'your_venue_s_capacity',
    venueInterest.venueCapacity?.toString(),
  );
  fields.push(
    field('website', venueInterest.website),
    field('first_name', venueInterest.firstName),
    field('last_name', venueInterest.lastName),
    field('role', venueInterest.role),
    field('email', venueInterest.email),
  );
  addOptionalField(fields, 'phone_number', venueInterest.phoneNumber);
  return fields;
}

function registrationToHubSpotFields(
  registration: UserRegistration,
): HubSpotField[] {
  const fields = [
    field('firstname', registration.firstName),
    field('lastname', registration.lastName),
    field('email', registration.email),
    field('age', registration.age.toString()),
  ];
  addOptionalField(fields, 'gender', registration.gender);
  addOptionalField(fields, 'usage_reason', registration.usageReason);
  fields.push(
    field('marketing_consent', registration.marketingConsent.toString()),
  );
  addOptionalField(fields, 'country', registration.country);
  return fields;
}

function addOptionalField(
  fields: HubSpotField[],
  name: string,
  value: string | undefined,
): void {
  if (value !== undefined) {
    fields.push(field(name, value));
  }
}

function field(name: string, value: string): HubSpotField {
  return { name, value };
}

function errorResponse(
  status: number,
  code: string,
  requestId: string,
  additionalHeaders: HeadersInit = {},
  corsHeaders: Headers | null = null,
): Response {
  const headers = new Headers(additionalHeaders);
  headers.set('content-type', 'application/json; charset=utf-8');
  headers.set('cache-control', 'no-store');

  if (corsHeaders !== null) {
    corsHeaders.forEach((value, name) => headers.set(name, value));
  }

  return new Response(JSON.stringify({ code, requestId }), {
    status,
    headers,
  });
}
