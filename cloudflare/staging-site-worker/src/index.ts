export interface AssetsBinding {
  fetch(request: Request): Promise<Response>;
}

export interface Env {
  ASSETS: AssetsBinding;
}

const noIndex = 'noindex, nofollow, noarchive';

export async function handleRequest(
  request: Request,
  env: Env,
): Promise<Response> {
  const pathname = new URL(request.url).pathname;

  if (pathname === '/api' || pathname.startsWith('/api/')) {
    return new Response(null, {
      status: 404,
      headers: {
        'Cache-Control': 'no-store',
        'X-Robots-Tag': noIndex,
      },
    });
  } else {
    return env.ASSETS.fetch(request);
  }
}

export default {
  fetch: handleRequest,
};
