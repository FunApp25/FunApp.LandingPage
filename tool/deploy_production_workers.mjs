import { execFileSync, spawnSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { preflightProductionRelease, productionVars, targets } from './check_production_worker.mjs';

const wrapper = fileURLToPath(new URL('./staging-wrangler/wrangler.mjs', import.meta.url));
const versionId = /^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i;

function requireCurrentMain(sha) {
  const ref = 'refs/heads/main';
  let latest;
  try {
    latest = execFileSync('git', ['ls-remote', '--exit-code', 'origin', ref], {
      encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
  } catch {
    throw new Error('Cannot determine current main revision');
  }
  if (latest !== `${sha}\t${ref}`) throw new Error('Production revision has been superseded');
}

function runWrangler(project, args, env) {
  const result = spawnSync(process.execPath, [wrapper, ...args, '--env=', '--config', 'wrangler.jsonc'], {
    cwd: fileURLToPath(new URL(`../cloudflare/${project}/`, import.meta.url)),
    env,
    stdio: 'ignore',
  });
  if (result.status !== 0) throw new Error(`Wrangler ${args.slice(0, 2).join(' ')} failed for ${project}`);
}

function readReceipt(path, type, name) {
  try {
    const records = readFileSync(path, 'utf8').trim().split('\n').map((line) => JSON.parse(line));
    const record = records.find((entry) => entry.type === type && entry.worker_name === name);
    if (record) return record;
  } catch {
    // Wrangler receipts are local machine output, never included in workflow logs.
  }
  throw new Error(`Missing Wrangler ${type} receipt for ${name}`);
}

export async function deployProductionWorkers(env, {
  fetchMetadata = fetch,
  wrangler = runWrangler,
  checkRevision = requireCurrentMain,
} = {}) {
  const sha = env.GITHUB_SHA;
  if (env.GITHUB_REF !== 'refs/heads/main' || !/^[a-f0-9]{40}$/.test(sha ?? '')) {
    throw new Error('Production deployment requires a main revision');
  }
  checkRevision(sha);
  const tags = await preflightProductionRelease(env, fetchMetadata);
  const directory = mkdtempSync(resolve(env.RUNNER_TEMP, 'production-workers-'));
  const versions = [];
  try {
    const wranglerEnv = {
      PATH: env.PATH,
      HOME: env.HOME,
      CI: 'true',
      CLOUDFLARE_ACCOUNT_ID: env.CLOUDFLARE_ACCOUNT_ID,
      CLOUDFLARE_API_TOKEN: env.CLOUDFLARE_API_TOKEN,
      CLOUDFLARE_LOAD_DEV_VARS_FROM_DOT_ENV: 'false',
      WRANGLER_SEND_METRICS: 'false',
      WRANGLER_LOG_SANITIZE: 'true',
      WRANGLER_LOG_PATH: resolve(directory, 'wrangler.log'),
    };
    const message = `Release ${sha}`;
    for (const [project, { name }] of Object.entries(targets)) {
      const args = ['versions', 'upload', '--message', message];
      if (project === 'founding-friend-payment-worker') {
        const file = resolve(directory, 'payment-secrets.json');
        writeFileSync(file, JSON.stringify({
          STRIPE_SECRET_KEY: env.STRIPE_SECRET_KEY,
          PURCHASE_REFERENCE_SECRET: env.PURCHASE_REFERENCE_SECRET,
        }), { mode: 0o600 });
        args.push('--secrets-file', file);
      }
      for (const [key, value] of Object.entries(productionVars(project, env))) {
        args.push('--var', `${key}:${value}`);
      }
      const output = resolve(directory, `${project}-upload.jsonl`);
      checkRevision(sha);
      wrangler(project, args, {
        ...wranglerEnv,
        WRANGLER_CI_MATCH_TAG: tags[project],
        WRANGLER_OUTPUT_FILE_PATH: output,
      });
      const receipt = readReceipt(output, 'version-upload', name);
      if (receipt.worker_tag !== tags[project] || !versionId.test(receipt.version_id)) {
        throw new Error(`Invalid uploaded version for ${name}`);
      }
      console.log(`Uploaded ${name} version ${receipt.version_id}`);
      versions.push({ project, name, id: receipt.version_id });
    }
    for (const { project, name, id } of versions) {
      const output = resolve(directory, `${project}-deploy.jsonl`);
      checkRevision(sha);
      wrangler(project, ['versions', 'deploy', `${id}@100%`, '--yes', '--message', message], {
        ...wranglerEnv,
        WRANGLER_OUTPUT_FILE_PATH: output,
      });
      const receipt = readReceipt(output, 'version-deploy', name);
      if (typeof receipt.deployment_id !== 'string' || !receipt.deployment_id) {
        throw new Error(`Missing deployment confirmation for ${name}`);
      }
      console.log(`Deployed ${name} version ${id}`);
    }
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    await deployProductionWorkers(process.env);
  } catch (error) {
    console.error(`Production Worker release failed. ${error.message}`);
    process.exitCode = 1;
  }
}
