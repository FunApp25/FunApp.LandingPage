import {
  handleRequest,
  type CheckoutFailureDiagnostic,
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
  let invalidStage: CheckoutFailureDiagnostic['stage'] | null = null;
  if (env.STRIPE_EXPECTED_LIVEMODE !== 'false') {
    invalidStage = 'staging_livemode';
  } else if (env.PUBLIC_APP_ORIGIN !== stagingOrigin) {
    invalidStage = 'staging_origin';
  } else if (
    secretKey !== undefined &&
    !/^rk_test_[A-Za-z0-9]+$/.test(secretKey)
  ) {
    invalidStage = 'staging_stripe_key';
  }
  const reportFailure =
    url.pathname === '/api/founding-friend-payments/checkout-sessions'
      ? reportCheckoutFailure
      : undefined;
  if (invalidStage !== null) {
    const requestId = crypto.randomUUID();
    reportFailure?.({
      requestId,
      stage: invalidStage,
      category: 'configuration_invalid',
    });
    return stagingErrorResponse(500, 'unexpected', requestId);
  }

  return handleRequest(request, env, dependencies, reportFailure);
}

const worker = {
  fetch(request: Request, env: Env): Promise<Response> {
    return handleStagingRequest(request, env);
  },
};

export default worker;

function reportCheckoutFailure({
  requestId,
  stage,
  category,
}: CheckoutFailureDiagnostic): void {
  try {
    console.error(JSON.stringify({ requestId, stage, category }));
  } catch {
    // Diagnostics must not change the payment response if the logging sink fails.
  }
}

function stagingErrorResponse(
  status: number,
  code: string,
  requestId = crypto.randomUUID(),
): Response {
  return Response.json(
    { error: { code, requestId } },
    {
      status,
      headers: {
        'cache-control': 'no-store',
        'content-type': 'application/json; charset=utf-8',
      },
    },
  );
}
