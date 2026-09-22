export interface Env {
  HUBSPOT_PORTAL_ID: string;
  HUBSPOT_FORM_GUID: string;
}

export type UpstreamFetch = (
  input: RequestInfo | URL,
  init?: RequestInit,
) => Promise<Response>;

export interface WorkerDependencies {
  upstreamFetch?: UpstreamFetch;
  submissionTimeoutMs?: number;
}

const endpointPath = '/api/venue-interest';
const maxRequestBodyBytes = 16 * 1024;
const hubSpotSubmissionTimeoutMs = 10_000;

const allowedFields = new Set([
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

const emailPattern = /^(?!.*\.\.)[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]{1,64}@(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$/;
const websiteHostPattern = /^(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$/;
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

interface HubSpotField {
  name: string;
  value: string;
}

/**
 * Handles the first-party venue enquiry endpoint without exposing HubSpot
 * details or submitted form content to the browser.
 */
export async function handleVenueInterestRequest(
  request: Request,
  env: Env,
  dependencies: WorkerDependencies = {},
): Promise<Response> {
  const requestId = crypto.randomUUID();
  const url = new URL(request.url);

  if (url.pathname !== endpointPath) {
    return errorResponse(404, 'not_found', requestId);
  } else if (request.method !== 'POST') {
    return errorResponse(405, 'method_not_allowed', requestId, {
      Allow: 'POST',
    });
  } else if (!isJsonContentType(request.headers.get('content-type'))) {
    return errorResponse(400, 'invalid_request', requestId);
  }

  let venueInterest: VenueInterest;

  try {
    venueInterest = parseVenueInterest(await readLimitedBody(request));
  } catch (error) {
    if (
      error instanceof InvalidRequestError ||
      error instanceof RequestBodyTooLargeError
    ) {
      return errorResponse(400, 'invalid_request', requestId);
    } else {
      return errorResponse(500, 'unexpected', requestId);
    }
  }

  if (!hasValidConfiguration(env)) {
    return errorResponse(500, 'unexpected', requestId);
  }

  const controller = new AbortController();
  const timeoutMs =
    dependencies.submissionTimeoutMs ?? hubSpotSubmissionTimeoutMs;
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  const upstreamFetch = dependencies.upstreamFetch ?? fetch;

  let hubSpotResponse: Response;

  try {
    hubSpotResponse = await upstreamFetch(buildHubSpotEndpoint(env), {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        fields: toHubSpotFields(venueInterest),
      }),
      signal: controller.signal,
    });
  } catch {
    return errorResponse(503, 'service_unavailable', requestId);
  } finally {
    clearTimeout(timeout);
  }

  if (hubSpotResponse.status === 200) {
    return new Response(null, { status: 204 });
  } else if (hubSpotResponse.status === 400) {
    return errorResponse(422, 'submission_rejected', requestId);
  } else if (hubSpotResponse.status === 429) {
    return errorResponse(429, 'rate_limited', requestId);
  } else if (hubSpotResponse.status >= 500 && hubSpotResponse.status <= 599) {
    return errorResponse(503, 'service_unavailable', requestId);
  } else {
    return errorResponse(500, 'unexpected', requestId);
  }
}

export const worker = {
  fetch(request: Request, env: Env): Promise<Response> {
    return handleVenueInterestRequest(request, env);
  },
};

export default worker;

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

  const venueName = requiredText(parsed, 'venueName', 512);
  const venueType = optionalText(parsed, 'venueType', 256);
  const chainStatus = optionalChainStatus(parsed);
  const venueCount = optionalPositiveInteger(parsed, 'venueCount');
  const venueCapacity = optionalPositiveInteger(parsed, 'venueCapacity');
  const website = requiredText(parsed, 'website', 2048);
  const firstName = requiredText(parsed, 'firstName', 256);
  const lastName = requiredText(parsed, 'lastName', 256);
  const role = requiredText(parsed, 'role', 256);
  const email = requiredText(parsed, 'email', 320);
  const phoneNumber = optionalText(parsed, 'phoneNumber', 64);

  if (!isWebsite(website) || !emailPattern.test(email)) {
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

function isJsonObject(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function requiredText(
  body: Record<string, unknown>,
  fieldName: string,
  maximumLength: number,
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

function optionalText(
  body: Record<string, unknown>,
  fieldName: string,
  maximumLength: number,
): string | undefined {
  if (!(fieldName in body)) {
    return undefined;
  }

  const value = body[fieldName];

  if (
    typeof value !== 'string' ||
    value.length > maximumLength ||
    lineBreakPattern.test(value)
  ) {
    throw new InvalidRequestError();
  } else if (value.trim().length === 0) {
    return undefined;
  } else {
    return value;
  }
}

function optionalChainStatus(
  body: Record<string, unknown>,
): 'Independent' | 'Part of chain' | undefined {
  const chainStatus = optionalText(body, 'chainStatus', 32);

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

function hasValidConfiguration(env: Env): boolean {
  return (
    typeof env.HUBSPOT_PORTAL_ID === 'string' &&
    env.HUBSPOT_PORTAL_ID.trim().length > 0 &&
    typeof env.HUBSPOT_FORM_GUID === 'string' &&
    env.HUBSPOT_FORM_GUID.trim().length > 0
  );
}

function buildHubSpotEndpoint(env: Env): URL {
  return new URL(
    `https://api.hsforms.com/submissions/v3/integration/submit/${encodeURIComponent(env.HUBSPOT_PORTAL_ID)}/${encodeURIComponent(env.HUBSPOT_FORM_GUID)}`,
  );
}

function toHubSpotFields(venueInterest: VenueInterest): HubSpotField[] {
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
): Response {
  const headers = new Headers(additionalHeaders);
  headers.set('content-type', 'application/json; charset=utf-8');
  headers.set('cache-control', 'no-store');

  return new Response(JSON.stringify({ code, requestId }), {
    status,
    headers,
  });
}
