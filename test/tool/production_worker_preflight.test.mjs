import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { before, describe, it } from 'node:test';

import {
  checkProductionWorker,
  readProductionWorkerConfig,
  preflightProductionRelease,
} from '../../tool/check_production_worker.mjs';
import { deployProductionWorkers } from '../../tool/deploy_production_workers.mjs';

const cloudflare = {
  CLOUDFLARE_ACCOUNT_ID: 'fixture-account',
  CLOUDFLARE_API_TOKEN: 'fixture-token',
};
const mainPush = {
  GITHUB_REF: 'refs/heads/main',
  GITHUB_EVENT_NAME: 'push',
  GITHUB_SHA: 'a'.repeat(40),
};
const venue = {
  ...cloudflare,
  ...mainPush,
  HUBSPOT_PORTAL_ID: '123456789',
  HUBSPOT_VENUE_FORM_GUID: '01234567-89ab-cdef-0123-456789abcdef',
  HERE_AND_NOW_SUBMISSIONS_ENABLED: 'false',
  FOUNDING_FRIEND_SUBMISSIONS_ENABLED: 'false',
};
const hereAndNowGuid = '11111111-1111-1111-1111-111111111111';
const foundingFriendGuid = '22222222-2222-2222-2222-222222222222';
const payment = {
  ...cloudflare,
  ...mainPush,
  PAYMENT_CREATION_ENABLED: 'false',
  STRIPE_PRICE_ID: 'price_fixture249',
  STRIPE_EXPECTED_LIVEMODE: 'true',
  STRIPE_AUTOMATIC_TAX_ENABLED: 'false',
  PUBLIC_APP_ORIGIN: 'https://funapp.world',
  STRIPE_SECRET_KEY: ['rk', 'live', 'SyntheticRestrictedKeyForReleaseTests'].join('_'),
  PURCHASE_REFERENCE_SECRET: 'synthetic-purchase-reference-secret-for-tests',
};

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
      assert.equal(config.name, project === 'venue-interest-worker'
        ? 'funapp-registration-forms' : 'funapp-founding-friend-payment');
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
              GITHUB_EVENT_NAME: 'workflow_dispatch',
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

      it('requires a valid form for each enabled registration on a main push', () => {
        for (const [prefix, form] of [
          ['HERE_AND_NOW', 'HUBSPOT_HERE_AND_NOW_FORM_GUID'],
          ['FOUNDING_FRIEND', 'HUBSPOT_FOUNDING_FRIEND_FORM_GUID'],
        ]) {
          const flag = `${prefix}_SUBMISSIONS_ENABLED`;
          for (const guid of [undefined, 'invalid']) {
            assert.throws(() => check({ ...venue, [flag]: 'true', [form]: guid }), new RegExp(form));
          }
        }
        assert.throws(() => check({
          ...venue,
          FOUNDING_FRIEND_SUBMISSIONS_ENABLED: 'true',
          HUBSPOT_FOUNDING_FRIEND_FORM_GUID: venue.HUBSPOT_VENUE_FORM_GUID.toUpperCase(),
        }), /distinct valid HUBSPOT_FOUNDING_FRIEND_FORM_GUID/);
        assert.throws(() => check({ ...venue, HUBSPOT_PORTAL_ID: '123x' }), /HUBSPOT_PORTAL_ID/);
        assert.throws(() => check({ ...venue, HUBSPOT_VENUE_FORM_GUID: 'not-a-guid' }), /HUBSPOT_VENUE_FORM_GUID/);
      });

      it('requires the canonical Venue form and checks the optional GitHub legacy value', () => {
        check({ ...venue, HUBSPOT_FORM_GUID: venue.HUBSPOT_VENUE_FORM_GUID.toUpperCase() });
        assert.throws(() => check({ ...venue, HUBSPOT_FORM_GUID: hereAndNowGuid }), /conflicts/);
        assert.throws(() => check({
          ...venue, HUBSPOT_VENUE_FORM_GUID: '', HUBSPOT_FORM_GUID: venue.HUBSPOT_VENUE_FORM_GUID,
        }), /HUBSPOT_VENUE_FORM_GUID/);
      });
    } else {
      it('rejects misconfigured Stripe bindings even while creation is disabled', () => {
        for (const [name, value] of [
          ['STRIPE_EXPECTED_LIVEMODE', 'false'],
          ['STRIPE_SECRET_KEY', 'rk_test_fixture'],
          ['STRIPE_SECRET_KEY', ['sk', 'live', 'SyntheticKey'].join('_')],
          ['STRIPE_PRICE_ID', 'prod_fixture'],
          ['STRIPE_AUTOMATIC_TAX_ENABLED', ''],
          ['STRIPE_AUTOMATIC_TAX_ENABLED', 'true'],
          ['PUBLIC_APP_ORIGIN', 'https://staging.funapp.world'],
          ['PURCHASE_REFERENCE_SECRET', ' '],
          ['PURCHASE_REFERENCE_SECRET', undefined],
          ['PURCHASE_REFERENCE_SECRET', payment.STRIPE_SECRET_KEY],
        ]) {
          assert.throws(() => check({ ...payment, [name]: value }), new RegExp(name));
        }
      });

    }
  });
}

