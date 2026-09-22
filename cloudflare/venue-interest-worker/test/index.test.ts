import { describe, expect, it, vi } from 'vitest';

import {
  handleVenueInterestRequest,
  type Env,
  type UpstreamFetch,
} from '../src/index';

const endpoint = 'https://funapp.world/api/venue-interest';
const testEnv: Env = {
  HUBSPOT_PORTAL_ID: 'test-portal',
  HUBSPOT_FORM_GUID: '00000000-0000-0000-0000-000000000000',
};

const minimalVenueInterest = {
  venueName: 'Synthetic Venue',
  website: 'venue.test',
  firstName: 'Test',
  lastName: 'Contact',
  role: 'Venue manager',
  email: 'contact@venue.test',
};

describe('POST /api/venue-interest', () => {
  it('maps a valid full submission to the exact HubSpot payload', async () => {
    let capturedInput: RequestInfo | URL | undefined;
    let capturedInit: RequestInit | undefined;
    const response = await post(
      {
        ...minimalVenueInterest,
        venueType: 'Music venue',
        chainStatus: 'Part of chain',
        venueCount: 4,
        venueCapacity: 850,
        phoneNumber: '0034123456789',
      },
      async (input, init) => {
        capturedInput = input;
        capturedInit = init;
        return new Response('not used', { status: 200 });
      },
    );

    expect(response.status).toBe(204);
    expect(capturedInput).toEqual(
      new URL(
        'https://api.hsforms.com/submissions/v3/integration/submit/' +
          'test-portal/00000000-0000-0000-0000-000000000000',
      ),
    );
    expect(capturedInit?.method).toBe('POST');
    expect(capturedInit?.headers).toEqual({
      'content-type': 'application/json',
    });
    expect(JSON.parse(capturedInit?.body as string)).toEqual({
      fields: [
        { name: 'your_venue_s_name', value: 'Synthetic Venue' },
        { name: 'type_of_venue', value: 'Music venue' },
        {
          name: 'independent_or_part_of_chain_',
          value: 'Part of chain',
        },
        { name: 'if_chain__number_of_venues', value: '4' },
        { name: 'your_venue_s_capacity', value: '850' },
        { name: 'website', value: 'venue.test' },
        { name: 'first_name', value: 'Test' },
        { name: 'last_name', value: 'Contact' },
        { name: 'role', value: 'Venue manager' },
        { name: 'email', value: 'contact@venue.test' },
        { name: 'phone_number', value: '0034123456789' },
      ],
    });
  });

  it('accepts the required-only flow and omits absent optional HubSpot fields', async () => {
    let capturedBody = '';
    const response = await post(minimalVenueInterest, async (_, init) => {
      capturedBody = init?.body as string;
      return new Response(null, { status: 200 });
    });

    expect(response.status).toBe(204);
    expect(JSON.parse(capturedBody)).toEqual({
      fields: [
        { name: 'your_venue_s_name', value: 'Synthetic Venue' },
        { name: 'website', value: 'venue.test' },
        { name: 'first_name', value: 'Test' },
        { name: 'last_name', value: 'Contact' },
        { name: 'role', value: 'Venue manager' },
        { name: 'email', value: 'contact@venue.test' },
      ],
    });
  });

  it('accepts the Independent flow without venueCount', async () => {
    let capturedBody = '';
    const response = await post(
      { ...minimalVenueInterest, chainStatus: 'Independent' },
      async (_, init) => {
        capturedBody = init?.body as string;
        return new Response(null, { status: 200 });
      },
    );

    expect(response.status).toBe(204);
    expect(JSON.parse(capturedBody).fields).toContainEqual({
      name: 'independent_or_part_of_chain_',
      value: 'Independent',
    });
    expect(JSON.parse(capturedBody).fields).not.toContainEqual({
      name: 'if_chain__number_of_venues',
      value: expect.any(String),
    });
  });

  it('allows Part of chain without venueCount, matching the current form rule', async () => {
    const response = await post(
      { ...minimalVenueInterest, chainStatus: 'Part of chain' },
      successfulUpstreamFetch,
    );

    expect(response.status).toBe(204);
  });

  it('rejects venueCount outside the Part of chain flow', async () => {
    const response = await post(
      {
        ...minimalVenueInterest,
        chainStatus: 'Independent',
        venueCount: 2,
      },
      successfulUpstreamFetch,
    );

    await expectInvalidRequest(response);
  });

  it('preserves phone leading zeroes and accepts a scheme-less website', async () => {
    let capturedBody = '';
    const response = await post(
      {
        ...minimalVenueInterest,
        phoneNumber: '00123456789',
        website: 'subdomain.venue.test/path?interest=fun',
      },
      async (_, init) => {
        capturedBody = init?.body as string;
        return new Response(null, { status: 200 });
      },
    );

    expect(response.status).toBe(204);
    expect(JSON.parse(capturedBody).fields).toContainEqual({
      name: 'phone_number',
      value: '00123456789',
    });
    expect(JSON.parse(capturedBody).fields).toContainEqual({
      name: 'website',
      value: 'subdomain.venue.test/path?interest=fun',
    });
  });

  it.each([
    ['invalid JSON', '{'],
    ['non-object JSON', JSON.stringify(['not', 'an', 'object'])],
    ['missing required field', JSON.stringify({ ...minimalVenueInterest, email: undefined })],
    ['wrong field type', JSON.stringify({ ...minimalVenueInterest, venueCapacity: '850' })],
    ['excessive field length', JSON.stringify({ ...minimalVenueInterest, venueName: 'v'.repeat(513) })],
    ['unknown top-level field', JSON.stringify({ ...minimalVenueInterest, unexpected: true })],
    ['invalid chain status', JSON.stringify({ ...minimalVenueInterest, chainStatus: 'Chain' })],
  ])('rejects %s', async (_, body) => {
    const response = await rawRequest(
      new Request(endpoint, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body,
      }),
    );

    await expectInvalidRequest(response);
  });

  it('rejects unsupported methods, paths, and content types before provider work', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>(successfulUpstreamFetch);
    const methodResponse = await rawRequest(
      new Request(endpoint, { method: 'GET' }),
      upstreamFetch,
    );
    const pathResponse = await rawRequest(
      new Request('https://funapp.world/api/other', { method: 'POST' }),
      upstreamFetch,
    );
    const contentTypeResponse = await rawRequest(
      new Request(endpoint, {
        method: 'POST',
        headers: { 'content-type': 'text/plain' },
        body: JSON.stringify(minimalVenueInterest),
      }),
      upstreamFetch,
    );
    const missingContentTypeResponse = await rawRequest(
      new Request(endpoint, {
        method: 'POST',
        body: JSON.stringify(minimalVenueInterest),
      }),
      upstreamFetch,
    );

    expect(methodResponse.status).toBe(405);
    expect(methodResponse.headers.get('allow')).toBe('POST');
    expect(pathResponse.status).toBe(404);
    await expectInvalidRequest(contentTypeResponse);
    await expectInvalidRequest(missingContentTypeResponse);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('rejects an oversized body before provider work', async () => {
    const upstreamFetch = vi.fn<UpstreamFetch>(successfulUpstreamFetch);
    const response = await rawRequest(
      new Request(endpoint, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: `{"venueName":"${'x'.repeat(16 * 1024)}"}`,
      }),
      upstreamFetch,
    );

    await expectInvalidRequest(response);
    expect(upstreamFetch).not.toHaveBeenCalled();
  });

  it('maps HubSpot 200 to 204 without exposing its response body', async () => {
    const response = await post(
      minimalVenueInterest,
      async () => new Response('provider submission detail', { status: 200 }),
    );

    expect(response.status).toBe(204);
    expect(await response.text()).toBe('');
  });

  it('maps HubSpot 400 to a provider-neutral rejection', async () => {
    const response = await post(
      minimalVenueInterest,
      async () => new Response('contact@venue.test should not escape', { status: 400 }),
    );

    await expectError(response, 422, 'submission_rejected');
  });

  it('maps HubSpot 429 to a provider-neutral rate-limit result', async () => {
    const response = await post(
      minimalVenueInterest,
      async () => new Response(null, { status: 429 }),
    );

    await expectError(response, 429, 'rate_limited');
  });

  it.each([500, 503])('maps HubSpot %s to service unavailable', async (status) => {
    const response = await post(
      minimalVenueInterest,
      async () => new Response(null, { status }),
    );

    await expectError(response, 503, 'service_unavailable');
  });

  it('maps provider network failures to service unavailable', async () => {
    const response = await post(minimalVenueInterest, async () => {
      throw new TypeError('synthetic network failure');
    });

    await expectError(response, 503, 'service_unavailable');
  });

  it('maps an aborted upstream request to service unavailable without retrying', async () => {
    let calls = 0;
    const response = await post(
      minimalVenueInterest,
      (_, init) =>
        new Promise<Response>((_, reject) => {
          calls += 1;
          init?.signal?.addEventListener('abort', () => reject(new DOMException('', 'AbortError')));
        }),
      1,
    );

    await expectError(response, 503, 'service_unavailable');
    expect(calls).toBe(1);
  });

  it('does not intentionally write submitted values to application logs', async () => {
    const log = vi.spyOn(console, 'log').mockImplementation(() => undefined);
    const info = vi.spyOn(console, 'info').mockImplementation(() => undefined);
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => undefined);
    const error = vi.spyOn(console, 'error').mockImplementation(() => undefined);

    try {
      const response = await post(
        {
          ...minimalVenueInterest,
          venueName: 'Private Synthetic Venue',
          phoneNumber: '00123456789',
        },
        successfulUpstreamFetch,
      );

      expect(response.status).toBe(204);
      expect(log).not.toHaveBeenCalled();
      expect(info).not.toHaveBeenCalled();
      expect(warn).not.toHaveBeenCalled();
      expect(error).not.toHaveBeenCalled();
    } finally {
      log.mockRestore();
      info.mockRestore();
      warn.mockRestore();
      error.mockRestore();
    }
  });
});

const successfulUpstreamFetch: UpstreamFetch = async () =>
  new Response(null, { status: 200 });

async function post(
  body: Record<string, unknown>,
  upstreamFetch: UpstreamFetch,
  submissionTimeoutMs?: number,
): Promise<Response> {
  return rawRequest(
    new Request(endpoint, {
      method: 'POST',
      headers: { 'content-type': 'application/json; charset=utf-8' },
      body: JSON.stringify(body),
    }),
    upstreamFetch,
    submissionTimeoutMs,
  );
}

async function rawRequest(
  request: Request,
  upstreamFetch: UpstreamFetch = successfulUpstreamFetch,
  submissionTimeoutMs?: number,
): Promise<Response> {
  return handleVenueInterestRequest(request, testEnv, {
    upstreamFetch,
    submissionTimeoutMs,
  });
}

async function expectInvalidRequest(response: Response): Promise<void> {
  await expectError(response, 400, 'invalid_request');
}

async function expectError(
  response: Response,
  status: number,
  code: string,
): Promise<void> {
  expect(response.status).toBe(status);
  expect(response.headers.get('access-control-allow-origin')).toBeNull();
  expect(await response.json()).toEqual({
    code,
    requestId: expect.any(String),
  });
}
