# Fun App Landing Page

This repository owns the public Fun App website and landing page. The active
application is a Flutter Web-only project deployed through GitHub Pages.

## Where to start

- [`SPECIFICATIONS.md`](SPECIFICATIONS.md) is the authoritative source for
  product scope, technical decisions, open questions, and change policy.
- [`AGENTS.md`](AGENTS.md) tells coding agents how to work in this repository.
- `README.md` provides practical setup and contributor onboarding.

## Current repository state

- The active web-only Flutter package is `fun_app_landing_page`.
- All 13 surfaces in Figma `Landing Page - V1` now have a presentation-only
  Flutter implementation, including the Free, Here & Now, and Lifetime
  Membership cards and the Founding Friend explanation. The header remains
  fixed above the scrolling page, repeated header/footer navigation moves to
  the corresponding page sections, and the independently expandable FAQ
  supports its complete item surface. The localized header "Join the queue"
  CTA, Free Membership, Limited Offer queue CTA, Here & Now membership CTA,
  Lifetime Membership CTA, and Founding Friend CTA retain their approved labels
  and styling and navigate to the appropriate public form route. The
  `/#/here-and-now` and `/#/founding-friend` destinations use responsive
  branded forms with optional, unchecked marketing consent. Separate domain
  models, provider-neutral repository contracts, and application BLoCs own
  validation, pending, success, failure, duplicate prevention, and retry. The
  development can explicitly select the temporary direct HubSpot transport or
  a first-party local Worker transport backed by deterministic mocks. With no
  explicit development selection, and in every production composition, the
  repositories deliberately fail closed without network or persistence.
  Injected test repositories can confirm the existing Here & Now success
  presentation. After a confirmed Founding Friend registration, the separate
  payment workflow prepares a server-owned one-time Stripe-hosted Checkout for
  a £249 GBP base price, with Stripe Adaptive Pricing for localized payments.
  A payment return page shows confirmation and the purchase reference only
  after the payment Worker verifies the Checkout Session; it
  never claims that membership has been activated.
  The stable
  responsive presentation includes the mobile navigation menu, a mobile
  Research-statistics and Founding Friend carousels, restrained anchor/FAQ
  interaction motion, and
  one-time scroll accents only for Research Statistics, Membership pricing
  cards, Founding Friends, and Venue; the Hero and all other landing sections
  remain static. The first provider-neutral prospective-venue domain model and
  application form workflow now sit above one concrete provider-neutral
  repository. Dependency injection selects a deterministic development data
  source or the production first-party data source. Production submits
  provider-neutral venue leads through the same-origin, unauthenticated
  `/api/venue-interest` endpoint. The deployed Cloudflare Worker owns the
  HubSpot mapping behind that boundary; Flutter does not send HubSpot fields or
  identifiers. The Venue CTA navigates to the dedicated `/#/venues` page,
  whose responsive Figma-aligned shell contains the localized form backed by a
  fresh `VenueLeadFormBloc`. A confirmed submission replaces the form with the
  responsive full-page success presentation on the same route; refresh and
  re-entry create a fresh form lifecycle. Failures preserve the draft for
  retry. The success email and shared footer email open
  `mailto:info@funapp.world`. The
  form shows the approved informational privacy acknowledgement immediately
  before Send, provides an optional presentation-local checkbox, and links to
  the hosted Privacy Notice without adding a submitted consent field. The
  Privacy Notice is also discoverable through same-tab footer navigation at
  [https://funapp.world/#/privacy](https://funapp.world/#/privacy). The Venue
  form's inline Privacy Notice link remains a new-tab link so a draft is
  preserved.
  Its approved English legal copy lives in
  `assets/legal/privacy_notice.md`. Footers show only
  Privacy Policy. Terms, refunds/cancellations, Cookie Policy, and Cookie Banner
  remain inaccessible through navigation and direct routes. Their source
  documents remain unapproved and implement no consent behavior. Cookie Policy
  renders the self-contained cookie section directly
  from the approved Privacy Notice; approval of a standalone Cookie Policy and
  any real cookie-consent solution remain unresolved. The
  landing, form, success, Privacy, and legal-document shells share a
  viewport-aware scrolling layout: short content keeps the footer at the
  bottom of the viewport, while longer content and scaled text remain in the
  normal scroll flow without a fixed overlay. The
  Membership section is rendered between Connection and Limited Offer; its
  header and mobile-menu anchor is active. Payment creation and registration
  both remain disabled in production pending separate external setup and
  authorization.
- Reusable branding assets live under `assets/branding/`, with active widget
  paths centralized in project code. Figma assets consumed by implemented
  landing sections live under `assets/landing/`.
- Google Fonts typography remains implemented through `google_fonts`, but its
  required Manrope and Instrument Serif files are bundled under `assets/fonts/`.
  Runtime font fetching is disabled in the common bootstrap. When adding a
  family, weight, or style, add its correctly named official font file and OFL
  license asset, then keep the bootstrap license registration in sync.
- Flutter localization supports complete application-UI catalogs for English,
  Spanish, Welsh, and Belarusian, with English as the source and unsupported-
  locale fallback language. The canonical Privacy Notice legal document
  remains the approved English source pending separately approved legal
  translations.
- Dart analysis follows the main Fun App Flutter project's
  `very_good_analysis` policy.
- GitHub Pages builds Flutter directly through `subosito/flutter-action@v2`
  and deploys `build/web` to
  [https://funapp.world](https://funapp.world).
- Web-root static inputs, including `CNAME` and `robots.txt`, live under `web/`.

The previous Astro implementation is retained under `archive/astro_site/` only
as deprecated historical, design, and content reference. It is not built or
deployed, and production work must not be implemented there.

## Setup

Flutter and Dart commands use the named Puro environment `fun-app-landing`,
which tracks Flutter stable.

For a fresh checkout:

```bash
puro create fun-app-landing stable
puro use fun-app-landing
puro flutter pub get
puro flutter gen-l10n
puro flutter pub run build_runner build
```

Puro records the local selection in `.puro.json`. That file is excluded
locally rather than committed, so each fresh checkout must create or select the
environment.

VS Code and VSCodium users should also generate local editor SDK settings:

```bash
puro use fun-app-landing --vscode --no-intellij
```

Those machine-specific settings remain ignored.

## Run Flutter Web

```bash
puro flutter run -d chrome -t lib/main_dev.dart
```

Both entrypoints expose the Here & Now and Founding Friend forms. Their BLoCs
validate and attempt submission. Development remains fail-closed by default,
and does not load local HubSpot configuration. Copy `.env.example` to the
ignored local `.env`, then replace the four placeholder identifiers with the
approved portal and form identifiers. The Venue form identifier is retained
only as a local reference for configuring the Worker-specific `.dev.vars` file;
Flutter does not read it. The shared portal identifier and two registration
form identifiers configure only an explicitly configured temporary
direct-HubSpot development test:

```bash
cp .env.example .env
puro flutter run -d chrome -t lib/main_dev.dart \
  --dart-define-from-file=.env \
  --dart-define=FUN_APP_REGISTRATION_TRANSPORT=direct_hubspot
```

These are public form identifiers, not credentials. Do not put private HubSpot
access tokens or secrets in Dart defines or a Flutter Web bundle. The direct
transport sends no `legalConsentOptions`; independently verify each form's
required fields and legal-consent settings in HubSpot before any authorized
live test. Production registration submissions remain fail-closed even when
these defines are present. Consent and age-eligibility decisions remain open.
Draft legal routes remain restricted.

VS Code and VSCodium users can also launch either explicit Flutter entrypoint
on Chrome in debug mode through the committed configurations:

- **Fun App Landing — Development (Fake Repositories)** selects the
  deterministic local data source and does not load `.env`.
- **Fun App Landing — Development (Direct HubSpot)** loads `.env` for the two
  development-only registration workflows. This is the only committed launch
  configuration that can make direct registration requests.
- **Fun App Landing — Development (Local Registration Worker)** uses Flutter
  port `7357`, loads the registration Worker origin from `.env`, keeps payment
  deferred, and sends provider-neutral registration JSON only to localhost.
- **Fun App Landing — Development (Local Workers)** loads both Worker origins
  and selects both local deterministic transports.
- **Fun App Worker — Local Mock** runs Wrangler on `localhost:8787`; the
  **Fun App Landing + Local Mock Worker** compound starts both local processes.
- **Fun App Payment Worker — Local Mock** runs the deterministic Stripe mock on
  `localhost:8788`; the **Fun App Landing + Local Mock Workers** compound starts
  Flutter and both isolated Workers without contacting HubSpot or Stripe.
- **Fun App Landing — Production** selects the production first-party Venue
  source and fixed `https://funapp.world` payment boundary without loading `.env`.
  Registration remains deferred, so the purchase flow cannot start, and the
  payment Worker separately defaults creation to disabled.

For a terminal production launch, use the production entrypoint without the
development-only registration configuration:

```bash
puro flutter run -d chrome -t lib/main_prod.dart
```

The explicit entrypoints select the dependency environment. Development uses
`lib/main_dev.dart` and its deterministic fake source; production uses
`lib/main_prod.dart` and sends current-origin Venue requests. A local production
browser run resolves `/api/venue-interest` to localhost and therefore does not
reach the deployed Worker. Use development for local form behavior, or test the
production data source with its deterministic request-target seam.

Build the production entrypoint locally without runtime defines:

```bash
puro flutter build web -t lib/main_prod.dart
puro dart run tool/prepare_intermediate_release_artifact.dart
```

The second command removes the three review-only legal Markdown files from the
production artifact and restores the production robots/header state if the
same `build/web` directory previously held a staging artifact. It refuses to
delete an unrecognized `_headers` file. The source legal files remain intact
for review and testing, but their routes remain inaccessible in the public
application.

## Environment and execution guide

The entrypoint chooses the dependency graph. Builds never submit forms, create
Checkout Sessions, or deploy anything; provider activity is possible only when
a running browser submits through an explicitly selected transport. The
staging artifact is deliberately separate from `web/CNAME`, which remains the
production declaration for `funapp.world`.

### Environment matrix

| Environment or mode | Purpose | Flutter entrypoint or build command | VS Code/VSCodium | Website location | Configuration and preparation |
| --- | --- | --- | --- | --- | --- |
| Local fake development | Default UI work with no registration or payment I/O. Venue submissions are deterministic local success; user registration and payment fail closed. | `puro flutter run -d chrome -t lib/main_dev.dart`; build-only: `puro flutter build web -t lib/main_dev.dart` | **Fun App Landing — Development (Fake Repositories)**; this is the first/default Run choice. | Flutter-selected localhost; build output is `build/web`. | No `.env`, Worker, HubSpot, Stripe, Cloudflare, or GitHub preparation. |
| Local direct HubSpot testing | Explicit browser-to-HubSpot testing for Here & Now and Founding Friend only. | `puro flutter run -d chrome -t lib/main_dev.dart --dart-define-from-file=.env --dart-define=FUN_APP_REGISTRATION_TRANSPORT=direct_hubspot` | **Fun App Landing — Development (Direct HubSpot)** | Flutter-selected localhost. | Copy `.env.example` to ignored `.env` and set the public portal and two registration form IDs. No private token belongs in Flutter. |
| Local mocked registration Worker | Exercise first-party registration serialization, validation, rate limiting, and deterministic responses without starting payment. | Start `npm run dev` in `cloudflare/venue-interest-worker`, then run `lib/main_dev.dart` on port `7357` with `.env` and `FUN_APP_REGISTRATION_TRANSPORT=local_worker`. | **Fun App Landing + Local Mock Worker** compound; its Flutter child is **Development (Local Registration Worker)**. | Flutter at `http://localhost:7357`; registration Worker at `http://localhost:8787`. | Copy the registration `.dev.vars.example` to ignored `.dev.vars` and root `.env.example` to ignored `.env`. |
| Local mocked Worker integration | Exercise registration plus the complete deterministic Checkout/verification journey, without HubSpot or Stripe. | Start registration `npm run dev` and payment `npm run dev:mock`, then run `lib/main_dev.dart` on port `7357` with both `local_worker` defines. | **Fun App Landing + Local Mock Workers** compound; its Flutter child is **Development (Local Workers)**. | Flutter at `http://localhost:7357`; Workers at ports `8787` and `8788`. | Same ignored `.env` and registration `.dev.vars`; payment `dev:mock` needs no file or credential. Copy its `.dev.vars.example` only to choose another scenario. |
| Production-mode local run/build | Compile or inspect the exact production composition without deploying it. | Run: `puro flutter run -d chrome -t lib/main_prod.dart`; build: `puro flutter build web -t lib/main_prod.dart`, then `puro dart run tool/prepare_intermediate_release_artifact.dart`. | **Fun App Landing — Production** | Localhost when run; `build/web` when built. | No `.env`. Venue requests resolve to localhost; payment routes target `https://funapp.world`, subject to browser CORS. Deferred registration prevents the normal registration-to-Checkout journey. Builds make no requests. |
| Staging artifact build | Compile the staging composition and produce an upload-safe artifact. This is a build, not a supported local integration runtime. | `puro flutter build web -t lib/main_staging.dart`, then `puro dart run tool/prepare_staging_release_artifact.dart`. | No extra launch configuration; use the terminal tasks above to avoid implying localhost is staging. | `build/web` only. The preparation tool removes `CNAME` and review-only legal assets and adds staging canonical/noindex metadata. | No `.env` or provider credential. The compiled graph targets `https://staging.funapp.world` for both first-party integrations. |
| Hosted staging | Protected staging UI, mocked registration, and optionally real Stripe sandbox Checkout. | Pushes to `dev` validate then deploy the site and both staging API Workers through one workflow. | Not launched by Run; GitHub `staging` permits deployments from `dev` only. | `https://staging.funapp.world` on Workers Static Assets Worker `funapp-landing-staging`. | GitHub `staging` Environment, Cloudflare Workers credentials, Stripe sandbox configuration, custom domain, routes, and Access. Existing resources and environment configuration are maintained externally; CI does not provision them. |
| Hosted production | Current public site and existing Venue flow. | `.github/workflows/deploy.yml` builds `lib/main_prod.dart`; the two existing production Worker workflows deploy only when manually dispatched. | **Fun App Landing — Production** is local inspection only. | GitHub Pages at `https://funapp.world`; the existing narrow Venue Worker route is externally managed. | GitHub Pages plus the existing production Cloudflare configuration. Production registration and payment creation remain disabled. |

The standalone Worker commands are also supported execution modes:

- `cloudflare/staging-site-worker`: after preparing `build/web`, `npm run dev`
  serves the Static Assets composition locally on port `8789`; `npm run
  typecheck`, `npm test`, and `npm run wrangler:validate` validate without
  deploying.
- `cloudflare/venue-interest-worker`: `npm run dev` is loopback-only and mock-only;
  `npm run typecheck`, `npm test`, `npm run wrangler:validate`, and
  `npm run wrangler:validate:staging` validate without deploying.
- `cloudflare/founding-friend-payment-worker`: `npm run dev:mock` is the
  credential-free default; `npm run dev` reads an ignored `.dev.vars` for a
  selected local scenario. The same typecheck, test, and two Wrangler dry-run
  commands validate both Worker environments without deployment.

### Integration matrix

| Mode | Venue form | Here & Now / Founding Friend registration | HubSpot | Founding Friend payment | Stripe | Can create external records or payments? | Can affect production? | Current status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Local fake development | In-memory fake success | Deferred/fail-closed | Unavailable | Deferred/fail-closed | Unavailable | No | No | Implemented; local-only. |
| Local direct HubSpot testing | In-memory fake success | Direct public HubSpot Forms API | **Real** development-selected forms | Deferred/fail-closed | Unavailable | **Can create HubSpot form records** when a developer submits | Cannot change production infrastructure, but supplied IDs may identify real HubSpot forms | Implemented; use only for explicitly authorized tests. |
| Local mocked registration Worker | In-memory fake success | Local registration Worker | Mocked, no upstream call | Deferred/fail-closed | Unavailable | No | No | Implemented; deterministic. |
| Local mocked Worker integration | In-memory fake success | Local registration Worker | Mocked, no upstream call | Local payment Worker | Mocked, no upstream call | No | No | Implemented; deterministic. |
| Production-mode local run | Same-origin localhost request | Deferred/fail-closed | Registration unavailable | Fixed `https://funapp.world` payment endpoints, subject to browser CORS | Production payment service boundary | No during build; runtime payment routes can attempt production requests; registration remains deferred | Payment requests target production, not a local mock | Use local mocked Worker integration for payment development. |
| Staging artifact build | No runtime activity | No runtime activity | No runtime activity | No runtime activity | No runtime activity | No | No | Implemented build path; artifact is not deployed. |
| Hosted staging | In-memory fake success; no staging Venue API route | `funapp-venue-interest-staging` staging-only adapter | Mocked, with no HubSpot identifiers or fallback | `funapp-founding-friend-payment-staging` | Stripe **sandbox only**; creation follows the required `STAGING_PAYMENT_CREATION_ENABLED` environment variable | Can create sandbox Checkout/Customer/payment records while enabled; never HubSpot records | No, when the documented identities/routes/Environment are used | Operational sandbox Checkout and verification after secret rotation were confirmed by the operator on 2026-10-31; not rechecked by this implementation. |
| Hosted production | Existing `funapp-venue-interest` route may submit to HubSpot | Deferred/fail-closed in Flutter; registration routes remain unattached/disabled | Real for the existing Venue contract only | Repository boundary exists, but creation is disabled and no production payment route is approved | Live payment unavailable | Existing Venue submissions can create HubSpot records; no registration or payment activation is introduced here | This is production | Existing hosting/Worker behavior preserved. |

### Trigger matrix

| Event or command | Builds/tests | Deploys | Target and safety boundary |
| --- | --- | --- | --- |
| Press Run in VSCodium | Starts only the selected launch configuration. The first/default choice is fake development. | Nothing | The selected name states whether it is fake, direct HubSpot, local registration, both local Workers, or production-mode local. |
| Start **Landing + Local Mock Worker** | Starts Flutter plus the registration mock. | Nothing | Localhost only; payment remains deferred. |
| Start **Landing + Local Mock Workers** | Starts Flutter plus both deterministic Workers. | Nothing | Localhost only; no HubSpot or Stripe request. |
| Run any local `flutter build web` command | Compiles the selected entrypoint into `build/web`. | Nothing | Build commands perform no provider I/O. Run the matching artifact preparation command before upload. |
| Push a feature branch other than `dev` or `main` | No repository workflow is triggered solely by the push. | Nothing | No staging Worker uses Cloudflare Git integration or an automatic repository trigger. |
| Open or update a PR targeting `dev` or `main` | `pr_checks.yml` formats, generates, analyzes, tests, dry-runs the site Worker and both API Workers, and builds production plus staging artifacts. | Nothing | Hosted CI validation only. |
| Push a commit to `main` | `deploy.yml` regenerates, analyzes, tests, and builds production. | **Deploys production GitHub Pages** | Existing production behavior is intentionally preserved. It does not deploy either Worker or staging. |
| Manually dispatch `deploy.yml` | Same production validation/build. | **Deploys production GitHub Pages** | Production action; unrelated to staging. |
| Manually dispatch either existing production Worker workflow | Validates the selected root Worker. | **Deploys that production Worker identity** | Uses GitHub `production`; no routes are changed. These are not staging commands. |
| Push a commit to `dev` (including a PR merge) | Reuses every `pr_checks.yml` validation, including production/staging builds and all three Worker suites. | **Deploys staging only after all checks succeed** | `deploy-staging-site.yml` uses GitHub `staging`, rejects superseded revisions, deploys both staging API Workers, then publishes the validated staging site artifact. |

The staging workflow has no manual or PR deployment trigger. The former
individual staging API deployment workflows have been retired so there is one
validation gate and no manual checkbox that resets payment creation. Production
Worker workflows remain manual-only and use the GitHub `production` environment.
Production Pages retains the `github-pages` environment and its existing triggers.

### Staging architecture and routing

Cloudflare Workers Static Assets is the staging host. The independent
`cloudflare/staging-site-worker/` project deploys `build/web` as Worker
`funapp-landing-staging`, serves unmatched navigation through the SPA fallback,
and runs its minimal handler first for `/api` and `/api/*`. That handler returns
`404` instead of allowing a missing API route to resolve to `index.html`.
`workers.dev` and preview/version URLs are explicitly disabled. No
source-controlled route or custom domain is attached, so deploying the Worker
cannot change DNS or claim either staging or production traffic.

Named Wrangler environments remain the boundary for the two distinct API
Workers. Bindings and variables are non-inherited, so each `env.staging` block
declares its own vars and rate limiter. Rate-limit namespace IDs are
account-defined positive integers; `2001` and `2002` are deliberately distinct
from each other and from the production source IDs `1001` and `1002`, but an
operator must retain the established unique account namespaces. Automatic
staging deployments preserve the deployed rate limiters instead of reconciling
these source defaults over dashboard settings.

After `staging.funapp.world` is added as the site Worker's dashboard-managed
Custom Domain, the intended dashboard-managed Worker Routes are:

```text
staging.funapp.world/api/registrations/*
  -> funapp-venue-interest-staging

staging.funapp.world/api/founding-friend-payments/*
  -> funapp-founding-friend-payment-staging
```

Cloudflare creates the DNS record and certificate for a Worker Custom Domain.
The two more-specific Routes then take precedence over that site origin and send
only the API families to their isolated Workers. Those Workers still accept
only their exact supported paths and return `404` for other suffixes. If a
Route is absent or incorrect, the site Worker also fails closed for every
`/api` path. Do not add a staging `/api/venue-interest` route, do not add any
staging route on `funapp.world`, and do not change the existing
`funapp.world/api/venue-interest` route.

Relevant current Cloudflare references are [Static Assets configuration](https://developers.cloudflare.com/workers/static-assets/binding/),
[Static Assets headers](https://developers.cloudflare.com/workers/static-assets/headers/),
[Worker Custom Domains](https://developers.cloudflare.com/workers/configuration/routing/custom-domains/),
[Worker Routes](https://developers.cloudflare.com/workers/configuration/routing/routes/),
[Cloudflare Access for Workers](https://developers.cloudflare.com/workers/configuration/cloudflare-access/),
[Workers authorization](https://developers.cloudflare.com/workers/authorization/),
and [Wrangler environments](https://developers.cloudflare.com/workers/wrangler/environments/).

### Staging configuration inventory

Public, source-controlled staging configuration:

- Site origin: `https://staging.funapp.world`.
- Static Assets Worker: `funapp-landing-staging`, entrypoint
  `cloudflare/staging-site-worker/src/index.ts`, asset directory `build/web`,
  SPA fallback enabled, `/api` fallback blocked, `workers.dev` disabled, preview
  URLs disabled, and no route or custom domain in source.
- Registration Worker: `funapp-venue-interest-staging`, staging entrypoint,
  deterministic mock enabled, rate namespace `2001`, no HubSpot identifiers.
- Payment Worker: `funapp-founding-friend-payment-staging`,
  `STRIPE_EXPECTED_LIVEMODE=false`, staging return/cancel origin, and source
  rate namespace `2002`. Source-only fail-closed Price/tax placeholders and the
  disabled creation default remain useful for dry runs; automatic deployment
  removes them and supplies the reviewed GitHub environment values explicitly.

Required GitHub `staging` environment configuration (names only; values are
managed outside source control):

| Kind | Name | Purpose |
| --- | --- | --- |
| Variable | `CLOUDFLARE_ACCOUNT_ID` | Account containing the intended staging Workers and `funapp.world` zone. |
| Variable | `STRIPE_SANDBOX_PRICE_ID` | Sandbox, active, one-time, tax-inclusive GBP 24900 Price. |
| Variable | `STRIPE_SANDBOX_AUTOMATIC_TAX_ENABLED` | Must preserve disabled automatic tax for this staging automation. |
| Variable | `STAGING_PAYMENT_CREATION_ENABLED` | Required exact boolean string; explicitly mapped to Worker `PAYMENT_CREATION_ENABLED`, with no fallback. Currently enabled. |
| Secret | `CLOUDFLARE_STAGING_SITE_API_TOKEN` | Existing least-privilege token for `funapp-landing-staging`, including settings read and code deployment. No DNS, route, or Access permission is added. |
| Secret | `CLOUDFLARE_WORKERS_API_TOKEN` | Existing least-privilege token limited to the two staging API Workers, including settings read and code deployment. No permissions are broadened automatically. |
| Secret | `STRIPE_SANDBOX_RESTRICTED_KEY` | Restricted key beginning `rk_test_`; the workflow rejects live or standard secret keys. |
| Secret | `STAGING_PURCHASE_REFERENCE_SECRET` | Independent random value of at least 32 characters, never shared with production. |

`STRIPE_SANDBOX_RESTRICTED_KEY` is the canonical GitHub staging secret name;
deployment maps it to the Worker's `STRIPE_SECRET_KEY` binding. If the GitHub
environment currently uses `STRIPE_SECRET_KEY`, manually copy the existing
sandbox restricted credential to the canonical name before deployment. This
naming correction requires no credential rotation; there is no fallback alias.

`STAGING_PAYMENT_CREATION_ENABLED` is required on every deployment. Missing,
blank, or malformed values fail preflight before any Worker is changed; an
explicit disabled value is supported for an intentional staging sales stop.
Automatic tax must remain disabled. The workflow pins expected live mode to
false and the public origin to staging, and accepts only a sandbox restricted
key. It does not alter pricing, Adaptive Pricing, or payment verification.
Flutter contains none of these credentials. Local `.env` and `.dev.vars` files
remain ignored.

### Staging validation and deployment

Build and validate locally without deployment:

```bash
puro flutter build web -t lib/main_staging.dart
puro dart run tool/prepare_staging_release_artifact.dart
bash tool/verify_staging_artifact.sh
cd cloudflare/staging-site-worker
npm ci
npm run typecheck
npm test
npm run wrangler:validate
```

The **Deploy Staging** workflow (`deploy-staging-site.yml`) runs on pushes to
`dev` only. It calls the same credential-free checks used by PRs and deploys
only after every check succeeds. The Flutter job builds `lib/main_staging.dart`,
prepares and verifies its isolated metadata, and uploads that run's artifact.
The deployment job downloads that exact artifact; it does not rebuild Flutter
with credentials present. Required-check names for PR branch protection are
**Worker checks**, **Payment Worker checks**, and **Flutter and staging site
checks**. There are no path filters that silently skip these checks.

Publishing is serialized without cancelling an active deployment. A dev-HEAD
comparison under that lock rejects stale reruns and jobs queued out of order.
A push arriving during publishing waits for the active deployment to finish.
Both API Workers publish before the site. The three deployments are sequential,
not atomic; a later failure can leave a partial staging release.

`tool/prepare_staging_deployment.mjs` first validates every required setting,
then reads `/workers/scripts/<staging-worker>/settings` for all three existing
identities using their respective tokens. Missing resources or denied reads
fail before deployment; the workflow never creates replacement resources or
broadens permissions. It writes temporary configs containing only public
payment settings, absolute staging entrypoints/assets, and preservation
metadata. Current dashboard variable values are not copied into files or logs.

Wrangler reconciliation is deliberate:

- [`keep_vars`](https://developers.cloudflare.com/workers/wrangler/commands/workers/#deploy)
  preserves plain/JSON variables, and Wrangler retains encrypted secrets. It
  does **not** preserve arbitrary resource bindings or rate-limit configuration.
- The generated configs use the Cloudflare upload API's
  [`keep_bindings`](https://developers.cloudflare.com/api/resources/workers/subresources/scripts/methods/update/)
  metadata via Wrangler `unsafe.metadata`, retaining every binding type found
  during preflight plus plain/JSON variables and encrypted secret types. Source
  rate-limit declarations are omitted, preserving deployed namespaces and limits.
  Only the five reviewed payment variables and the new site assets are supplied
  explicitly. Tests inspect the actual locked Wrangler multipart output.
- Routes and Custom Domains are absent from generated configs. With
  `workers_dev: false`, Wrangler leaves dashboard routing managed externally
  ([documented behavior](https://developers.cloudflare.com/workers/wrangler/deprecations/)).
  No DNS, routing, or Access command is used.
- The two payment secrets come from the existing GitHub secrets, are written
  with mode `0600` under `RUNNER_TEMP`, and are uploaded with code using
  `--secrets-file`. This avoids a separate secret-update deployment. Temporary
  files are deleted even on failure and never uploaded as artifacts. Keep these
  GitHub secrets synchronized with Cloudflare when rotating them.

Keep dashboard configuration stable during a deployment: binding types added
after preflight are outside its preservation snapshot. The `unsafe.metadata`
interface is version-sensitive; the locked Wrangler versions are unchanged and
CI tests its output. Changes to those versions require rerunning these tests.

### Operational configuration and rollback

The operator reports the three Workers, GitHub environments, staging variables
and secrets already exist, and sandbox Checkout plus payment verification passed
after purchase-reference secret rotation. This implementation does not repeat
that hosted verification or modify external configuration.

Before enabling this change through the normal review/merge process:

1. Retain GitHub `staging` restricted to `dev`, `production` restricted to `main`,
   and the existing `github-pages` environment. Add the three check names above
   to branch protection when desired; this task does not change protection rules.
2. Confirm the existing tokens can read settings and deploy only their intended
   Workers. A denied read must be investigated without automatically expanding
   token permissions. No new credential or bootstrap Admin token is needed.
3. Preserve the site Custom Domain, the two API Routes, unique rate-limit
   namespaces, and hostname-wide Cloudflare Access. Confirm Access covers all
   three Workers and the return from Stripe Checkout.
4. Keep the payment creation variable explicitly enabled, the existing sandbox
   Price/key and rotated purchase-reference secret synchronized, and automatic
   tax disabled. Review the first authorized hosted run and sandbox smoke test.

For a code rollback, revert the offending change through a PR to `dev`; merging
it runs the same validation and republishes all three staging components using
the current environment configuration. Re-running an old workflow revision is
intentionally skipped by the dev-HEAD check. If publishing itself is broken,
disable **Deploy Staging** in GitHub Actions, cancel pending runs, and let any
active publish settle. Use Cloudflare's version history to restore a known-good
version on each affected **staging** Worker, then repair/re-enable automation.
Before a version rollback, check its variables and encrypted secrets: an old
version can restore a pre-rotation purchase-reference secret. Prefer a code
revert with the current secrets. Neither rollback path changes routes, DNS,
production Pages, or production Workers automatically.

## Localization

Localization source files live under `lib/l10n/` using Flutter ARB generation
configured by `l10n.yaml`. English (`en`) is the source/default language;
Spanish (`es`), Welsh (`cy`), and Belarusian (`be`) are also supported.

Product terminology keeps `Fun App`, `Here & Now`, `Founding Friend`,
`Safe Guard`, and `Footprint` unchanged. Generic terms such as Membership,
Venue, and Waitlist are localized. Country option labels use Unicode CLDR
translations while their stored integration values remain unchanged.

Regenerate localization output after changing an ARB file:

```bash
puro flutter gen-l10n
```

Generated localization Dart files are local build inputs and are not committed.

## Routing

Flutter routing uses `auto_route` with generated typed route classes and
`MaterialApp.router`. The public paths are `/`, `/venues`, `/privacy`,
`/here-and-now`, `/founding-friend`, `/founding-friend/payment`, and
`/founding-friend/payment/cancelled`; deployed URLs retain Flutter Web's hash
form (for example, `/#/privacy`). Direct production visits to `/terms`,
`/refunds`, `/cookies`, or `/cookie-banner` redirect to `/` without rendering
the unfinished legal document. Unknown paths fall back to `/`. Direct-route
loads do not synthesize a landing-page history entry, while in-app pushes,
logo navigation, Back, and Forward are handled by Router 2. Landing-section
targets are typed route arguments rather than URL fragments.

Route source is declared in `lib/presentation/core/routing/app_router.dart`.
The generated `app_router.gr.dart` file is a local build input and remains
uncommitted; regenerate it with the repository's standard `build_runner`
command after changing route declarations or `@RoutePage` constructors.

## Privacy Notice content and review-only legal pages

`assets/legal/privacy_notice.md` is the canonical website representation of
the currently approved Fun App Ltd Privacy Notice. Do not rewrite or translate
its legal prose independently. Replace or update it only from a newly approved
source document.

The site exposes the notice through Flutter's GitHub-Pages-safe hash route:

```text
https://funapp.world/#/privacy
```

During local development, append `#/privacy` to the root URL printed by
`puro flutter run -d chrome -t lib/main_dev.dart`. The build bundles the legal
Markdown asset directory declared in `pubspec.yaml`;
`flutter_markdown_plus` renders every document through the shared branded
shell, and the web link adapter handles only the approved `mailto:` contact
links.

Auto Route, Freezed, and Injectable sources are generated locally and remain
uncommitted. Regenerate all generated Dart source after changing a route,
model, or dependency registration:

```bash
puro flutter pub run build_runner build
```

## Validation

```bash
puro flutter gen-l10n
puro flutter pub run build_runner build
puro flutter analyze
puro flutter test
puro flutter build web -t lib/main_prod.dart
puro dart run tool/prepare_intermediate_release_artifact.dart
```

The test suite covers domain validation, Venue and prospective-user form
orchestration, the Founding Friend Checkout and payment-verification lifecycle,
the user sign-up widgets, and the active landing surface's branding,
localization, theme, interactions, and responsive viewport contracts.

## Cloudflare Worker development

`cloudflare/venue-interest-worker/` is the isolated TypeScript project for the
existing `funapp-venue-interest` Worker. It preserves `POST
/api/venue-interest` and implements exact dispatch for `POST
/api/registrations/here-and-now` and `POST
/api/registrations/founding-friend`. The registration routes are implemented
but are not attached or enabled in production. The Worker validates each Fun
App-owned request contract and maps to HubSpot only inside the Worker. GitHub
Pages remains the origin for every non-API path.

Install and validate it independently:

```bash
cd cloudflare/venue-interest-worker
npm ci
npm run typecheck
npm test
npm run wrangler:validate
```

Fake local values live only in the tracked `.dev.vars.example`; copy that file
to an ignored `.dev.vars` for local Wrangler development. Its required mock
scenario makes both Venue and registration submissions deterministic and
prevents HubSpot I/O. Start it with `npm run dev`; copy `.env.example` to the
ignored root `.env`; then use the compound launch configuration. Change
`HUBSPOT_MOCK_SCENARIO` and restart Wrangler to exercise `success`,
`provider_rejection`, `rate_limited`, `provider_unavailable`,
`network_failure`, or `timeout`. Send malformed JSON or omit a required field
to exercise request validation.

```bash
cd cloudflare/venue-interest-worker
cp .dev.vars.example .dev.vars
npm run dev
```

The Here & Now request requires `firstName`, `lastName`, `email`, integer
`age`, and boolean `marketingConsent`; `gender` and `usageReason` are optional.
Founding Friend uses the same contract plus required canonical `country`.
Unknown properties, malformed JSON, unsupported gender/country values,
non-safe-integer ages, non-JSON content, and bodies over 16 KiB are rejected.
The local Flutter Worker client applies the same JavaScript safe-integer and
UTF-8 body-size boundaries before sending; these are serialization constraints,
not age eligibility or product-specific text-length rules.
Responses are provider-neutral: `204` success, `400` invalid request, `404`
unknown route, `405` unsupported method, `422` provider validation rejection,
`429` rate limited, `503` disabled/unavailable, and `500` unexpected or invalid
configuration. Provider bodies and submitted personal data are never returned
or logged.

The Worker uses `HUBSPOT_PORTAL_ID`, the authoritative existing
`HUBSPOT_FORM_GUID` (with `HUBSPOT_VENUE_FORM_GUID` supported only as a fallback
alias when the established binding is absent),
`HUBSPOT_HERE_AND_NOW_FORM_GUID`,
`HUBSPOT_FOUNDING_FRIEND_FORM_GUID`, and
`REGISTRATION_SUBMISSIONS_ENABLED`. Registration defaults to disabled and
requires the source-declared `REGISTRATION_RATE_LIMITER` binding. That binding
provides approximate, Cloudflare-location-local protection targeting 10
attempts per 60 seconds for each route/connecting-IP key; it is not a strict,
globally consistent quota. Shared public IPs can group unrelated users and
cause collective throttling, while traffic handled in different Cloudflare
locations may exceed the nominal aggregate rate. The
`wrangler.jsonc` file declares no HubSpot `vars` and sets `keep_vars: true`.
The Worker makes at most one HubSpot attempt with a 10-second timeout and never
retries. `LOCAL_DEVELOPMENT_ALLOWED_ORIGIN` and `HUBSPOT_MOCK_SCENARIO` are
local-only mock settings. Loopback Worker execution requires both settings and
a valid scenario, otherwise it fails closed without provider I/O. A deployed
Worker rejects either local setting. Do not configure them on the deployed
Worker.

`.github/workflows/deploy-venue-interest-worker.yml` is manually triggered
only. Its sole job targets the GitHub `production` Environment, validates the
Worker, and deploys the existing Worker using that Environment's
`HUBSPOT_PORTAL_ID`, `HUBSPOT_FORM_GUID`, `CLOUDFLARE_ACCOUNT_ID`, and
`CLOUDFLARE_API_TOKEN`. It supplies
`REGISTRATION_SUBMISSIONS_ENABLED=false` when that Environment variable is
absent. The two registration form variables are required only if the flag is
later set to `true`. Do not enable it until consent/legal approval and the
Cloudflare routes and bindings have been reviewed. The workflow deliberately
configures no route; route attachment remains dashboard-managed.

Pending manual production setup is deliberately unperformed: keep the existing
`HUBSPOT_PORTAL_ID`, `HUBSPOT_FORM_GUID`, `CLOUDFLARE_ACCOUNT_ID`, and
`CLOUDFLARE_API_TOKEN`; add GitHub Environment variables
`HUBSPOT_HERE_AND_NOW_FORM_GUID`,
`HUBSPOT_FOUNDING_FRIEND_FORM_GUID`, and
`REGISTRATION_SUBMISSIONS_ENABLED=false`; confirm rate-limit namespace `1001`
is unique in the Cloudflare account; and later attach the existing Worker to
the exact `funapp.world/api/registrations/here-and-now` and
`funapp.world/api/registrations/founding-friend` routes. Do not change the flag
to `true` until the outstanding legal/consent and controlled-live-verification
gates are approved.

### Founding Friend payment Worker

`cloudflare/founding-friend-payment-worker/` is a separate Worker project. It
does not modify, share deployment with, or add bindings to the existing Venue
Worker. It owns two first-party JSON endpoints:

- `POST /api/founding-friend-payments/checkout-sessions` accepts exactly a
  validated `email` and UUID v4 `attemptId`. When creation is enabled, the
  Worker validates its configured tax-inclusive Stripe Price, creates one
  Stripe Checkout Session in `payment` mode for quantity 1 and a £249 GBP
  base price, explicitly applies the approved automatic-tax setting, always
  creates a Stripe Customer after Checkout completion, prefills the Customer email, and
  returns only `checkoutUrl`, `sessionId`, and an opaque request ID.
- `POST /api/founding-friend-payments/checkout-sessions/verify` accepts exactly
  a Stripe Checkout `sessionId`. It retrieves that specific session and its
  line item, verifies environment, mode, configured Price, quantity, currency,
  amount, paid state, purchase reference, and the latest-charge refund/dispute
  signals available from Stripe. It returns only a provider-neutral status and
  exposes the purchase reference after confirmed payment.

The browser never supplies a Price, amount, currency, or redirect URL. The
Worker generates `FF-...` purchase references with a server-only HMAC secret
and writes each reference to Stripe `client_reference_id`, Checkout metadata,
and PaymentIntent metadata. The explicit automatic-tax choice is also stored in
Checkout and PaymentIntent metadata so later verification checks the Session's
own creation contract rather than whichever tax setting is current then.
Payment-mode Checkout uses
`customer_creation=always`; a completed qualifying payment must contain the
resulting Stripe Customer ID, while a newly created or pending Session may not
have a Customer yet. Verification is read-only and remains available when new
Checkout creation is disabled. Responses contain no email, Customer ID,
billing or payment-method details, raw Stripe objects, provider errors,
Checkout URLs on verification, or secrets.

Checkout creation uses `founding-friend-checkout-v1-{attemptId}` as the Stripe
idempotency key. Flutter creates the attempt only after successful HubSpot
registration and keeps the email, attempt ID, and opaque Checkout Session ID
once returned in tab-scoped browser session storage for explicit payment retry.
A retry therefore does not resubmit registration and, while Stripe retains the
idempotency result, reuses the logical Checkout creation. This is not durable
exactly-once behavior: no D1, KV, Durable Object, or other payment database exists. A lost response after
Stripe's idempotency retention window, cleared tab storage, an independent
browser session, or an expired Checkout Session can require a new attempt and
may produce another unpaid session. In the original browser tab, an explicitly
retried expired session rotates only the payment attempt and does not resubmit
registration. Cancellation stays inert until explicit retry, then verifies the
stored Session through the payment repository. Only verified expiry rotates the
attempt. Open/unpaid `pending` results explicitly allow resuming Checkout via
`canResumeCheckout`. Updated clients opt in with
`Accept: application/json; checkout-recovery=1`; older clients retain the
previous response schema. Complete/unpaid or older responses without that
capability cannot authorize a redirect. Creation replay recovers the URL using the same
attempt, and the returned Session is verified again before redirect. Older
stored attempts and interrupted creation without a Session ID replay the
original attempt, then persist and verify the response; they retain the existing
Stripe idempotency-retention limitation. Verification failure never rotates the
attempt. Confirmed, refunded, disputed, and invalid results cannot create a new
Checkout. Without tab state, the UI fails safely to support guidance.
Stripe remains the only purchase record; customers must not be treated as paid
from a redirect alone.

Run the browser storage regression separately from the normal Flutter suite:

```bash
puro flutter test --platform chrome \
  test/data/founding_friend_payment/session_pending_founding_friend_payment_store_web_test.dart
```

Install and validate the payment Worker independently:

```bash
cd cloudflare/founding-friend-payment-worker
npm ci
npm run typecheck
npm test
npm run wrangler:validate
```

Ordinary local development needs no Stripe account or credential. Run
`npm run dev:mock` for the default confirmed-payment scenario, or copy the
tracked `.dev.vars.example` to ignored `.dev.vars` and select one deterministic
scenario: `created`, `paid`, `pending`, `cancelled`, `expired`,
`provider_validation_failure`, `payment_mismatch`, `network_failure`,
`provider_unavailable`, `timeout`, `duplicate_attempt`, `refunded`, or
`disputed`, then run `npm run dev`. Local mode requires the exact loopback
Flutter origin and never calls Stripe. Point Flutter at it with the committed
VSCodium compound or:

```bash
puro flutter run -d chrome -t lib/main_dev.dart --web-port=7357 \
  --dart-define-from-file=.env \
  --dart-define=FUN_APP_REGISTRATION_TRANSPORT=local_worker \
  --dart-define=FUN_APP_PAYMENT_TRANSPORT=local_worker
```

`duplicate_attempt` models Stripe's idempotent replay: identical email and
attempt-ID requests return the same mock Session and Checkout URL, while a new
attempt ID creates a different mock Session. It does not claim durable
exactly-once behavior.

The Worker accepts JSON bodies up to 4 KiB, exact schemas only, a strict public
application origin, abortable 10-second Stripe requests, exact
`checkout.stripe.com` redirects, and a required Cloudflare rate-limit binding.
It performs no operational logging of emails, names, request bodies, Checkout
URLs, payment details, credentials, or provider responses. Local mock settings
are rejected outside loopback execution. `PAYMENT_CREATION_ENABLED` must be
exactly `true` before creation is possible and defaults to false; invalid or
incomplete Price, live/test-mode, origin, key, secret, or binding configuration
fails closed without creating a session. For creation,
`STRIPE_AUTOMATIC_TAX_ENABLED` is a required exact `true` or `false`; the
Worker always sends it to Stripe and
never inherits an account-level Checkout tax default. The configured Price
must be tax-inclusive so the base total remains £249 GBP whether the
separately approved automatic-tax setting is enabled or disabled. Adaptive
Pricing remains enabled in Stripe; Stripe calculates any localized equivalent.
Creation response checks remain GBP/24900. Verification accepts either GBP
Session/payment totals with optional presentment details, or reconciled
localized Session, line-item, PaymentIntent and captured-charge totals tied to
that exact original GBP Price. It requires successful payment/capture, matching
references and environment, and consistent supplied presentment details; it
never computes an exchange rate. See the [payment
contract in SPECIFICATIONS.md](SPECIFICATIONS.md) for details and the documented
API-version evidence limit: the read-only sandbox showed localized totals, but
the connector cannot make a GET pinned to the Worker's Dahlia version.

`.github/workflows/deploy-founding-friend-payment-worker.yml` is a separate,
manual-only validation and deployment workflow and has not been run. Later
external setup requires Cloudflare Environment variables
`PAYMENT_CREATION_ENABLED=false`, `STRIPE_PRICE_ID`,
`STRIPE_EXPECTED_LIVEMODE`, `STRIPE_AUTOMATIC_TAX_ENABLED`,
`PUBLIC_APP_ORIGIN=https://funapp.world`, and
`CLOUDFLARE_ACCOUNT_ID`; Cloudflare/GitHub secrets `STRIPE_SECRET_KEY`
(prefer a least-privilege restricted key), `PURCHASE_REFERENCE_SECRET`, and
`CLOUDFLARE_API_TOKEN`; a unique rate-limit namespace for source ID `1002`;
and exact route attachment for the two payment paths. A Stripe sandbox Product,
Price, and restricted key are maintained outside the repository; the operator
reports successful staging Checkout and verification after secret rotation.
This CI implementation does not repeat that hosted verification. This change
creates no live Stripe resource, credential, secret, route, binding, GitHub
Environment value, or deployment.

Before activation, approve the tax treatment and then set
`STRIPE_AUTOMATIC_TAX_ENABLED` deliberately. Enabling it also requires the
business's confirmed Stripe Tax settings, origin address, applicable active
registrations, and approved Product tax code; the code does not choose any of
those legal or business inputs. Also approve the refund/cancellation policy and
copy, supported payment methods, dispute/support handling, and any required
terms. This MVP deliberately performs no automatic HubSpot payment sync,
webhook fulfillment, account creation, or membership provisioning. The later
authenticated Fun App backend must verify a qualifying Stripe payment against
the account's verified email. Customers are reminded to use the purchase email
for that future account; the present payment confirmation does not activate
membership. If delayed payment methods or payment-triggered side effects are
introduced, their asynchronous lifecycle and authenticated webhook handling
must be designed before launch.

## Repository structure

```text
lib/                         Active Flutter application source
lib/main_dev.dart            Development/fake Flutter entrypoint
lib/main_staging.dart        Hosted staging Worker composition entrypoint
lib/main_prod.dart           Production first-party Flutter entrypoint
lib/application/venue/       Venue-lead form state and submission orchestration
lib/application/user_registration/ Independent Here & Now and Founding Friend BLoCs
lib/application/founding_friend_payment/ Checkout and verification BLoCs
lib/core/config/              Typed application-environment selection
lib/core/injection/           GetIt/Injectable composition root
lib/domain/core/             Pure-Dart failures, validators, and value objects
lib/domain/venue/            Provider-neutral prospective-venue domain model
lib/domain/user_registration/ Provider-neutral registration models and contracts
lib/domain/founding_friend_payment/ Provider-neutral payment contracts and status
lib/data/venue/               Venue repository, DTO, and selectable data sources
lib/data/user_registration/  Direct/Worker transports and fail-closed fallback
lib/data/founding_friend_payment/ Payment Worker transport and tab-scoped retry state
lib/l10n/                    Localization ARB source files
lib/presentation/core/routing/ Typed auto_route configuration and dependencies
lib/presentation/core/widgets/ Shared viewport/footer page shell
lib/presentation/landing/pages/ Landing-page composition and navigation owner
lib/presentation/landing/sections/ Section-owned landing presentation widgets
lib/presentation/landing/shared/widgets/ Cross-section landing widgets
lib/presentation/landing/content/ Landing presentation content definitions
lib/presentation/landing/theme/ Shared landing typography and motion values
assets/branding/             Shared Fun App logos and decorative brand shapes
assets/landing/              Figma assets consumed by active landing sections
assets/fonts/                Bundled Google Fonts files and OFL license assets
assets/legal/                Approved canonical website legal content
test/                        Flutter widget tests for active behavior
web/                         Flutter Web shell and web-root static inputs
cloudflare/venue-interest-worker/ Existing first-party forms Worker
cloudflare/founding-friend-payment-worker/ Separate Stripe payment Worker
cloudflare/staging-site-worker/ Staging-only Workers Static Assets site host
l10n.yaml                    Flutter localization generation configuration
archive/astro_site/          Deprecated pre-Flutter historical reference
.github/workflows/deploy.yml Flutter GitHub Pages workflow
.github/workflows/deploy-venue-interest-worker.yml Manual Worker deployment
.github/workflows/deploy-founding-friend-payment-worker.yml Manual payment Worker deployment
SPECIFICATIONS.md            Authoritative project decisions
AGENTS.md                    Coding-agent working rules
```

Each landing section owns a directory under `sections/`, with one Widget class
per Dart file and no private Widget component classes. Section-specific widgets
stay with their section; widgets genuinely used by multiple sections stay under
`shared/widgets/`. A StatefulWidget's associated private State class remains in
the same file as its public widget.

## Architecture direction

Application behavior uses a layer-first direction with `presentation`,
`application`, `domain`, and `data` responsibilities when active code requires
them. `domain` owns validation and the provider-neutral Venue, Here & Now,
Founding Friend registration, Checkout, and payment-status contracts; separate
application BLoCs coordinate registration, Checkout creation, and reloadable
payment verification.
The Venue data repository maps validated leads into a provider-neutral DTO and
delegates to an environment-selected data source. Prospective-user repositories
use direct HubSpot only in the explicit direct-development profile, or
provider-neutral requests to a local mocked Worker in the explicit Worker
profile. Unconfigured development and every production build remain
fail-closed. Payment uses only the separate first-party Worker boundary;
Flutter has no Stripe SDK or secret. The explicit development and production
entrypoints pass a typed
environment into `core`, which configures GetIt through Injectable before the
app starts.
The production data boundary maps the DTO to the Fun App-owned JSON contract
and posts to same-origin `/api/venue-interest` with an abortable 15-second
request deadline. The Worker keeps HubSpot mapping outside Flutter layers.

See [`SPECIFICATIONS.md`](SPECIFICATIONS.md) for the complete direction and
dependency boundaries.

## Deployment

Pull requests targeting `dev` or `main` run all three Worker projects'
typechecking, tests, and Wrangler dry runs plus Flutter formatting, generation,
analysis, full-suite coverage, and production/staging builds through the
read-only `PR Checks` workflow. These checks have no staging environment or
Cloudflare/Stripe credentials and cannot deploy. Pushes to `dev` reuse these
checks, then automatically deploy only staging through **Deploy Staging**.

Pushes to `main` and manual workflow dispatches run the GitHub Pages workflow.
The `dev` branch deploys to Cloudflare staging and has no Pages environment.
Hosted CI installs Flutter 3.47.2 directly through
`subosito/flutter-action@v2`, then generates localizations and Dart sources,
analyzes, tests, and explicitly builds `lib/main_prod.dart` without browser-side
provider configuration. Local development continues to use Puro. The workflow
then removes the three review-only legal Markdown assets before it uploads
`build/web` and deploys to
[https://funapp.world](https://funapp.world).

The custom domain remains configured in GitHub Pages. `web/CNAME` records the
repository's active domain declaration and is copied into the Flutter artifact.

## Contributing

Keep commits small and focused, preserve the documented decision status, and
run verification appropriate to the files changed before requesting review.
For staging automation changes, install each Worker's locked dependencies,
prepare the staging artifact, and run `node --test
test/tool/staging_deployment.test.mjs` from the repository root. This suite uses
mock settings responses and Wrangler dry runs, with no provider credentials or
deployments. PRs to either long-lived branch validate only; a merge into `dev`
starts automatic staging deployment after those checks pass.