const releaseEnv = { ...venue, ...payment };
const allEnabled = {
  ...releaseEnv,
  HERE_AND_NOW_SUBMISSIONS_ENABLED: 'true',
  FOUNDING_FRIEND_SUBMISSIONS_ENABLED: 'true',
  PAYMENT_CREATION_ENABLED: 'true',
  HUBSPOT_HERE_AND_NOW_FORM_GUID: hereAndNowGuid,
  HUBSPOT_FOUNDING_FRIEND_FORM_GUID: foundingFriendGuid,
};
const dispatchAuthorizations = {
  AUTHORIZE_HERE_AND_NOW_SUBMISSIONS: 'true',
  AUTHORIZE_FOUNDING_FRIEND_SUBMISSIONS: 'true',
  AUTHORIZE_PAYMENT_CREATION: 'true',
};
const workerNames = {
  'venue-interest-worker': 'funapp-registration-forms',
  'founding-friend-payment-worker': 'funapp-founding-friend-payment',
};
const activePrice = {
  object: 'price', id: payment.STRIPE_PRICE_ID, active: true, currency: 'gbp',
  livemode: true, type: 'one_time', unit_amount: 24_900,
  billing_scheme: 'per_unit', tax_behavior: 'inclusive',
};

function providerFixture({ missing, price = activePrice, legacy = venue.HUBSPOT_VENUE_FORM_GUID,
  binding, publicPreview = false } = {}) {
  return async (url, options) => {
    assert.equal(options.method, 'GET');
    assert.equal(options.redirect, 'error');
    assert.ok(options.signal);
    if (url === `https://api.stripe.com/v1/prices/${payment.STRIPE_PRICE_ID}`) {
      assert.equal(options.headers.Authorization, `Bearer ${payment.STRIPE_SECRET_KEY}`);
      assert.equal(options.headers['Stripe-Version'], '2026-08-26.dahlia');
      return Response.json(price);
    }
    assert.equal(options.headers.Authorization, `Bearer ${cloudflare.CLOUDFLARE_API_TOKEN}`);
    const path = url.replace(
      `https://api.cloudflare.com/client/v4/accounts/${cloudflare.CLOUDFLARE_ACCOUNT_ID}/workers/`, '',
    );
    for (const name of Object.values(workerNames)) {
      if (path === `services/${name}`) {
        return name === missing ? new Response(null, { status: 404 }) : Response.json({
          success: true, result: { id: name, default_environment: { script: { tag: `tag-${name}` } } },
        });
      }
      if (path === `scripts/${name}/settings`) {
        const bindings = name === workerNames['venue-interest-worker']
          ? [{ name: 'HUBSPOT_FORM_GUID', type: 'plain_text', text: legacy }] : [];
        if (binding) bindings.push(binding);
        return Response.json({ success: true, result: { bindings } });
      }
      if (path === `workers/${name}`) {
        return Response.json({ success: true, result: {
          subdomain: { enabled: false, previews_enabled: publicPreview },
        } });
      }
    }
    assert.fail('Unexpected preflight request');
  };
}

