import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { before, describe, it } from 'node:test';
import { fileURLToPath } from 'node:url';

import {
  checkProductionWorker,
  readProductionWorkerConfig,
} from '../../tool/check_production_worker.mjs';

const cloudflare = {
  CLOUDFLARE_ACCOUNT_ID: 'fixture-account',
  CLOUDFLARE_API_TOKEN: 'fixture-token',
};
const venue = {
  ...cloudflare,
  HUBSPOT_PORTAL_ID: '123456789',
  HUBSPOT_FORM_GUID: '01234567-89ab-cdef-0123-456789abcdef',
};
const hereAndNowGuid = '11111111-1111-1111-1111-111111111111';
const foundingFriendGuid = '22222222-2222-2222-2222-222222222222';
const payment = {
  ...cloudflare,
  STRIPE_PRICE_ID: 'price_fixture249',
  STRIPE_EXPECTED_LIVEMODE: 'true',
  STRIPE_AUTOMATIC_TAX_ENABLED: 'false',
  PUBLIC_APP_ORIGIN: 'https://funapp.world',
  STRIPE_SECRET_KEY: ['rk', 'live', 'SyntheticRestrictedKey'].join('_'),
  PURCHASE_REFERENCE_SECRET: 'synthetic-purchase-reference-secret-for-tests',
};

function runWorkflowDeployment(project, env) {
  const workflow = readFileSync(new URL(
    `../../.github/workflows/deploy-${project}.yml`, import.meta.url,
  ), 'utf8');
  assert.match(workflow, /workflow_dispatch:/);
  assert.match(workflow, /if: github.ref == 'refs\/heads\/main'/);
  assert.match(workflow, /environment: production/);
  const step = workflow.split('      - name: Preflight and deploy ')[1]
    ?.split('\n      - name:')[0];
  const script = step?.split('        run: |\n')[1];
  assert.ok(script, 'Expected the production preflight and deployment step');

  const temp = mkdtempSync(join(tmpdir(), 'production-worker-test-'));
  try {
    writeFileSync(join(temp, 'npx'), `#!/usr/bin/env node
      const fs = require('node:fs');
      const argv = process.argv.slice(2);
      const secrets = argv[argv.indexOf('--secrets-file') + 1];
      const report = { argv };
      if (argv.includes('--secrets-file')) {
        report.mode = fs.statSync(secrets).mode & 0o777;
        report.secretNames = Object.keys(JSON.parse(fs.readFileSync(secrets)));
        report.secretsUnset = report.secretNames.every((key) => !process.env[key]);
      }
      console.log(JSON.stringify(report));`, { mode: 0o700 });
    const result = spawnSync('bash', ['-c', script], {
      cwd: fileURLToPath(new URL(`../../cloudflare/${project}/`, import.meta.url)),
      encoding: 'utf8',
      env: {
        PATH: `${temp}:${process.env.PATH}`,
        RUNNER_TEMP: temp,
        ...env,
      },
    });
    assert.ifError(result.error);
    assert.equal(result.signal, null);
    assert.deepEqual(readdirSync(temp), ['npx'], 'temporary secrets file was cleaned up');
    return result;
  } finally {
    rmSync(temp, { force: true, recursive: true });
  }
}

