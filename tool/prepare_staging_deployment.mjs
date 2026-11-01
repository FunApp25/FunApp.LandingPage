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
  } else if (!bindings.some((b) => b.name === 'ASSETS' && b.type === 'assets')) {
    throw new Error('Missing deployed staging assets binding');
  }
  if (project === 'venue-interest-worker' && !bindings.some((b) =>
    b.name === 'STAGING_REGISTRATION_MOCK_ENABLED' && b.type === 'plain_text' && b.text === 'true')) {
    throw new Error('Missing enabled staging registration mock binding');
  }
  if (project === 'founding-friend-payment-worker' &&
      !['STRIPE_SECRET_KEY', 'PURCHASE_REFERENCE_SECRET'].every((name) =>
        bindings.some((b) => b.name === name && b.type === 'secret_text'))) {
    throw new Error('Missing encrypted staging payment bindings');
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

export async function prepareDeployment(env, fetchMetadata = fetch) {
  const paymentVars = paymentConfiguration(env);
  const configurations = [];
  for (const [project, worker] of Object.entries(targets)) {
    const token = project === 'staging-site-worker'
      ? env.CLOUDFLARE_STAGING_SITE_API_TOKEN : env.CLOUDFLARE_WORKERS_API_TOKEN;
    async function read(path) {
      const response = await fetchMetadata(
        `https://api.cloudflare.com/client/v4/accounts/${encodeURIComponent(env.CLOUDFLARE_ACCOUNT_ID)}/workers/${path}`,
        { method: 'GET', headers: { Authorization: `Bearer ${token}` },
          redirect: 'error', signal: AbortSignal.timeout(30_000) },
      );
      if (!response.ok) throw new Error(`Cannot read required staging Worker metadata: ${project}`);
      const body = await response.json();
      if (body.success !== true || body.result == null) {
        throw new Error(`Invalid required staging Worker metadata: ${project}`);
      }
      return body.result;
    }
    const service = await read(`services/${worker}`);
    const internalEnvironment = service.default_environment?.environment;
    if (service.id !== worker || typeof internalEnvironment !== 'string' ||
        !/^[a-z0-9_-]{1,64}$/i.test(internalEnvironment) ||
        !service.default_environment?.script) {
      throw new Error(`Invalid existing staging Worker identity: ${project}`);
    }
    const base = `services/${worker}/environments/${encodeURIComponent(internalEnvironment)}`;
    // Mirror the fixed dashboard comparison, plus the reads made later by deploy.
    // Routes/domains are dashboard-owned and absent from generated configurations.
    const bindings = await read(`${base}/bindings`);
    const subdomain = await read(`${base}/subdomain`);
    const metadata = await read(base);
    const schedules = await read(`scripts/${worker}/schedules`);
    const settings = await read(`scripts/${worker}/settings`);
    const workerMetadata = await read(`workers/${worker}`);
    const deployments = await read(`scripts/${worker}/deployments`);
    if (typeof subdomain.enabled !== 'boolean' || typeof subdomain.previews_enabled !== 'boolean' ||
        !metadata.script || !Array.isArray(schedules.schedules) ||
        schedules.schedules.some((s) => typeof s?.cron !== 'string') ||
        !workerMetadata.subdomain || !Array.isArray(deployments.deployments) ||
        (deployments.deployments[0] && !Array.isArray(deployments.deployments[0].versions))) {
      throw new Error(`Invalid required staging Worker metadata: ${project}`);
    }
    const versions = deployments.deployments[0]?.versions ?? [];
    if (versions.length >= 2) {
      for (const version of versions) {
        if (!/^[a-f0-9-]{36}$/i.test(version.version_id ?? '')) {
          throw new Error('Invalid deployed staging version identity');
        }
        const deployedVersion = await read(`scripts/${worker}/versions/${version.version_id}`);
        if (deployedVersion.id !== version.version_id || typeof deployedVersion.metadata?.created_on !== 'string') {
          throw new Error('Invalid deployed staging version metadata');
        }
      }
    }
    const source = JSON.parse(readFileSync(`cloudflare/${project}/wrangler.jsonc`, 'utf8')
      .replace(/^\s*\/\/.*$/gm, ''));
    const config = deploymentConfig(project, source, bindings, paymentVars);
    deploymentConfig(project, source, settings.bindings, paymentVars);
    const bindingTypes = (items) => items.map((b) => `${b.name}:${b.type}`).sort();
    if (JSON.stringify(bindingTypes(bindings)) !== JSON.stringify(bindingTypes(settings.bindings))) {
      throw new Error('Staging bindings changed during preflight');
    }
    if (Object.keys(config.vars).length > 0) {
      const secrets = await read(`scripts/${worker}/secrets`);
      if (!Array.isArray(secrets) || secrets.some((s) => Object.hasOwn(config.vars, s.name))) {
        throw new Error('Staging variables would replace encrypted secrets');
      }
    }
    configurations.push([project, config]);
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
    console.error('Staging preflight failed. Check environment configuration, existing Worker identities/bindings, and required metadata read access.');
    process.exitCode = 1;
  }
}
