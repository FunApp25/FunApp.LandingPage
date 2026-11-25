import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

import {
  invalidProductionPaymentBinding,
  matchesCheckoutPrice,
  stripeApiVersion,
} from '../cloudflare/founding-friend-payment-worker/src/production-config.ts';

const registration = 'venue-interest-worker';
const payment = 'founding-friend-payment-worker';
export const targets = {
  [registration]: {
    name: 'funapp-registration-forms',
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
const requireWrangler = createRequire(new URL('./staging-wrangler/package.json', import.meta.url));

function projectDirectory(project) {
  if (!Object.hasOwn(targets, project)) throw new Error('Unknown production Worker project');
  return fileURLToPath(new URL(`../cloudflare/${project}/`, import.meta.url));
}

export function readProductionWorkerConfig(project) {
  const config = resolve(projectDirectory(project), 'wrangler.jsonc');
  return requireWrangler('wrangler').unstable_readConfig({ config, env: '' });
}

export function checkProductionWorker(project, config, env) {
  const event = env.GITHUB_EVENT_NAME;
  if (env.GITHUB_REF !== 'refs/heads/main' || (event !== 'push' && event !== 'workflow_dispatch')) {
    throw new Error('Production preflight requires a main push or workflow dispatch');
  }
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
    const value = env[flag];
    if (value !== 'true' && value !== 'false') {
      throw new Error(`${flag} must be exactly true or false`);
    }
    if (event === 'workflow_dispatch' && value === 'true' && env[authorization] !== 'true') {
      throw new Error(`${flag}=true requires explicit dispatch authorization: ${authorization}`);
    }
  }
  if (project === payment) {
    const invalid = invalidProductionPaymentBinding(env);
    if (invalid !== null) throw new Error(`Invalid production payment configuration: ${invalid}`);
    if ([env.STRIPE_SECRET_KEY, env.CLOUDFLARE_API_TOKEN].includes(env.PURCHASE_REFERENCE_SECRET)) {
      throw new Error('PURCHASE_REFERENCE_SECRET must be independent of deployment and Stripe credentials');
    }
    if (env.STRIPE_AUTOMATIC_TAX_ENABLED !== 'false') {
      throw new Error('STRIPE_AUTOMATIC_TAX_ENABLED must be false for this release');
    }
  } else {
    if (!/^\d+$/.test(env.HUBSPOT_PORTAL_ID ?? '')) {
      throw new Error('HUBSPOT_PORTAL_ID must be numeric');
    }
    if (!guid.test(env.HUBSPOT_VENUE_FORM_GUID ?? '')) {
      throw new Error('HUBSPOT_VENUE_FORM_GUID must be a valid HubSpot form GUID');
    }
    checkLegacyVenueForm(env.HUBSPOT_VENUE_FORM_GUID, env.HUBSPOT_FORM_GUID || undefined);
    if (env.HERE_AND_NOW_SUBMISSIONS_ENABLED === 'true' &&
        !guid.test(env.HUBSPOT_HERE_AND_NOW_FORM_GUID ?? '')) {
      throw new Error('Here & Now activation requires a valid HUBSPOT_HERE_AND_NOW_FORM_GUID');
    }
    if (env.FOUNDING_FRIEND_SUBMISSIONS_ENABLED === 'true') {
      const form = env.HUBSPOT_FOUNDING_FRIEND_FORM_GUID?.toLowerCase();
      if (!guid.test(form ?? '') ||
          form === env.HUBSPOT_VENUE_FORM_GUID.toLowerCase() ||
          form === env.HUBSPOT_HERE_AND_NOW_FORM_GUID?.toLowerCase()) {
        throw new Error('Founding Friend activation requires a distinct valid HUBSPOT_FOUNDING_FRIEND_FORM_GUID');
      }
    }
  }
}

function checkLegacyVenueForm(canonical, legacy) {
  if (legacy !== undefined &&
      (typeof legacy !== 'string' || canonical.toLowerCase() !== legacy.toLowerCase())) {
    throw new Error('HUBSPOT_FORM_GUID conflicts with HUBSPOT_VENUE_FORM_GUID');
  }
}

export function productionVars(project, env) {
  const flags = Object.fromEntries(
    Object.keys(targets[project].flags).map((flag) => [flag, env[flag]]),
  );
  const keys = project === registration
    ? ['HUBSPOT_PORTAL_ID', 'HUBSPOT_VENUE_FORM_GUID']
    : ['STRIPE_PRICE_ID', 'STRIPE_EXPECTED_LIVEMODE', 'STRIPE_AUTOMATIC_TAX_ENABLED', 'PUBLIC_APP_ORIGIN'];
  if (flags.HERE_AND_NOW_SUBMISSIONS_ENABLED === 'true') keys.push('HUBSPOT_HERE_AND_NOW_FORM_GUID');
  if (flags.FOUNDING_FRIEND_SUBMISSIONS_ENABLED === 'true') keys.push('HUBSPOT_FOUNDING_FRIEND_FORM_GUID');
  return { ...flags, ...Object.fromEntries(keys.map((key) => [key, env[key]])) };
}

export async function preflightProductionRelease(env, fetchMetadata = fetch) {
  for (const project of Object.keys(targets)) {
    checkProductionWorker(project, readProductionWorkerConfig(project), env);
  }
  async function read(url, headers, failure) {
    try {
      const response = await fetchMetadata(url, {
        method: 'GET', headers, redirect: 'error', signal: AbortSignal.timeout(30_000),
      });
      if (response.ok) return await response.json();
    } catch {
      // Provider responses and request details can contain protected configuration.
    }
    throw new Error(failure);
  }
  const tags = {};
  const base = `https://api.cloudflare.com/client/v4/accounts/${encodeURIComponent(env.CLOUDFLARE_ACCOUNT_ID)}/workers`;
  const headers = { Authorization: `Bearer ${env.CLOUDFLARE_API_TOKEN}` };
  for (const [project, { name }] of Object.entries(targets)) {
    const failure = `Cannot verify existing production Worker or bindings: ${name}`;
    const readWorker = async (path) => {
      const body = await read(`${base}/${path}`, headers, failure);
      if (body?.success !== true || body.result == null) throw new Error(failure);
      return body.result;
    };
    const service = await readWorker(`services/${name}`);
    const tag = service.default_environment?.script?.tag;
    if (service.id !== name || typeof tag !== 'string' || !tag.trim()) {
      throw new Error(failure);
    }
    tags[project] = tag;
    const metadata = await readWorker(`workers/${name}`);
    if (metadata.subdomain?.enabled !== false || metadata.subdomain?.previews_enabled !== false) {
      throw new Error(`Unexpected public subdomain or previews for ${name}`);
    }
    const settings = await readWorker(`scripts/${name}/settings`);
    if (!Array.isArray(settings.bindings) ||
        settings.bindings.some((binding) => !binding?.name || !binding.type)) {
      throw new Error(failure);
    }
    const vars = productionVars(project, env);
    for (const binding of settings.bindings) {
      if ((Object.hasOwn(vars, binding.name) && binding.type !== 'plain_text') ||
          (project === payment &&
           ['STRIPE_SECRET_KEY', 'PURCHASE_REFERENCE_SECRET'].includes(binding.name) &&
           binding.type !== 'secret_text')) {
        throw new Error(`Deployed binding type conflict for ${name}`);
      }
      if (['LOCAL_DEVELOPMENT_ALLOWED_ORIGIN', 'HUBSPOT_MOCK_SCENARIO', 'STRIPE_MOCK_SCENARIO'].includes(binding.name)) {
        throw new Error(`Unexpected local mock binding for ${name}`);
      }
      if (project === registration && binding.name === 'HUBSPOT_FORM_GUID') {
        if (binding.type !== 'plain_text' || typeof binding.text !== 'string') {
          throw new Error('Cannot reconcile the deployed legacy HUBSPOT_FORM_GUID binding');
        }
        checkLegacyVenueForm(env.HUBSPOT_VENUE_FORM_GUID, binding.text);
      }
      if (project === registration && vars.FOUNDING_FRIEND_SUBMISSIONS_ENABLED === 'true' &&
          binding.name === 'HUBSPOT_HERE_AND_NOW_FORM_GUID' && !Object.hasOwn(vars, binding.name) &&
          (binding.type !== 'plain_text' || typeof binding.text !== 'string' ||
            binding.text.toLowerCase() === vars.HUBSPOT_FOUNDING_FRIEND_FORM_GUID.toLowerCase())) {
        throw new Error('Cannot verify that the Founding Friend form differs from the retained Here & Now form');
      }
    }
  }
  const price = await read(
    `https://api.stripe.com/v1/prices/${encodeURIComponent(env.STRIPE_PRICE_ID)}`,
    { Authorization: `Bearer ${env.STRIPE_SECRET_KEY}`, 'Stripe-Version': stripeApiVersion },
    'Cannot read the production Stripe Price with the restricted live key',
  );
  if (price === null || typeof price !== 'object' || !matchesCheckoutPrice(price, env.STRIPE_PRICE_ID, true)) {
    throw new Error('Production STRIPE_PRICE_ID must identify the active live £249 GBP one-time inclusive Price');
  }
  return tags;
}
