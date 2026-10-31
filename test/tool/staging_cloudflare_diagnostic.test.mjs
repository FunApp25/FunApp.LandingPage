import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { test } from 'node:test';
import { diagnoseStaging } from '../../tool/staging_cloudflare_diagnostic.mjs';

const env = {
  CLOUDFLARE_ACCOUNT_ID: '0123456789abcdef0123456789abcdef',
  CLOUDFLARE_WORKERS_API_TOKEN: 'test-token-never-log',
};
const secret = 'response-secret-never-log';
const worker = 'funapp-founding-friend-payment-staging';
const origin = `https://api.cloudflare.com/client/v4/accounts/${env.CLOUDFLARE_ACCOUNT_ID}`;
const base = `/workers/services/${worker}/environments/actual-environment`;
const categories = [
  'service_metadata', 'environment_bindings', 'environment_routes',
  'custom_domain_records', 'worker_subdomain', 'worker_environment', 'worker_schedules',
];
const metadata = {
  success: true,
  result: { default_environment: { environment: 'actual-environment' }, secret },
};
const response = (status = 200, body = { success: true, result: { secret } }) =>
  Response.json(body, { status, headers: { 'cf-ray': '0123456789abcdef-MAD' } });

function assertSanitized(lines) {
  for (const line of lines) {
    const record = JSON.parse(line);
    assert.deepEqual(Object.keys(record), ['endpoint', 'http_status', 'cloudflare_error_codes', 'cf_ray']);
    assert.ok(categories.includes(record.endpoint));
    for (const value of [env.CLOUDFLARE_WORKERS_API_TOKEN, env.CLOUDFLARE_ACCOUNT_ID, secret, 'actual-environment']) {
      assert.ok(!line.includes(value));
    }
  }
}

test('uses seven fixed GETs and the service internal environment, with no redirects', async () => {
  const calls = [];
  const lines = [];
  const ok = await diagnoseStaging(env, async (url, options) => {
    calls.push(url);
    assert.equal(options.method, 'GET');
    assert.equal(options.redirect, 'error');
    assert.deepEqual(options.headers, { Authorization: `Bearer ${env.CLOUDFLARE_WORKERS_API_TOKEN}` });
    assert.ok(options.signal instanceof AbortSignal);
    assert.equal(options.signal.aborted, false);
    return response(200, calls.length === 1 ? metadata : undefined);
  }, (line) => lines.push(line));
  assert.equal(ok, true);
  assert.deepEqual(calls, [
    `/workers/services/${worker}`,
    `${base}/bindings`, `${base}/routes?show_zonename=true`,
    `/workers/domains/records?page=0&per_page=5&service=${worker}&environment=actual-environment`,
    `${base}/subdomain`, base, `/workers/scripts/${worker}/schedules`,
  ].map((path) => origin + path));
  assert.deepEqual(lines.map((line) => JSON.parse(line).endpoint), categories);
  assert.ok(lines.every((line) => JSON.parse(line).http_status === 200));
  assertSanitized(lines);
});

for (const status of [403, 429, 500, 503]) {
  test(`HTTP ${status}: records only safe codes and continues all six probes`, async () => {
    let calls = 0;
    const lines = [];
    const ok = await diagnoseStaging(env, async () => {
      calls++;
      return calls === 1 ? response(200, metadata) : response(status, {
        success: false,
        errors: [{ code: 10000, message: secret }, { code: secret }, { code: -1 }, null],
        result: { bindings: [{ value: secret }] },
      });
    }, (line) => lines.push(line));
    assert.equal(ok, false);
    assert.equal(calls, 7);
    for (const line of lines.slice(1)) {
      assert.deepEqual(JSON.parse(line), {
        endpoint: categories[lines.indexOf(line)], http_status: status,
        cloudflare_error_codes: [10000], cf_ray: '0123456789abcdef-MAD',
      });
    }
    assertSanitized(lines);
  });
}