function mockWrangler(calls, release, failAt) {
  return (project, args, env) => {
    calls.push([project, args.slice(0, 2).join(' ')]);
    if (calls.length === failAt) throw new Error('Simulated Wrangler failure');
    const name = workerNames[project];
    assert.equal(env.CLOUDFLARE_API_TOKEN, cloudflare.CLOUDFLARE_API_TOKEN);
    assert.ok(!env.STRIPE_SECRET_KEY && !env.PURCHASE_REFERENCE_SECRET);
    assert.ok(!env.CLOUDFLARE_WORKERS_API_TOKEN && !env.CLOUDFLARE_STAGING_SITE_API_TOKEN);
    assert.ok(args.includes(`Release ${release.GITHUB_SHA}`));
    assert.ok(!args.some((arg) => /route|trigger|staging/.test(arg)));
    const id = project === 'venue-interest-worker'
      ? '11111111-1111-4111-8111-111111111111' : '22222222-2222-4222-8222-222222222222';
    let receipt;
    if (args[1] === 'upload') {
      const tag = `tag-${name}`;
      const vars = args.filter((_, index) => args[index - 1] === '--var');
      assert.equal(env.WRANGLER_CI_MATCH_TAG, tag);
      if (project === 'venue-interest-worker') {
        const expected = [
          `HERE_AND_NOW_SUBMISSIONS_ENABLED:${release.HERE_AND_NOW_SUBMISSIONS_ENABLED}`,
          `FOUNDING_FRIEND_SUBMISSIONS_ENABLED:${release.FOUNDING_FRIEND_SUBMISSIONS_ENABLED}`,
          `HUBSPOT_PORTAL_ID:${venue.HUBSPOT_PORTAL_ID}`,
          `HUBSPOT_VENUE_FORM_GUID:${venue.HUBSPOT_VENUE_FORM_GUID}`,
        ];
        if (release.HERE_AND_NOW_SUBMISSIONS_ENABLED === 'true') {
          expected.push(`HUBSPOT_HERE_AND_NOW_FORM_GUID:${hereAndNowGuid}`);
        }
        if (release.FOUNDING_FRIEND_SUBMISSIONS_ENABLED === 'true') {
          expected.push(`HUBSPOT_FOUNDING_FRIEND_FORM_GUID:${foundingFriendGuid}`);
        }
        assert.deepEqual(vars, expected);
        assert.ok(!args.includes('--secrets-file'));
      } else {
        const file = args[args.indexOf('--secrets-file') + 1];
        assert.equal(statSync(file).mode & 0o777, 0o600);
        assert.deepEqual(JSON.parse(readFileSync(file, 'utf8')), {
          STRIPE_SECRET_KEY: payment.STRIPE_SECRET_KEY,
          PURCHASE_REFERENCE_SECRET: payment.PURCHASE_REFERENCE_SECRET,
        });
        assert.deepEqual(vars, [
          `PAYMENT_CREATION_ENABLED:${release.PAYMENT_CREATION_ENABLED}`,
          `STRIPE_PRICE_ID:${payment.STRIPE_PRICE_ID}`,
          'STRIPE_EXPECTED_LIVEMODE:true',
          'STRIPE_AUTOMATIC_TAX_ENABLED:false',
          `PUBLIC_APP_ORIGIN:${payment.PUBLIC_APP_ORIGIN}`,
        ]);
      }
      receipt = { type: 'version-upload', worker_name: name, worker_tag: tag, version_id: id };
    } else {
      assert.deepEqual(args.slice(0, 4), ['versions', 'deploy', `${id}@100%`, '--yes']);
      receipt = { type: 'version-deploy', worker_name: name, deployment_id: `deployment-${name}` };
    }
    writeFileSync(env.WRANGLER_OUTPUT_FILE_PATH, JSON.stringify(receipt));
  };
}