for (const [project, baseEnv] of [
  ['venue-interest-worker', venue],
  ['founding-friend-payment-worker', payment],
]) {
  describe(project, () => {
    let config;
    before(() => { config = readProductionWorkerConfig(project); });
    const check = (env = baseEnv, override = {}) =>
      checkProductionWorker(project, { ...config, ...override }, env);

    it('accepts the checked-in production identity, bindings and disabled defaults', () => {
      check();
    });

    it('rejects staging identity, wrong entrypoint, public previews and source-managed routes', () => {
      for (const override of [
        { name: `${config.name}-staging` },
        { main: config.main.replace('index.ts', 'staging.ts') },
        { account_id: 'different-fixture-account' },
        { preview_urls: true },
        { workers_dev: true },
        { routes: ['funapp.world/*'] },
      ]) {
        assert.throws(() => check(baseEnv, override), /production Worker identity/);
      }
    });

    it('rejects missing production resource bindings or deployment credentials', () => {
      assert.throws(() => check(baseEnv, { ratelimits: [] }), /rate-limit binding/);
      assert.throws(() => check(baseEnv, { keep_vars: false }), /preserve existing dashboard variables/);
      assert.throws(() => check(baseEnv, {
        ratelimits: [{ ...config.ratelimits[0], namespace_id: '2001' }],
      }), /rate-limit binding/);
      assert.throws(() => check({ ...baseEnv, CLOUDFLARE_API_TOKEN: '' }), /CLOUDFLARE_API_TOKEN/);
      assert.throws(() => check({ ...baseEnv, CLOUDFLARE_ACCOUNT_ID: '' }), /CLOUDFLARE_ACCOUNT_ID/);
      assert.throws(() => check(baseEnv, { vars: { PAYMENT_CREATION_ENABLED: 'true' } }), /disabled activation defaults/);
    });

    if (project === 'venue-interest-worker') {
      for (const hereAndNow of ['false', 'true']) {
        for (const foundingFriend of ['false', 'true']) {
          it(`preflights Here & Now=${hereAndNow} and Founding Friend=${foundingFriend}`, () => {
            check({
              ...venue,
              HERE_AND_NOW_SUBMISSIONS_ENABLED: hereAndNow,
              FOUNDING_FRIEND_SUBMISSIONS_ENABLED: foundingFriend,
              AUTHORIZE_HERE_AND_NOW_SUBMISSIONS: hereAndNow,
              AUTHORIZE_FOUNDING_FRIEND_SUBMISSIONS: foundingFriend,
              HUBSPOT_HERE_AND_NOW_FORM_GUID: hereAndNow === 'true' ? hereAndNowGuid : 'ignored',
              HUBSPOT_FOUNDING_FRIEND_FORM_GUID: foundingFriend === 'true' ? foundingFriendGuid : 'ignored',
            });
          });
        }
      }

      it('requires separate authorization and a valid form for each enabled workflow', () => {
        for (const [prefix, form, valid] of [
          ['HERE_AND_NOW', 'HUBSPOT_HERE_AND_NOW_FORM_GUID', hereAndNowGuid],
          ['FOUNDING_FRIEND', 'HUBSPOT_FOUNDING_FRIEND_FORM_GUID', foundingFriendGuid],
        ]) {
          const flag = `${prefix}_SUBMISSIONS_ENABLED`;
          assert.throws(() => check({ ...venue, [flag]: 'TRUE' }), /exactly true or false/);
          assert.throws(() => check({ ...venue, [flag]: 'true', [form]: valid }), /explicit dispatch authorization/);
          const authorized = { ...venue, [flag]: 'true', [`AUTHORIZE_${prefix}_SUBMISSIONS`]: 'true' };
          for (const guid of [undefined, 'invalid']) {
            assert.throws(() => check({ ...authorized, [form]: guid }), new RegExp(form));
          }
        }
        assert.throws(() => check({
          ...venue,
          FOUNDING_FRIEND_SUBMISSIONS_ENABLED: 'true',
          AUTHORIZE_FOUNDING_FRIEND_SUBMISSIONS: 'true',
          HUBSPOT_FOUNDING_FRIEND_FORM_GUID: venue.HUBSPOT_FORM_GUID.toUpperCase(),
        }), /distinct valid HUBSPOT_FOUNDING_FRIEND_FORM_GUID/);
        assert.throws(() => check({ ...venue, HUBSPOT_PORTAL_ID: '123x' }), /HUBSPOT_PORTAL_ID/);
        assert.throws(() => check({ ...venue, HUBSPOT_FORM_GUID: 'not-a-guid' }), /HUBSPOT_FORM_GUID/);
      });

      it('passes the independent activation flags and only the enabled form to Wrangler', () => {
        const env = {
          ...venue,
          HERE_AND_NOW_SUBMISSIONS_ENABLED: 'false',
          FOUNDING_FRIEND_SUBMISSIONS_ENABLED: 'true',
          HUBSPOT_FOUNDING_FRIEND_FORM_GUID: foundingFriendGuid,
        };
        const denied = runWorkflowDeployment(project, env);
        assert.equal(denied.status, 1);
        assert.equal(denied.stdout, '');
        assert.match(denied.stderr, /explicit dispatch authorization/);
        const allowed = runWorkflowDeployment(project, { ...env, AUTHORIZE_FOUNDING_FRIEND_SUBMISSIONS: 'true' });
        assert.equal(allowed.status, 0, allowed.stderr);
        assert.deepEqual(JSON.parse(allowed.stdout).argv, [
          '--no-install', 'wrangler', 'deploy', '--env=', '--config', 'wrangler.jsonc',
          '--var', `HUBSPOT_PORTAL_ID:${venue.HUBSPOT_PORTAL_ID}`,
          '--var', `HUBSPOT_FORM_GUID:${venue.HUBSPOT_FORM_GUID}`,
          '--var', 'HERE_AND_NOW_SUBMISSIONS_ENABLED:false',
          '--var', 'FOUNDING_FRIEND_SUBMISSIONS_ENABLED:true',
          '--var', `HUBSPOT_FOUNDING_FRIEND_FORM_GUID:${foundingFriendGuid}`,
        ]);
      });
    } else {
      it('requires explicit authorization for true even with all Stripe bindings present', () => {
        const enabled = { ...payment, PAYMENT_CREATION_ENABLED: 'true' };
        assert.throws(() => check(enabled), /explicit dispatch authorization/);
        assert.throws(() => check({ ...payment, PAYMENT_CREATION_ENABLED: 'True' }), /exactly true or false/);
        check({ ...enabled, AUTHORIZE_PAYMENT_CREATION: 'true' });
      });

      it('rejects misconfigured Stripe bindings even while creation is disabled', () => {
        for (const [name, value] of [
          ['STRIPE_EXPECTED_LIVEMODE', 'false'],
          ['STRIPE_SECRET_KEY', 'rk_test_fixture'],
          ['STRIPE_SECRET_KEY', ['sk', 'live', 'SyntheticKey'].join('_')],
          ['STRIPE_PRICE_ID', 'prod_fixture'],
          ['STRIPE_AUTOMATIC_TAX_ENABLED', ''],
          ['PUBLIC_APP_ORIGIN', 'https://staging.funapp.world'],
          ['PURCHASE_REFERENCE_SECRET', ' '],
          ['PURCHASE_REFERENCE_SECRET', undefined],
        ]) {
          assert.throws(() => check({ ...payment, [name]: value }), new RegExp(name));
        }
      });

      it('passes disabled config and a protected secrets file in one Wrangler invocation', () => {
        const denied = runWorkflowDeployment(project, { ...payment, PAYMENT_CREATION_ENABLED: 'true' });
        assert.equal(denied.status, 1);
        assert.equal(denied.stdout, '');
        assert.match(denied.stderr, /explicit dispatch authorization/);
        const result = runWorkflowDeployment(project, { ...payment, PAYMENT_CREATION_ENABLED: 'false' });
        assert.equal(result.status, 0, result.stderr);
        const { argv, mode, secretNames, secretsUnset } = JSON.parse(result.stdout);
        assert.deepEqual(argv.slice(0, 7), [
          '--no-install', 'wrangler', 'deploy', '--env=', '--config', 'wrangler.jsonc', '--secrets-file',
        ]);
        assert.ok(argv.includes('PAYMENT_CREATION_ENABLED:false'));
        assert.ok(argv.includes('STRIPE_EXPECTED_LIVEMODE:true'));
        assert.equal(mode, 0o600);
        assert.deepEqual(secretNames, ['STRIPE_SECRET_KEY', 'PURCHASE_REFERENCE_SECRET']);
        assert.ok(secretsUnset);
        assert.ok(!result.stdout.includes(payment.STRIPE_SECRET_KEY));
        assert.ok(!result.stdout.includes(payment.PURCHASE_REFERENCE_SECRET));
      });
    }
  });
}
