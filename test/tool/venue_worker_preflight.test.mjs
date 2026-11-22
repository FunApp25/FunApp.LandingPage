import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';

const workflow = readFileSync(new URL(
  '../../.github/workflows/deploy-venue-interest-worker.yml', import.meta.url,
), 'utf8');
const preflightStep = workflow.split(
  '      - name: Validate production deployment configuration\n',
)[1]?.split('\n      - name:')[0];
const preflight = preflightStep?.split('        run: |\n')[1];
assert.ok(preflight, 'Expected the production preflight Bash block');

const guid = '01234567-89AB-cdef-0123-456789abcdef';

function runPreflight(overrides) {
  const result = spawnSync('bash', ['-c', preflight], {
    encoding: 'utf8',
    env: {
      HUBSPOT_PORTAL_ID: '123456789',
      HUBSPOT_FORM_GUID: guid,
      CLOUDFLARE_ACCOUNT_ID: 'fixture-account',
      CLOUDFLARE_API_TOKEN: 'fixture-token',
      ...overrides,
    },
  });
  assert.ifError(result.error);
  assert.equal(result.signal, null);
  return result;
}

for (const enabled of ['true', 'false']) {
  const config = {
    HERE_AND_NOW_SUBMISSIONS_ENABLED: enabled,
    ...(enabled === 'true' ? { HUBSPOT_HERE_AND_NOW_FORM_GUID: guid } : {}),
  };
  test(`valid Venue identifiers pass with Here & Now set to ${enabled}`, () => {
    const result = runPreflight(config);
    assert.equal(result.status, 0, result.stdout + result.stderr);
  });

  for (const [name, value] of [
    ['HUBSPOT_PORTAL_ID', '123x'],
    ['HUBSPOT_FORM_GUID', 'bad'],
  ]) {
    test(`rejects malformed ${name} with Here & Now set to ${enabled}`, () => {
      const result = runPreflight({ ...config, [name]: value });
      assert.equal(result.status, 1);
      assert.match(result.stdout, new RegExp(name));
    });
  }
}

test('validates the Here & Now GUID only when enabled', () => {
  const config = { HUBSPOT_HERE_AND_NOW_FORM_GUID: 'bad' };
  const enabled = runPreflight({ ...config, HERE_AND_NOW_SUBMISSIONS_ENABLED: 'true' });
  assert.equal(enabled.status, 1);
  assert.match(enabled.stdout, /HUBSPOT_HERE_AND_NOW_FORM_GUID/);
  const disabled = runPreflight({ ...config, HERE_AND_NOW_SUBMISSIONS_ENABLED: 'false' });
  assert.equal(disabled.status, 0, disabled.stdout + disabled.stderr);
});

test('rejects an unsupported Here & Now enablement value', () => {
  const result = runPreflight({ HERE_AND_NOW_SUBMISSIONS_ENABLED: 'yes' });
  assert.equal(result.status, 1);
  assert.match(result.stdout, /HERE_AND_NOW_SUBMISSIONS_ENABLED/);
});
