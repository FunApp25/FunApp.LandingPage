import { spawnSync } from 'node:child_process';
import { resolve } from 'node:path';
import { directory, verifyToolchain } from './patch.mjs';

verifyToolchain();
const result = spawnSync(process.execPath, [
  resolve(directory, 'node_modules/wrangler/bin/wrangler.js'),
  ...process.argv.slice(2),
], { stdio: 'inherit' });
process.exitCode = result.status ?? 1;
