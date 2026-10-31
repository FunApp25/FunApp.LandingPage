import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export const targets = {
  'staging-site-worker': 'funapp-landing-staging',
  'venue-interest-worker': 'funapp-venue-interest-staging',
  'founding-friend-payment-worker': 'funapp-founding-friend-payment-staging',
};

export function paymentConfiguration(env) {
  for (const name of [
    'CLOUDFLARE_ACCOUNT_ID',
    'CLOUDFLARE_STAGING_SITE_API_TOKEN',
    'CLOUDFLARE_WORKERS_API_TOKEN',
    'STAGING_PAYMENT_CREATION_ENABLED',
    'STRIPE_SANDBOX_PRICE_ID',
    'STRIPE_SANDBOX_AUTOMATIC_TAX_ENABLED',
    'STRIPE_SANDBOX_RESTRICTED_KEY',
    'STAGING_PURCHASE_REFERENCE_SECRET',
    'RUNNER_TEMP',
  ]) {
    if (!env[name]?.trim()) throw new Error(`Missing staging configuration: ${name}`);
  }
  if (!['true', 'false'].includes(env.STAGING_PAYMENT_CREATION_ENABLED)) {
    throw new Error('STAGING_PAYMENT_CREATION_ENABLED must be true or false');
  }
  if (!/^price_[A-Za-z0-9]+$/.test(env.STRIPE_SANDBOX_PRICE_ID)) {
    throw new Error('STRIPE_SANDBOX_PRICE_ID must be a Stripe Price ID');
  }
  if (env.STRIPE_SANDBOX_AUTOMATIC_TAX_ENABLED !== 'false') {
    throw new Error('STRIPE_SANDBOX_AUTOMATIC_TAX_ENABLED must remain false');
  }
  if (!/^rk_test_[A-Za-z0-9]+$/.test(env.STRIPE_SANDBOX_RESTRICTED_KEY)) {
    throw new Error('STRIPE_SANDBOX_RESTRICTED_KEY must be a sandbox restricted key');
  }
  if (env.STAGING_PURCHASE_REFERENCE_SECRET.length < 32) {
    throw new Error('STAGING_PURCHASE_REFERENCE_SECRET must contain at least 32 characters');
  }
  return {
    PAYMENT_CREATION_ENABLED: env.STAGING_PAYMENT_CREATION_ENABLED,
    STRIPE_PRICE_ID: env.STRIPE_SANDBOX_PRICE_ID,
    STRIPE_EXPECTED_LIVEMODE: 'false',
    STRIPE_AUTOMATIC_TAX_ENABLED: 'false',
    PUBLIC_APP_ORIGIN: 'https://staging.funapp.world',
  };
}

export function deploymentConfig(project, source, bindings, paymentVars) {
  if (!Object.hasOwn(targets, project)) throw new Error('Unknown staging project');
  const selected = project === 'staging-site-worker' ? source : source.env?.staging;
  if (selected?.name !== targets[project] || selected.route || selected.routes) {
    throw new Error(`Invalid staging identity or source-managed routes: ${project}`);
  }
  if (!Array.isArray(bindings) || bindings.some((b) => !b.name || !b.type)) {
    throw new Error(`Missing or invalid deployed binding metadata: ${project}`);
  }
  if (project !== 'staging-site-worker') {
    const name = project === 'venue-interest-worker'
      ? 'REGISTRATION_RATE_LIMITER' : 'PAYMENT_RATE_LIMITER';
    if (!bindings.some((b) => b.name === name && b.type === 'ratelimit')) {
      throw new Error(`Missing deployed staging rate limiter: ${project}`);
    }
  }
  const directory = resolve('cloudflare', project);
  return {
    name: selected.name,
    main: resolve(directory, selected.main),
    compatibility_date: selected.compatibility_date ?? source.compatibility_date,
    workers_dev: false,
    preview_urls: false,
    ...(selected.assets && {
      assets: { ...selected.assets, directory: resolve(directory, selected.assets.directory) },
    }),
    vars: project === 'founding-friend-payment-worker' ? paymentVars : {},
    // keep_vars alone does not retain dashboard rate limiters or other resource bindings.
    unsafe: {
      metadata: {
        keep_bindings: [...new Set([
          'plain_text', 'json', 'secret_text', 'secret_key',
          ...bindings.map((binding) => binding.type),
        ])],
      },
    },
  };
}

export async function prepareDeployment(env, fetchSettings = fetch) {
  const paymentVars = paymentConfiguration(env);
  const configurations = [];
  for (const [project, worker] of Object.entries(targets)) {
    const token = project === 'staging-site-worker'
      ? env.CLOUDFLARE_STAGING_SITE_API_TOKEN : env.CLOUDFLARE_WORKERS_API_TOKEN;
    const response = await fetchSettings(
      `https://api.cloudflare.com/client/v4/accounts/${encodeURIComponent(env.CLOUDFLARE_ACCOUNT_ID)}/workers/scripts/${worker}/settings`,
      { headers: { Authorization: `Bearer ${token}` }, signal: AbortSignal.timeout(30_000) },
    );
    if (!response.ok) throw new Error(`Cannot read existing staging Worker settings: ${worker}`);
    const body = await response.json();
    if (body.success !== true) throw new Error(`Cannot read existing staging Worker settings: ${worker}`);
    const source = JSON.parse(readFileSync(`cloudflare/${project}/wrangler.jsonc`, 'utf8')
      .replace(/^\s*\/\/.*$/gm, ''));
    configurations.push([project, deploymentConfig(project, source, body.result?.bindings, paymentVars)]);
  }
  // Finish every preflight before writing deployable configurations; no remote writes occur here.
  for (const [project, config] of configurations) {
    writeFileSync(resolve(env.RUNNER_TEMP, `${project}.json`), JSON.stringify(config), { mode: 0o600 });
  }
  writeFileSync(resolve(env.RUNNER_TEMP, 'staging-payment-secrets.json'), JSON.stringify({
    STRIPE_SECRET_KEY: env.STRIPE_SANDBOX_RESTRICTED_KEY,
    PURCHASE_REFERENCE_SECRET: env.STAGING_PURCHASE_REFERENCE_SECRET,
  }), { mode: 0o600 });
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    await prepareDeployment(process.env);
  } catch {
    // Do not print provider responses, environment values, or request details.
    console.error('Staging preflight failed. Check required environment configuration and Worker settings read access.');
    process.exitCode = 1;
  }
}
