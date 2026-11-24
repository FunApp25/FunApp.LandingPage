import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

import { invalidProductionPaymentBinding } from '../cloudflare/founding-friend-payment-worker/src/production-config.ts';

const registration = 'venue-interest-worker';
const payment = 'founding-friend-payment-worker';
const targets = {
  [registration]: {
    name: 'funapp-venue-interest',
    binding: 'REGISTRATION_RATE_LIMITER',
    namespace: '1001',
    flags: {
      HERE_AND_NOW_SUBMISSIONS_ENABLED: 'AUTHORIZE_HERE_AND_NOW_SUBMISSIONS',
      FOUNDING_FRIEND_SUBMISSIONS_ENABLED: 'AUTHORIZE_FOUNDING_FRIEND_SUBMISSIONS',
    },
  },
  [payment]: {
    name: 'funapp-founding-friend-payment',
    binding: 'PAYMENT_RATE_LIMITER',
    namespace: '1002',
    flags: { PAYMENT_CREATION_ENABLED: 'AUTHORIZE_PAYMENT_CREATION' },
  },
};
const guid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function projectDirectory(project) {
  if (!Object.hasOwn(targets, project)) throw new Error('Unknown production Worker project');
  return fileURLToPath(new URL(`../cloudflare/${project}/`, import.meta.url));
}

export function readProductionWorkerConfig(project) {
  const config = resolve(projectDirectory(project), 'wrangler.jsonc');
  const require = createRequire(config);
  return require('wrangler').unstable_readConfig({ config, env: '' });
}

export function checkProductionWorker(project, config, env) {
  const main = resolve(projectDirectory(project), 'src/index.ts');
  const target = targets[project];
  if (
    config.name !== target.name || config.main !== main || config.account_id !== undefined ||
    config.workers_dev !== false || config.preview_urls !== false ||
    config.route !== undefined || config.routes !== undefined
  ) {
    throw new Error('Invalid production Worker identity, entrypoint, or routing configuration');
  }
  const limiter = config.ratelimits?.find(({ name }) => name === target.binding);
  if (limiter?.namespace_id !== target.namespace ||
      limiter.simple?.limit !== 10 || limiter.simple?.period !== 60) {
    throw new Error(`Invalid production rate-limit binding: ${target.binding}`);
  }
  if (config.keep_vars !== true) {
    throw new Error('Production Worker must preserve existing dashboard variables');
  }
  const flags = Object.keys(target.flags);
  if (Object.entries(config.vars).some(([name, value]) => !flags.includes(name) || value !== 'false')) {
    throw new Error('Production Wrangler vars may only declare disabled activation defaults');
  }
  for (const name of ['CLOUDFLARE_ACCOUNT_ID', 'CLOUDFLARE_API_TOKEN']) {
    if (!env[name]?.trim()) throw new Error(`Missing production configuration: ${name}`);
  }
  for (const [flag, authorization] of Object.entries(target.flags)) {
    const value = env[flag] ?? 'false';
    if (value !== 'true' && value !== 'false') {
      throw new Error(`${flag} must be exactly true or false`);
    }
    if (value === 'true' && env[authorization] !== 'true') {
      throw new Error(`${flag}=true requires explicit dispatch authorization: ${authorization}`);
    }
  }
  if (project === payment) {
    const invalid = invalidProductionPaymentBinding(env);
    if (invalid !== null) throw new Error(`Invalid production payment configuration: ${invalid}`);
  } else {
    if (!/^\d+$/.test(env.HUBSPOT_PORTAL_ID ?? '')) {
      throw new Error('HUBSPOT_PORTAL_ID must be numeric');
    }
    if (!guid.test(env.HUBSPOT_FORM_GUID ?? '')) {
      throw new Error('HUBSPOT_FORM_GUID must be a valid HubSpot form GUID');
    }
    if (env.HERE_AND_NOW_SUBMISSIONS_ENABLED === 'true' &&
        !guid.test(env.HUBSPOT_HERE_AND_NOW_FORM_GUID ?? '')) {
      throw new Error('Here & Now activation requires a valid HUBSPOT_HERE_AND_NOW_FORM_GUID');
    }
    if (env.FOUNDING_FRIEND_SUBMISSIONS_ENABLED === 'true') {
      const form = env.HUBSPOT_FOUNDING_FRIEND_FORM_GUID?.toLowerCase();
      if (!guid.test(form ?? '') ||
          form === env.HUBSPOT_FORM_GUID.toLowerCase() ||
          form === env.HUBSPOT_HERE_AND_NOW_FORM_GUID?.toLowerCase()) {
        throw new Error('Founding Friend activation requires a distinct valid HUBSPOT_FOUNDING_FRIEND_FORM_GUID');
      }
    }
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    const project = process.argv[2];
    checkProductionWorker(project, readProductionWorkerConfig(project), process.env);
  } catch (error) {
    console.error(`::error::${error.message}`);
    process.exitCode = 1;
  }
}
