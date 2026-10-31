import { describe, expect, it, vi } from 'vitest';

import {
  handleRequest,
  type AssetsBinding,
} from '../src/index';

describe('staging site Worker', () => {
  it.each(['/api', '/api/', '/api/unknown', '/api/missing/route'])(
    'fails closed for unmatched API path %s',
    async (path) => {
      const assets = assetsBinding();
      const response = await handleRequest(
        new Request(`https://staging.funapp.world${path}`),
        { ASSETS: assets.binding },
      );

      expect(response.status).toBe(404);
      expect(response.headers.get('cache-control')).toBe('no-store');
      expect(response.headers.get('x-robots-tag')).toBe(
        'noindex, nofollow, noarchive',
      );
      expect(assets.fetch).not.toHaveBeenCalled();
    },
  );

  it.each(['/', '/main.dart.js', '/venues', '/apiary'])(
    'delegates non-API path %s to Static Assets',
    async (path) => {
      const assets = assetsBinding();
      const request = new Request(`https://staging.funapp.world${path}`);
      const response = await handleRequest(request, {
        ASSETS: assets.binding,
      });

      expect(response.status).toBe(200);
      expect(await response.text()).toBe('asset response');
      expect(assets.fetch).toHaveBeenCalledOnce();
      expect(assets.fetch).toHaveBeenCalledWith(request);
    },
  );
});

function assetsBinding(): {
  binding: AssetsBinding;
  fetch: ReturnType<typeof vi.fn>;
} {
  const fetch = vi.fn(async () => new Response('asset response'));
  return {
    binding: { fetch },
    fetch,
  };
}
