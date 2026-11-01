import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { createServer } from 'node:http';
import { mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { test } from 'node:test';
import { cliPath, directory as toolDirectory, originalHash, patchedHash, verifyToolchain, version } from '../../tool/staging-wrangler/patch.mjs';

const root = fileURLToPath(new URL('../../', import.meta.url));
const wrapper = resolve(root, 'tool/staging-wrangler/wrangler.mjs');
const worker = 'funapp-founding-friend-payment-staging';
const account = '0123456789abcdef0123456789abcdef';
const versionId = '11111111-1111-4111-8111-111111111111';
const required = ['/bindings', '/subdomain', '/environments/production', '/schedules', '/deployments'];

// Exercise the installed CLI and its real preUploadApiChecks, not a copy of the fix.
// Every Cloudflare API request goes to this loopback server; unexpected requests fail.
async function runMockDeployment({ routes, failure, command = 'deploy', conflict = false, matchTag } = {}) {
  verifyToolchain();
  const directory = mkdtempSync(resolve(tmpdir(), 'staging-wrangler-'));
  const calls = [];
  const unexpected = [];
  const server = createServer(async (request, response) => {
    const path = new URL(request.url, 'http://localhost').pathname;
    const method = request.method;
    calls.push([method, request.url]);
    request.resume();
    let result;
    let status = 200;
    if ((failure && path.endsWith(failure)) || path.endsWith('/routes') || path.endsWith('/domains/records')) {
      status = 403;
    } else if (path === '/user/tokens/verify') {
      status = 403;
    } else if (method === 'GET' && path.endsWith(`/services/${worker}`)) {
      result = { id: worker, default_environment: { environment: 'production',
        script: { last_deployed_from: 'dash', tag: 'worker-tag', tags: [] } } };
    } else if (method === 'GET' && path.endsWith(`/workers/workers/${worker}`)) {
      result = { subdomain: { enabled: false, previews_enabled: false } };
    } else if (method === 'GET' && path.endsWith('/bindings')) {
      result = conflict ? [{ name: 'OLD_SETTING', type: 'plain_text', text: 'remote-value' }] : [];
    } else if (method === 'GET' && path.endsWith('/subdomain')) {
      result = { enabled: false, previews_enabled: false };
    } else if (method === 'GET' && path.endsWith('/environments/production')) {
      result = { script: { compatibility_date: '2026-10-21', compatibility_flags: [], tags: [] } };
    } else if (method === 'GET' && path.endsWith('/schedules')) {
      result = { schedules: [] };
    } else if (method === 'GET' && path.endsWith('/settings')) {
      result = { bindings: [] };
    } else if (method === 'GET' && path.endsWith('/secrets')) {
      result = [];
    } else if (method === 'GET' && path.endsWith('/deployments')) {
      result = { deployments: [] };
    } else if (method === 'POST' && path.endsWith('/versions')) {
      result = { id: versionId, resources: { script: { etag: 'test-etag' } }, metadata: { has_preview: false }, startup_time_ms: 1 };
    } else if (method === 'POST' && path.endsWith('/subdomain')) {
      result = { enabled: false, previews_enabled: false };
    } else if (method === 'POST' && path.endsWith('/deployments')) {
      result = { id: 'mock-deployment' };
    } else if (method === 'PATCH' && path.endsWith('/script-settings')) {
      result = {};
    } else {
      unexpected.push([method, request.url]);
      status = 400;
    }
    response.writeHead(status, { 'Content-Type': 'application/json' });
    response.end(JSON.stringify({ success: status === 200, result,
      errors: status === 200 ? [] : [{ code: 10000, message: 'Mock permission denied' }] }));
  });
  try {
    await new Promise((resolve, reject) => { server.once('error', reject); server.listen(0, '127.0.0.1', resolve); });
    writeFileSync(resolve(directory, 'index.js'), 'export default { fetch() { return new Response("mock"); } };');
    writeFileSync(resolve(directory, 'wrangler.json'), JSON.stringify({
      name: worker, main: 'index.js', compatibility_date: '2026-10-21',
      workers_dev: false, preview_urls: false, ...(routes && { routes }),
    }));
    const childEnv = Object.fromEntries(Object.entries(process.env)
      .filter(([name]) => !/^(CF_|CLOUDFLARE_|WRANGLER_|STRIPE_)/.test(name)));
    const output = await new Promise((resolveResult, reject) => {
      const child = spawn(process.execPath, [wrapper, ...command.split(' '), '--strict', '--env=',
        '--config', resolve(directory, 'wrangler.json')], {
        cwd: directory, env: {
          ...childEnv, CI: 'true', CLOUDFLARE_ACCOUNT_ID: account, CLOUDFLARE_API_TOKEN: 'mock-token',
          CLOUDFLARE_API_BASE_URL: `http://127.0.0.1:${server.address().port}`,
          CLOUDFLARE_LOAD_DEV_VARS_FROM_DOT_ENV: 'false', WRANGLER_SEND_METRICS: 'false',
          WRANGLER_LOG_SANITIZE: 'true', WRANGLER_LOG_PATH: resolve(directory, 'wrangler.log'),
          ...(matchTag && { WRANGLER_CI_MATCH_TAG: matchTag }),
        }, stdio: ['ignore', 'pipe', 'pipe'],
      });
      let stdout = '', stderr = '';
      child.stdout.on('data', (chunk) => { stdout += chunk; });
      child.stderr.on('data', (chunk) => { stderr += chunk; });
      child.on('error', reject);
      const timeout = setTimeout(() => { child.kill('SIGKILL'); reject(new Error('Mock CLI timed out')); }, 30_000);
      child.on('exit', (code) => { clearTimeout(timeout); resolveResult({ code, stdout, stderr }); });
    });
    assert.deepEqual(unexpected, [], output.stderr);
    return { ...output, calls };
  } finally {
    await new Promise((resolve) => server.close(resolve));
    rmSync(directory, { recursive: true, force: true });
  }
}

const published = (calls) => calls.some(([method, url]) => method === 'POST' && url.includes('/versions'));
const queried = (calls, suffix) => calls.some(([, url]) => new URL(url, 'http://localhost').pathname.endsWith(suffix));

test('dashboard Worker with denied route/domain endpoints deploys without querying them', async () => {
  const result = await runMockDeployment();
  assert.equal(result.code, 0, result.stderr + result.stdout);
  assert.ok(published(result.calls));
  assert.ok(result.calls.some(([method, url]) => method === 'POST' && url.endsWith('/deployments')));
  for (const suffix of required) assert.ok(queried(result.calls, suffix), suffix);
  assert.ok(!queried(result.calls, '/routes'));
  assert.ok(!queried(result.calls, '/domains/records'));
});

for (const [name, routes, suffix, absent] of [
  ['ordinary string route', ['example.invalid/*'], '/routes', '/domains/records'],
  ['ordinary object route', [{ pattern: 'example.invalid/*', zone_id: account }], '/routes', '/domains/records'],
  ['Custom Domain', [{ pattern: 'example.invalid', custom_domain: true }], '/domains/records', '/routes'],
]) {
  test(`${name}: required permission denial fails before publishing`, async () => {
    const result = await runMockDeployment({ routes });
    assert.notEqual(result.code, 0);
    assert.ok(queried(result.calls, suffix), result.stderr);
    assert.ok(!queried(result.calls, absent));
    assert.ok(!published(result.calls));
  });
}

for (const failure of required) {
  test(`required metadata ${failure} denial still fails before upload`, async () => {
    const result = await runMockDeployment({ failure });
    assert.notEqual(result.code, 0);
    assert.ok(queried(result.calls, failure));
    assert.ok(!published(result.calls));
  });
}

test('versions upload ignores configured routes without bypassing strict configuration comparisons', async () => {
  const result = await runMockDeployment({ command: 'versions upload', routes: ['example.invalid/*'] });
  assert.equal(result.code, 0, result.stderr + result.stdout);
  assert.ok(published(result.calls));
  assert.ok(!queried(result.calls, '/routes'));
  assert.ok(!queried(result.calls, '/domains/records'));
});

test('destructive dashboard diff and mismatched CI Worker identity remain blocked', async () => {
  for (const options of [{ conflict: true }, { matchTag: 'different-worker-tag' }]) {
    const result = await runMockDeployment(options);
    assert.notEqual(result.code, 0);
    assert.ok(!published(result.calls));
    assert.match(result.stderr + result.stdout, options.conflict ? /differs from the remote configuration/ : /must match/);
  }
});

test('exact staging tool identity is enforced on install and every invocation', () => {
  verifyToolchain();
  const manifest = JSON.parse(readFileSync(resolve(toolDirectory, 'package.json')));
  const lock = JSON.parse(readFileSync(resolve(toolDirectory, 'package-lock.json')));
  assert.equal(manifest.devDependencies.wrangler, version);
  assert.equal(lock.packages['node_modules/wrangler'].version, version);
  assert.match(lock.packages['node_modules/wrangler'].integrity, /^sha512-/);
  assert.throws(() => verifyToolchain(originalHash), /integrity mismatch/);
  const directory = mkdtempSync(resolve(tmpdir(), 'wrangler-integrity-'));
  try {
    const packageRoot = resolve(directory, 'node_modules/wrangler');
    mkdirSync(resolve(packageRoot, 'wrangler-dist'), { recursive: true });
    writeFileSync(resolve(packageRoot, 'package.json'), JSON.stringify({ version: '4.156.0' }));
    writeFileSync(resolve(packageRoot, 'wrangler-dist/cli.js'), readFileSync(cliPath));
    assert.throws(() => verifyToolchain(patchedHash, directory), /version or bundle integrity mismatch/);
    writeFileSync(resolve(packageRoot, 'package.json'), JSON.stringify({ version }));
    writeFileSync(resolve(packageRoot, 'wrangler-dist/cli.js'), 'incompatible bundle');
    assert.throws(() => verifyToolchain(patchedHash, directory), /integrity mismatch/);
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
  const installAgain = spawnSync(process.execPath, [resolve(toolDirectory, 'patch.mjs')], { encoding: 'utf8' });
  assert.notEqual(installAgain.status, 0);
  verifyToolchain();
});
