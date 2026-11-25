import {
  handleRequest,
  type RateLimiter,
  type WorkerDependencies,
} from './index';

export interface StagingEnv {
  STAGING_REGISTRATION_MOCK_ENABLED?: string;
  REGISTRATION_RATE_LIMITER?: RateLimiter;
}

const stagingHostname = 'staging.funapp.world';
const stagingRegistrationPaths = new Set([
  '/api/registrations/here-and-now',
  '/api/registrations/founding-friend',
]);

/**
 * Handles only the isolated staging registration routes with a deterministic
 * no-I/O adapter. The production entrypoint never imports or selects this
 * adapter through request data or a production binding.
 */
export async function handleStagingRequest(
  request: Request,
  env: StagingEnv,
  dependencies: WorkerDependencies = {},
): Promise<Response> {
  const url = new URL(request.url);
  if (
    url.hostname !== stagingHostname ||
    !stagingRegistrationPaths.has(url.pathname)
  ) {
    return stagingErrorResponse(404, 'not_found');
  }

  const enabled = env.STAGING_REGISTRATION_MOCK_ENABLED;
  if (enabled === undefined || enabled.trim() === '' || enabled === 'false') {
    return stagingErrorResponse(503, 'service_unavailable');
  } else if (enabled !== 'true') {
    return stagingErrorResponse(500, 'unexpected');
  }

  return handleRequest(
    request,
    {
      REGISTRATION_SUBMISSIONS_ENABLED: 'true',
      REGISTRATION_RATE_LIMITER: env.REGISTRATION_RATE_LIMITER,
    },
    {
      ...dependencies,
      registrationProvider: 'staging_mock',
    },
  );
}

const worker = {
  fetch(request: Request, env: StagingEnv): Promise<Response> {
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
