import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
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

test('preflight reads only the three existing staging identities with their own tokens', async () => {
  const directory = mkdtempSync(resolve(tmpdir(), 'staging-preflight-'));
  try {
    const calls = [];
    await prepareDeployment({ ...environment, RUNNER_TEMP: directory }, async (url, options) => {
      calls.push([url, options.headers.Authorization]);
      assert.equal(options.method, undefined);
      return Response.json({ success: true, result: { bindings: remoteBindings } });
    });
    assert.deepEqual(calls, Object.entries(targets).map(([project, name]) => [
      `https://api.cloudflare.com/client/v4/accounts/test-account/workers/scripts/${name}/settings`,
      project === 'staging-site-worker' ? 'Bearer site-token' : 'Bearer api-token',
    ]));
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
    rmSync(directory, { recursive: true });
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});

test('a missing Worker or unreadable settings leaves no deployable configurations', async () => {
  const directory = mkdtempSync(resolve(tmpdir(), 'staging-preflight-failure-'));
  try {
    let calls = 0;
    await assert.rejects(prepareDeployment({ ...environment, RUNNER_TEMP: directory }, async () => {
      calls++;
      return calls === 3 ? new Response(null, { status: 403 })
        : Response.json({ success: true, result: { bindings: remoteBindings } });
    }), /Cannot read existing staging Worker settings/);
    assert.deepEqual(readdirSync(directory), []);
    assert.throws(() => deploymentConfig('venue-interest-worker', sourceConfig('venue-interest-worker'), [], {}), /rate limiter/);
    assert.throws(() => deploymentConfig('staging-site-worker', { name: 'production' }, [], {}), /identity/);
    assert.throws(() => deploymentConfig('staging-site-worker', { ...sourceConfig('staging-site-worker'), routes: [] }, [], {}), /routes/);
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});

for (const project of process.env.WORKER_PROJECT ? [process.env.WORKER_PROJECT] : Object.keys(targets)) {
  test(`${project}: locked Wrangler emits binding preservation metadata without deploying`, () => {
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
        resolve('cloudflare', project, 'node_modules/wrangler/bin/wrangler.js'),
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
        'plain_text', 'json', 'secret_text', 'secret_key', 'ratelimit', 'kv_namespace',
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
