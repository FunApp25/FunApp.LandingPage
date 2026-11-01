import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { readFileSync, renameSync, rmSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

// Backport of cloudflare/workers-sdk#16531 at this immutable source revision.
export const upstreamRevision = '416ed05ea788852c9c06784c370d77603ee10936';
export const version = '4.155.0';
export const originalHash = '5c0d5e62f06a95d1cde6edc88de9995cb70eacdca3cedc5ab48bc2fceb33e25c';
export const patchedHash = '45528569fd41a70fc821b4ac77a3c781167fe6a7a65fef653b9b08e103c14b72';
export const directory = fileURLToPath(new URL('.', import.meta.url));
export const cliPath = resolve(directory, 'node_modules/wrangler/wrangler-dist/cli.js');
const hash = (content) => createHash('sha256').update(content).digest('hex');

export function verifyToolchain(expectedHash = patchedHash, root = directory) {
  const installed = JSON.parse(readFileSync(resolve(root, 'node_modules/wrangler/package.json'), 'utf8'));
  const cli = readFileSync(resolve(root, 'node_modules/wrangler/wrangler-dist/cli.js'));
  if (installed.version !== version || hash(cli) !== expectedHash) {
    throw new Error('Staging Wrangler version or bundle integrity mismatch; reinstall the locked toolchain.');
  }
}

export function applyBackport() {
  verifyToolchain(originalHash);
  const output = `${cliPath}.patched`;
  try {
    const result = spawnSync('patch', ['--batch', '--fuzz=0', '--output', output, cliPath,
      resolve(directory, 'dashboard-routes.patch')], { encoding: 'utf8' });
    if (result.status !== 0 || hash(readFileSync(output)) !== patchedHash) {
      throw new Error('Staging Wrangler backport did not produce the expected bundle.');
    }
    renameSync(output, cliPath);
    verifyToolchain();
  } finally {
    rmSync(output, { force: true });
  }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  applyBackport();
}
