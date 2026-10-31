import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const worker = 'funapp-founding-friend-payment-staging';

export async function diagnoseStaging(env, fetchRequest = fetch, log = console.log) {
  const account = env.CLOUDFLARE_ACCOUNT_ID;
  const token = env.CLOUDFLARE_WORKERS_API_TOKEN;
  const record = (endpoint) => ({
    endpoint,
    http_status: null,
    cloudflare_error_codes: [],
    cf_ray: null,
  });
  if (!/^[a-f0-9]{32}$/i.test(account ?? '') || !token?.trim()) {
    log(JSON.stringify(record('service_metadata')));
    return false;
  }

  async function request(endpoint, path) {
    const output = record(endpoint);
    let body;
    let ok = false;
    try {
      const response = await fetchRequest(
        `https://api.cloudflare.com/client/v4/accounts/${account}${path}`,
        {
          method: 'GET',
          headers: { Authorization: `Bearer ${token}` },
          redirect: 'error',
          signal: AbortSignal.timeout(30_000),
        },
      );
      output.http_status = response.status;
      const ray = response.headers.get('cf-ray');
      if (/^[a-f0-9]{16}(?:-[a-z]{3})?$/i.test(ray ?? '')) output.cf_ray = ray;
      body = await response.json();
      if (Array.isArray(body?.errors)) {
        output.cloudflare_error_codes = body.errors
          .map((error) => error?.code)
          .filter((code) => Number.isSafeInteger(code) && code >= 0);
      }
      ok = response.ok && body?.success === true;
    } catch {
      // Provider payloads and exception messages may contain secrets; never log them.
    }
    log(JSON.stringify(output));
    return { ok, body };
  }

  const service = await request('service_metadata', `/workers/services/${worker}`);
  const environment = service.body?.result?.default_environment?.environment;
  if (!service.ok || typeof environment !== 'string' ||
      !/^[a-z0-9_-]{1,64}$/i.test(environment)) return false;

  const base = `/workers/services/${worker}/environments/${encodeURIComponent(environment)}`;
  const endpoints = [
    ['environment_bindings', `${base}/bindings`],
    ['environment_routes', `${base}/routes?show_zonename=true`],
    ['custom_domain_records', `/workers/domains/records?page=0&per_page=5&service=${worker}&environment=${encodeURIComponent(environment)}`],
    ['worker_subdomain', `${base}/subdomain`],
    ['worker_environment', base],
    ['worker_schedules', `/workers/scripts/${worker}/schedules`],
  ];
  let ok = true;
  for (const [endpoint, path] of endpoints) {
    const response = await request(endpoint, path);
    ok = response.ok && ok;
  }
  return ok;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    if (!await diagnoseStaging(process.env)) process.exitCode = 1;
  } catch {
    process.exitCode = 1;
  }
}
