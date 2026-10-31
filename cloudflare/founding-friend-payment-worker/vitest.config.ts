import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    setupFiles: ['./test/no-network.ts'],
    coverage: {
      provider: 'v8',
    },
  },
});
