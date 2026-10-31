import {
  handleRequest,
  type Env,
  type WorkerDependencies,
} from './index';

const stagingHostname = 'staging.funapp.world';
const stagingOrigin = `https://${stagingHostname}`;
const stagingPaymentPaths = new Set([
  '/api/founding-friend-payments/checkout-sessions',
  '/api/founding-friend-payments/checkout-sessions/verify',
]);

/**
 * Pins the named staging Worker to the staging hostname and Stripe sandbox.
 * The shared payment contract remains unchanged for the production entrypoint.
 */
export async function handleStagingRequest(
  request: Request,
  env: Env,
  dependencies: WorkerDependencies = {},
): Promise<Response> {
  const url = new URL(request.url);
  if (
    url.hostname !== stagingHostname ||
    !stagingPaymentPaths.has(url.pathname)
  ) {
    return stagingErrorResponse(404, 'not_found');
  }

  const secretKey = env.STRIPE_SECRET_KEY;
  if (
    env.STRIPE_EXPECTED_LIVEMODE !== 'false' ||
    env.PUBLIC_APP_ORIGIN !== stagingOrigin ||
    (secretKey !== undefined && !/^rk_test_[A-Za-z0-9]+$/.test(secretKey))
  ) {
    return stagingErrorResponse(500, 'unexpected');
  }

  return handleRequest(request, env, dependencies);
}

const worker = {
  fetch(request: Request, env: Env): Promise<Response> {
    return handleStagingRequest(request, env);
  },
};

export default worker;

function stagingErrorResponse(status: number, code: string): Response {
  return Response.json(
    { error: { code, requestId: crypto.randomUUID() } },
    {
      status,
      headers: {
        'cache-control': 'no-store',
        'content-type': 'application/json; charset=utf-8',
      },
    },
  );
}
