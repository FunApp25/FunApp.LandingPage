import { afterEach, expect, vi } from 'vitest';

const externalFetch = vi.fn(() => {
  throw new Error('Tests must inject upstreamFetch; external requests are forbidden');
});
vi.stubGlobal('fetch', externalFetch);

afterEach(() => {
  expect(externalFetch).not.toHaveBeenCalled();
});
