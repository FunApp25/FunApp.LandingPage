import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { chmodSync, mkdtempSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { test } from 'node:test';
import { deploymentConfig, paymentConfiguration, prepareDeployment, targets } from '../../tool/prepare_staging_deployment.mjs';

process.chdir(fileURLToPath(new URL('../../', import.meta.url)));

const environment = {
  CLOUDFLARE_ACCOUNT_ID: 'test-account',
  CLOUDFLARE_STAGING_SITE_API_TOKEN: 'site-token',
  CLOUDFLARE_WORKERS_API_TOKEN: 'api-token',
  STAGING_PAYMENT_CREATION_ENABLED: 'true',
  STRIPE_SANDBOX_PRICE_ID: 'price_example',
  STRIPE_SANDBOX_AUTOMATIC_TAX_ENABLED: 'false',
  STRIPE_SANDBOX_RESTRICTED_KEY: 'rk_test_REDACTEDSAFEVALUE',
  STAGING_PURCHASE_REFERENCE_SECRET: 'local-test-reference-secret-at-least-32-characters',
  RUNNER_TEMP: tmpdir(),
};
const remoteBindings = [
  { name: 'ASSETS', type: 'assets' },
  { name: 'STAGING_REGISTRATION_MOCK_ENABLED', type: 'plain_text', text: 'true' },
  { name: 'REGISTRATION_RATE_LIMITER', type: 'ratelimit', namespace_id: '9001', simple: { limit: 7, period: 60 } },
  { name: 'PAYMENT_RATE_LIMITER', type: 'ratelimit', namespace_id: '9002', simple: { limit: 8, period: 60 } },
  { name: 'DASHBOARD_VARIABLE', type: 'plain_text', text: 'must-not-be-copied' },
  { name: 'DASHBOARD_KV', type: 'kv_namespace', namespace_id: 'example' },
  { name: 'STRIPE_SECRET_KEY', type: 'secret_text' },
  { name: 'PURCHASE_REFERENCE_SECRET', type: 'secret_text' },
];
const sourceConfig = (project) => JSON.parse(readFileSync(`cloudflare/${project}/wrangler.jsonc`, 'utf8')
  .replace(/^\s*\/\/.*$/gm, ''));

test('payment enablement is explicit, sandbox-only, and never defaults', () => {
  const vars = paymentConfiguration(environment);
  assert.deepEqual(vars, {
    PAYMENT_CREATION_ENABLED: 'true',
    STRIPE_PRICE_ID: 'price_example',
    STRIPE_EXPECTED_LIVEMODE: 'false',
    STRIPE_AUTOMATIC_TAX_ENABLED: 'false',
    PUBLIC_APP_ORIGIN: 'https://staging.funapp.world',
  });
  assert.equal(paymentConfiguration({ ...environment, STAGING_PAYMENT_CREATION_ENABLED: 'false' }).PAYMENT_CREATION_ENABLED, 'false');
  for (const name of Object.keys(environment)) {
    assert.throws(() => paymentConfiguration({ ...environment, [name]: '' }), /Missing staging configuration/);
  }
  assert.throws(() => paymentConfiguration({
    ...environment,
    STRIPE_SANDBOX_RESTRICTED_KEY: '',
    STRIPE_SECRET_KEY: environment.STRIPE_SANDBOX_RESTRICTED_KEY,
  }), /Missing staging configuration: STRIPE_SANDBOX_RESTRICTED_KEY/);
  for (const value of ['yes', 'TRUE', ' true ', '0']) {
    assert.throws(() => paymentConfiguration({ ...environment, STAGING_PAYMENT_CREATION_ENABLED: value }));
  }
  for (const override of [
    { STRIPE_SANDBOX_RESTRICTED_KEY: 'rk_live_REDACTEDSAFEVALUE' },
    { STRIPE_SANDBOX_RESTRICTED_KEY: 'sk_test_REDACTEDSAFEVALUE' },
    { STRIPE_SANDBOX_PRICE_ID: 'STAGING_PRICE_ID_NOT_CONFIGURED' },
    { STRIPE_SANDBOX_AUTOMATIC_TAX_ENABLED: 'true' },
    { STAGING_PURCHASE_REFERENCE_SECRET: 'short' },
  ]) assert.throws(() => paymentConfiguration({ ...environment, ...override }));
});

function metadataResponse(url) {
  const worker = url.match(/workers\/(?:services|scripts|workers)\/([^/?]+)/)?.[1];
  if (url.endsWith(`/services/${worker}`)) return {
    id: worker, default_environment: { environment: 'actual-environment', script: { last_deployed_from: 'dash' } },
  };
  if (url.endsWith(`/workers/workers/${worker}`)) return { subdomain: { enabled: false, previews_enabled: false } };
  if (url.endsWith('/bindings')) return remoteBindings;
  if (url.endsWith('/settings')) return { bindings: remoteBindings };
  if (url.endsWith('/subdomain')) return { enabled: false, previews_enabled: false };
  if (url.endsWith('/schedules')) return { schedules: [] };
  if (url.endsWith('/deployments')) return { deployments: [] };
  if (url.endsWith('/secrets')) return remoteBindings.filter((b) => b.type === 'secret_text');
  if (url.endsWith('/environments/actual-environment')) return { script: { compatibility_date: '2026-09-22' } };
  assert.fail(`Unexpected metadata request: ${url}`);
}

test('purchase-reference preflight rejects invalid secrets before reads or file writes', async () => {
  const directory = mkdtempSync(resolve(tmpdir(), 'staging-invalid-secret-'));
  try {
    for (const secret of [
      undefined,
      '',
      'x'.repeat(31),
      `${'x'.repeat(32)}\n`,
      `\r${'x'.repeat(32)}`,
      `${'x'.repeat(32)}\r\n`,
      `${'x'.repeat(16)}\n${'x'.repeat(16)}`,
    ]) {
      let reads = 0;
      await assert.rejects(
        prepareDeployment(
          {
            ...environment,
            RUNNER_TEMP: directory,
            STAGING_PURCHASE_REFERENCE_SECRET: secret,
          },
          async () => {
            reads += 1;
            throw new Error('Must not read metadata');
          },
        ),
      );
      assert.equal(reads, 0);
      assert.deepEqual(readdirSync(directory), []);
    }
    assert.doesNotThrow(() =>
      paymentConfiguration({
        ...environment,
        STAGING_PURCHASE_REFERENCE_SECRET: 'x'.repeat(32),
      }),
    );
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});

const requiredPaths = (worker, project) => [
  `services/${worker}`,
  `services/${worker}/environments/actual-environment/bindings`,
  `services/${worker}/environments/actual-environment/subdomain`,
  `services/${worker}/environments/actual-environment`,
  `scripts/${worker}/schedules`, `scripts/${worker}/settings`,
  `workers/${worker}`, `scripts/${worker}/deployments`,
  ...(project === 'founding-friend-payment-worker' ? [`scripts/${worker}/secrets`] : []),
];

test('all required preflight GETs use existing staging identities, actual environments and separate tokens', async () => {
  const directory = mkdtempSync(resolve(tmpdir(), 'staging-preflight-'));
  try {
    const calls = [];
    await prepareDeployment({ ...environment, RUNNER_TEMP: directory }, async (url, options) => {
      calls.push([url, options.headers.Authorization]);
      assert.equal(options.method, 'GET');
      assert.equal(options.redirect, 'error');
      assert.ok(options.signal instanceof AbortSignal);
      // A Worker-scoped token cannot read these, and preflight must not request them.
      if (url.includes('/routes?') || url.includes('/domains/')) return new Response(null, { status: 403 });
      return Response.json({ success: true, result: metadataResponse(url) });
    });
    assert.deepEqual(calls, Object.entries(targets).flatMap(([project, name]) =>
      requiredPaths(name, project).map((path) => [
        `https://api.cloudflare.com/client/v4/accounts/test-account/workers/${path}`,
        project === 'staging-site-worker' ? 'Bearer site-token' : 'Bearer api-token',
      ])));
    assert.equal(statSync(resolve(directory, 'staging-payment-secrets.json')).mode & 0o777, 0o600);
    assert.deepEqual(JSON.parse(readFileSync(resolve(directory, 'staging-payment-secrets.json'), 'utf8')), {
      STRIPE_SECRET_KEY: environment.STRIPE_SANDBOX_RESTRICTED_KEY,
      PURCHASE_REFERENCE_SECRET: environment.STAGING_PURCHASE_REFERENCE_SECRET,
    });
    for (const project of Object.keys(targets)) {
      const config = readFileSync(resolve(directory, `${project}.json`), 'utf8');
      assert.ok(!config.includes(environment.STRIPE_SANDBOX_RESTRICTED_KEY));
      assert.ok(!config.includes(environment.STAGING_PURCHASE_REFERENCE_SECRET));
      assert.ok(!config.includes('must-not-be-copied'));
    }
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});

test('each required endpoint failing on any target leaves no deployable configs or secrets', async () => {
  for (const [project, worker] of Object.entries(targets)) {
    for (const path of requiredPaths(worker, project)) {
      for (const failure of ['403', 'missing', 'malformed', 'timeout']) {
        const directory = mkdtempSync(resolve(tmpdir(), 'staging-preflight-failure-'));
        try {
          let failureReached = false;
          await assert.rejects(prepareDeployment({ ...environment, RUNNER_TEMP: directory }, async (url) => {
            if (url.endsWith(`/workers/${path}`)) {
              failureReached = true;
              if (failure === '403') return new Response(null, { status: 403 });
              if (failure === 'missing') return Response.json({ success: false, errors: [{ code: 10007 }] });
              if (failure === 'malformed') return new Response('sensitive malformed response');
              throw new DOMException('sensitive response', 'TimeoutError');
            }
            return Response.json({ success: true, result: metadataResponse(url) });
          }));
          assert.ok(failureReached, `${path}: failure must be exercised`);
          assert.deepEqual(readdirSync(directory), []);
        } finally {
          rmSync(directory, { recursive: true, force: true });
        }
      }
    }
  }
});

test('invalid identities, metadata shapes, bindings and secret conflicts fail closed', async () => {
  for (const scenario of ['identity', 'environment', 'bindings', 'settings', 'subdomain', 'worker', 'metadata', 'schedules', 'deployments', 'version_list', 'secrets']) {
    const directory = mkdtempSync(resolve(tmpdir(), 'staging-invalid-metadata-'));
    try {
      await assert.rejects(prepareDeployment({ ...environment, RUNNER_TEMP: directory }, async (url) => {
        let result = metadataResponse(url);
        if (url.includes(targets['founding-friend-payment-worker'])) {
          if (scenario === 'identity' && result.id) result.id = 'production';
          if (scenario === 'environment' && result.id) result.default_environment.environment = '../production';
          if (scenario === 'bindings' && url.endsWith('/bindings')) result = [];
          if (scenario === 'settings' && url.endsWith('/settings')) result = { bindings: [] };
          if (scenario === 'subdomain' && url.endsWith('/subdomain')) result = {};
          if (scenario === 'worker' && url.includes('/workers/workers/')) result = {};
          if (scenario === 'metadata' && url.endsWith('/environments/actual-environment')) result = {};
          if (scenario === 'schedules' && url.endsWith('/schedules')) result = {};
          if (scenario === 'deployments' && url.endsWith('/deployments')) result = {};
          if (scenario === 'version_list' && url.endsWith('/deployments')) result = { deployments: [{}] };
          if (scenario === 'secrets' && url.endsWith('/secrets')) result = [{ name: 'STRIPE_PRICE_ID', type: 'secret_text' }];
        }
        return Response.json({ success: true, result });
      }));
      assert.deepEqual(readdirSync(directory), []);
    } finally {
      rmSync(directory, { recursive: true, force: true });
    }
  }
  for (const [project, name, type] of [
    ['staging-site-worker', 'ASSETS', 'assets'],
    ['venue-interest-worker', 'REGISTRATION_RATE_LIMITER', 'ratelimit'],
    ['venue-interest-worker', 'STAGING_REGISTRATION_MOCK_ENABLED', 'plain_text'],
    ['founding-friend-payment-worker', 'PAYMENT_RATE_LIMITER', 'ratelimit'],
    ['founding-friend-payment-worker', 'STRIPE_SECRET_KEY', 'secret_text'],
    ['founding-friend-payment-worker', 'PURCHASE_REFERENCE_SECRET', 'secret_text'],
  ]) {
    for (const invalid of [remoteBindings.filter((b) => b.name !== name),
      remoteBindings.map((b) => b.name === name ? { ...b, type: 'wrong_type' } : b)]) {
      assert.throws(() => deploymentConfig(project, sourceConfig(project), invalid, {}), `${project}: ${name} must be ${type}`);
    }
  }
  assert.throws(() => deploymentConfig('staging-site-worker', { name: 'production' }, [], {}), /identity/);
  assert.throws(() => deploymentConfig('staging-site-worker', { ...sourceConfig('staging-site-worker'), routes: [] }, [], {}), /routes/);
});

test('multi-version deployment metadata must be readable before any configuration is written', async () => {
  const versionIds = ['11111111-1111-4111-8111-111111111111', '22222222-2222-4222-8222-222222222222'];
  for (const failure of ['none', '403', 'malformed']) {
    const directory = mkdtempSync(resolve(tmpdir(), 'staging-versions-'));
    const reads = [];
    try {
      const preparation = prepareDeployment({ ...environment, RUNNER_TEMP: directory }, async (url) => {
        if (url.includes('/versions/')) {
          reads.push(url.split('/').at(-1));
          assert.deepEqual(readdirSync(directory), []);
          if (failure === '403') return new Response(null, { status: 403 });
          if (failure === 'malformed') return Response.json({ success: true, result: {} });
          return Response.json({ success: true, result: {
            id: reads.at(-1), metadata: { created_on: '2026-11-01T00:00:00Z' },
          } });
        }
        let result = metadataResponse(url);
        if (url.endsWith('/deployments')) result = { deployments: [{ versions: versionIds.map((version_id) => ({ version_id, percentage: 50 })) }] };
        return Response.json({ success: true, result });
      });
      if (failure !== 'none') {
        await assert.rejects(preparation);
        assert.deepEqual(readdirSync(directory), []);
        assert.deepEqual(reads, [versionIds[0]]);
      } else {
        await preparation;
        assert.deepEqual(reads, Object.keys(targets).flatMap(() => versionIds));
      }
    } finally {
      rmSync(directory, { recursive: true, force: true });
    }
  }
});

test('actual workflow revision check admits only current dev HEAD and fails closed on lookup errors', () => {
  const workflow = readFileSync('.github/workflows/deploy-staging-site.yml', 'utf8');
  const revisionStep = workflow.split('      - name: Check revision is still dev HEAD\n')[1].split('\n      - name:')[0];
  const script = revisionStep.split('        run: |\n')[1].split('\n').map((line) => line.slice(10)).join('\n');
  const directory = mkdtempSync(resolve(tmpdir(), 'staging-revision-'));
  try {
    writeFileSync(resolve(directory, 'git'), '#!/bin/sh\nif [ "$MOCK_DEV_HEAD" = error ]; then exit 1; fi\nprintf "%s\\trefs/heads/dev\\n" "$MOCK_DEV_HEAD"\n');
    chmodSync(resolve(directory, 'git'), 0o700);
    for (const head of ['current', 'superseded', 'error']) {
      const output = resolve(directory, 'output');
      writeFileSync(output, '');
      const child = spawnSync('bash', ['-c', script], { encoding: 'utf8', env: {
        PATH: `${directory}:/usr/bin:/bin`, GITHUB_SHA: 'current', GITHUB_OUTPUT: output, MOCK_DEV_HEAD: head,
      } });
      assert.equal(child.status, head === 'error' ? 1 : 0, child.stderr);
      assert.equal(readFileSync(output, 'utf8'), head === 'current' ? 'current=true\n' : '');
    }
    const publishSteps = workflow.split('\n      - name: Deploy staging ').slice(1);
    assert.equal(publishSteps.length, 3);
    for (const step of publishSteps) {
      assert.match(step.split('\n      - name:')[0], /if: steps.revision.outputs.current == 'true'/);
    }
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});

test('CLI preflight never logs credentials, responses or provider exceptions', () => {
  for (const failure of ['403', 'timeout', 'malformed']) {
    const secret = 'response-secret-never-log';
    const bootstrap = `globalThis.fetch = async () => {
      if (${JSON.stringify(failure)} === 'timeout') throw new Error(${JSON.stringify(secret)});
      return new Response(${JSON.stringify(secret)}, { status: ${failure === '403' ? 403 : 200} });
    };`;
    const child = spawnSync(process.execPath, [
      '--import', `data:text/javascript,${encodeURIComponent(bootstrap)}`,
      resolve('tool/prepare_staging_deployment.mjs'),
    ], { encoding: 'utf8', env: environment, timeout: 5000 });
    assert.equal(child.status, 1);
    assert.equal(child.stdout, '');
    for (const value of [secret, ...Object.values(environment)]) assert.ok(!child.stderr.includes(value));
    assert.match(child.stderr, /Staging preflight failed/);
  }
});

for (const project of process.env.WORKER_PROJECT ? [process.env.WORKER_PROJECT] : Object.keys(targets)) {
  test(`${project}: fixed staging Wrangler emits binding preservation metadata without deploying`, () => {
    const directory = mkdtempSync(resolve(tmpdir(), 'staging-upload-'));
    try {
      const config = deploymentConfig(project, sourceConfig(project), remoteBindings, paymentConfiguration(environment));
      assert.equal(config.name, targets[project]);
      assert.equal(config.ratelimits, undefined);
      assert.equal(config.route, undefined);
      assert.equal(config.routes, undefined);
      const configPath = resolve(directory, 'wrangler.json');
      const bundlePath = resolve(directory, 'bundle');
      writeFileSync(configPath, JSON.stringify(config));
      const secretArgs = [];
      if (project === 'founding-friend-payment-worker') {
        const secretsPath = resolve(directory, 'secrets.json');
        writeFileSync(secretsPath, JSON.stringify({
          STRIPE_SECRET_KEY: environment.STRIPE_SANDBOX_RESTRICTED_KEY,
          PURCHASE_REFERENCE_SECRET: environment.STAGING_PURCHASE_REFERENCE_SECRET,
        }), { mode: 0o600 });
        secretArgs.push('--secrets-file', secretsPath);
      }
      const childEnv = Object.fromEntries(Object.entries(process.env)
        .filter(([name]) => !/^(CLOUDFLARE_|STRIPE_|STAGING_PURCHASE_REFERENCE_SECRET)/.test(name)));
      const result = spawnSync(process.execPath, [
        resolve('tool/staging-wrangler/wrangler.mjs'),
        'deploy', '--dry-run', '--env=', '--config', configPath, '--outfile', bundlePath,
        ...secretArgs,
      ], {
        encoding: 'utf8',
        env: { ...childEnv, WRANGLER_SEND_METRICS: 'false', WRANGLER_LOG_SANITIZE: 'true', WRANGLER_LOG_PATH: resolve(directory, 'wrangler.log'), CLOUDFLARE_LOAD_DEV_VARS_FROM_DOT_ENV: 'false' },
      });
      assert.equal(result.status, 0, result.stderr || result.stdout);
      const bundle = readFileSync(bundlePath, 'utf8');
      const metadata = JSON.parse(bundle.match(/name="metadata"\r?\n\r?\n(.*)\r?\n--/)[1]);
      assert.deepEqual(new Set(metadata.keep_bindings), new Set([
        'plain_text', 'json', 'secret_text', 'secret_key', 'ratelimit', 'kv_namespace', 'assets',
      ]));
      assert.ok(!metadata.bindings.some((b) => b.type === 'ratelimit'));
      if (project === 'founding-friend-payment-worker') {
        assert.deepEqual(Object.fromEntries(metadata.bindings.filter((b) => b.type === 'plain_text')
          .map((b) => [b.name, b.text])), paymentConfiguration(environment));
        assert.deepEqual(metadata.bindings.filter((b) => b.type === 'secret_text').map((b) => b.name).sort(), [
          'PURCHASE_REFERENCE_SECRET', 'STRIPE_SECRET_KEY',
        ]);
        for (const secret of [environment.STRIPE_SANDBOX_RESTRICTED_KEY, environment.STAGING_PURCHASE_REFERENCE_SECRET]) {
          assert.ok(!(result.stdout + result.stderr).includes(secret));
          assert.ok(!readFileSync(resolve(directory, 'wrangler.log'), 'utf8').includes(secret));
        }
      }
    } finally {
      rmSync(directory, { recursive: true, force: true });
    }
  });
}