describe('production release', () => {
  it('requires both existing Worker identities and checks the deployed Venue alias and live Price', async () => {
    await preflightProductionRelease(allEnabled, providerFixture());
    await assert.rejects(preflightProductionRelease(allEnabled, providerFixture({
      missing: workerNames['founding-friend-payment-worker'],
    })), /verify existing production Worker/);
    await assert.rejects(preflightProductionRelease(allEnabled, providerFixture({ legacy: hereAndNowGuid })),
      /HUBSPOT_FORM_GUID conflicts/);
    await assert.rejects(preflightProductionRelease(allEnabled, providerFixture({ publicPreview: true })),
      /public subdomain/);
    await assert.rejects(preflightProductionRelease(allEnabled, providerFixture({
      binding: { name: 'HUBSPOT_VENUE_FORM_GUID', type: 'secret_text' },
    })), /binding type conflict/);
    await assert.rejects(preflightProductionRelease({
      ...releaseEnv,
      GITHUB_EVENT_NAME: 'workflow_dispatch',
      FOUNDING_FRIEND_SUBMISSIONS_ENABLED: 'true',
      AUTHORIZE_FOUNDING_FRIEND_SUBMISSIONS: 'true',
      HUBSPOT_FOUNDING_FRIEND_FORM_GUID: foundingFriendGuid,
    }, providerFixture({
      binding: { name: 'HUBSPOT_HERE_AND_NOW_FORM_GUID', type: 'plain_text', text: foundingFriendGuid },
    })), /retained Here & Now form/);
    for (const override of [{ livemode: false }, { active: false }, { unit_amount: 100 }, { tax_behavior: 'exclusive' }]) {
      await assert.rejects(preflightProductionRelease(allEnabled, providerFixture({
        price: { ...activePrice, ...override },
      })), /Production STRIPE_PRICE_ID/);
    }
  });

  it('requires every flag to be explicitly true or false before provider I/O', async () => {
    for (const flag of ['HERE_AND_NOW_SUBMISSIONS_ENABLED', 'FOUNDING_FRIEND_SUBMISSIONS_ENABLED', 'PAYMENT_CREATION_ENABLED']) {
      for (const value of [undefined, '', 'True', ' true']) {
        await assert.rejects(preflightProductionRelease({ ...allEnabled, [flag]: value },
          () => assert.fail('Provider I/O with invalid activation flag')), new RegExp(`${flag} must be exactly true or false`));
      }
    }
  });

  it('requires matching manual authorization for each enabled capability', async () => {
    const dispatch = { ...allEnabled, ...dispatchAuthorizations, GITHUB_EVENT_NAME: 'workflow_dispatch' };
    await preflightProductionRelease(dispatch, providerFixture());
    for (const authorization of Object.keys(dispatchAuthorizations)) {
      for (const value of [undefined, 'false']) {
        await assert.rejects(preflightProductionRelease({ ...dispatch, [authorization]: value },
          () => assert.fail('Provider I/O before manual authorization')),
        new RegExp(`requires explicit dispatch authorization: ${authorization}`));
      }
    }
    await preflightProductionRelease({ ...releaseEnv, GITHUB_EVENT_NAME: 'workflow_dispatch' }, providerFixture());
  });

  it('rejects missing production credentials before provider I/O on an enabled push', async () => {
    await assert.rejects(preflightProductionRelease({
      ...allEnabled, CLOUDFLARE_API_TOKEN: '', CLOUDFLARE_WORKERS_API_TOKEN: 'sandbox-token',
    }, () => assert.fail('Provider I/O with missing production token')), /CLOUDFLARE_API_TOKEN/);
    await assert.rejects(preflightProductionRelease({
      ...allEnabled, STRIPE_SECRET_KEY: 'rk_test_fixture',
    }, () => assert.fail('Provider I/O with a sandbox key')), /STRIPE_SECRET_KEY/);
  });

  it('blocks PRs, staging events and invalid or stale revisions before provider I/O or upload', async () => {
    const options = {
      fetchMetadata: () => assert.fail('Unexpected provider I/O'),
      wrangler: () => assert.fail('Unexpected Worker change'),
      checkRevision: () => {},
    };
    for (const event of ['pull_request', 'pull_request_target', 'workflow_call', undefined]) {
      await assert.rejects(deployProductionWorkers({
        ...allEnabled, ...dispatchAuthorizations, GITHUB_EVENT_NAME: event,
      }, options), /requires a main push or workflow dispatch/);
    }
    for (const override of [
      { GITHUB_REF: 'refs/heads/dev' },
      { GITHUB_REF: 'refs/heads/dev', GITHUB_EVENT_NAME: 'workflow_dispatch' },
      { GITHUB_REF: 'refs/pull/42/merge', GITHUB_EVENT_NAME: 'pull_request' },
      { GITHUB_SHA: 'invalid' },
    ]) {
      await assert.rejects(deployProductionWorkers({ ...allEnabled, ...override }, options), /requires a main revision/);
    }
    await assert.rejects(deployProductionWorkers(allEnabled, {
      ...options,
      checkRevision: () => { throw new Error('Stale revision'); },
    }), /Stale revision/);
  });

  it('deploys the exact configured state for every activation combination on a current main push', async (t) => {
    const base = mkdtempSync(join(tmpdir(), 'production-release-test-'));
    t.after(() => rmSync(base, { recursive: true, force: true }));
    for (const mask of [0, 1, 2, 3, 4, 5, 6, 7]) {
      const release = {
        ...allEnabled,
        HERE_AND_NOW_SUBMISSIONS_ENABLED: String(Boolean(mask & 1)),
        FOUNDING_FRIEND_SUBMISSIONS_ENABLED: String(Boolean(mask & 2)),
        PAYMENT_CREATION_ENABLED: String(Boolean(mask & 4)),
        RUNNER_TEMP: base,
      };
      const calls = [];
      await deployProductionWorkers(release, {
        fetchMetadata: providerFixture(),
        wrangler: mockWrangler(calls, release),
        checkRevision: (sha) => assert.equal(sha, mainPush.GITHUB_SHA),
      });
      assert.equal(calls.length, 4);
    }
  });

  it('uploads both versions before switching traffic and stops on the first failure or stale revision', async (t) => {
    const base = mkdtempSync(join(tmpdir(), 'production-release-test-'));
    t.after(() => rmSync(base, { recursive: true, force: true }));
    const order = [
      ['venue-interest-worker', 'versions upload'],
      ['founding-friend-payment-worker', 'versions upload'],
      ['venue-interest-worker', 'versions deploy'],
      ['founding-friend-payment-worker', 'versions deploy'],
    ];
    for (const failAt of [undefined, 1, 2, 3, 4, 'stale']) {
      const calls = [];
      let revisionChecks = 0;
      const deploy = deployProductionWorkers({
        ...allEnabled, RUNNER_TEMP: base, CLOUDFLARE_WORKERS_API_TOKEN: 'sandbox-token',
        CLOUDFLARE_STAGING_SITE_API_TOKEN: 'site-token',
      }, {
        fetchMetadata: providerFixture(),
        wrangler: mockWrangler(calls, allEnabled, failAt),
        checkRevision: (sha) => {
          assert.equal(sha, releaseEnv.GITHUB_SHA);
          revisionChecks += 1;
          if (failAt === 'stale' && revisionChecks === 4) throw new Error('Stale revision');
        },
      });
      if (failAt) await assert.rejects(deploy, failAt === 'stale' ? /Stale revision/ : /Simulated Wrangler failure/);
      else await deploy;
      assert.deepEqual(calls, order.slice(0, failAt === 'stale' ? 2 : failAt));
      assert.deepEqual(readdirSync(base), []);
    }
  });
});