for (const failure of ['network', 'timeout', 'body_timeout', 'malformed_json', 'malformed_shape', 'unsafe_ray', 'redirect']) {
  test(`${failure}: suppresses payloads and exceptions, and continues probes`, async () => {
    let calls = 0;
    const lines = [];
    const ok = await diagnoseStaging(env, async () => {
      calls++;
      if (calls === 1) return response(200, metadata);
      if (failure === 'network') throw new Error(secret);
      if (failure === 'timeout') throw new DOMException(secret, 'TimeoutError');
      if (failure === 'body_timeout') return {
        status: 200, ok: true, headers: new Headers(),
        json: async () => { throw new DOMException(secret, 'TimeoutError'); },
      };
      if (failure === 'malformed_json') return new Response(secret, { status: 200 });
      if (failure === 'malformed_shape') return response(200, { message: secret });
      if (failure === 'unsafe_ray') return new Response(JSON.stringify({ success: false }), {
        status: 403, headers: { 'cf-ray': secret, 'x-secret': secret },
      });
      return new Response(null, { status: 302, headers: { location: `https://example.invalid/${secret}` } });
    }, (line) => lines.push(line));
    assert.equal(ok, false);
    assert.equal(calls, 7);
    assert.equal(lines.length, 7);
    const first = JSON.parse(lines[1]);
    assert.equal(first.http_status, ['network', 'timeout'].includes(failure) ? null
      : failure === 'unsafe_ray' ? 403 : failure === 'redirect' ? 302 : 200);
    assert.equal(first.cf_ray, failure === 'malformed_shape' ? '0123456789abcdef-MAD' : null);
    assertSanitized(lines);
  });
}

test('failed service lookup or invalid environment prevents guessed environment requests', async () => {
  for (const body of [
    { success: false, errors: [{ code: 10000, message: secret }] },
    { success: true, result: null },
    ...['', '..', 'https://example.invalid', 'a/b', secret.repeat(10), null, 123].map((environment) => ({
      success: true, result: { default_environment: { environment } },
    })),
  ]) {
    let calls = 0;
    const lines = [];
    assert.equal(await diagnoseStaging(env, async () => {
      calls++;
      return response(200, body);
    }, (line) => lines.push(line)), false);
    assert.equal(calls, 1);
    assert.equal(lines.length, 1);
    assertSanitized(lines);
  }
});

test('missing credentials or invalid account produce no requests and only a null service record', async () => {
  for (const override of [
    { CLOUDFLARE_ACCOUNT_ID: undefined }, { CLOUDFLARE_ACCOUNT_ID: '../other-account' },
    { CLOUDFLARE_WORKERS_API_TOKEN: undefined }, { CLOUDFLARE_WORKERS_API_TOKEN: ' ' },
  ]) {
    const lines = [];
    assert.equal(await diagnoseStaging({ ...env, ...override }, async () => {
      assert.fail('must not make a request');
    }, (line) => lines.push(line)), false);
    assert.deepEqual(lines.map(JSON.parse), [{
      endpoint: 'service_metadata', http_status: null, cloudflare_error_codes: [], cf_ray: null,
    }]);
  }
});

test('CLI stdout and stderr remain sanitized for success, failures, and absent credentials', () => {
  const bootstrap = `
    let calls = 0;
    globalThis.fetch = async () => {
      calls++;
      const scenario = process.env.MOCK_SCENARIO;
      if (scenario === 'timeout') throw new DOMException(${JSON.stringify(secret)}, 'TimeoutError');
      if (scenario === 'malformed') return new Response(${JSON.stringify(secret)});
      return Response.json(calls === 1 ? ${JSON.stringify(metadata)} : {
        success: scenario === '200', result: { secret: ${JSON.stringify(secret)} },
        errors: [{ code: 10000, message: ${JSON.stringify(secret)} }],
      }, { status: calls === 1 ? 200 : Number(scenario) });
    };
  `;
  for (const scenario of ['200', '403', '429', '500', 'timeout', 'malformed', 'missing']) {
    const child = spawnSync(process.execPath, [
      '--import', `data:text/javascript,${encodeURIComponent(bootstrap)}`,
      fileURLToPath(new URL('../../tool/staging_cloudflare_diagnostic.mjs', import.meta.url)),
    ], {
      encoding: 'utf8', timeout: 5_000,
      env: { ...env, MOCK_SCENARIO: scenario, ...(scenario === 'missing' && { CLOUDFLARE_WORKERS_API_TOKEN: '' }) },
    });
    assert.equal(child.status, scenario === '200' ? 0 : 1);
    assert.equal(child.stderr, '');
    const lines = child.stdout.trim().split('\n');
    assert.equal(lines.length, ['timeout', 'malformed', 'missing'].includes(scenario) ? 1 : 7);
    assertSanitized(lines);
  }
});
