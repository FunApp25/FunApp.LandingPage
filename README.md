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
  a first-party local Worker transport backed by deterministic mocks. Without
  an explicit development selection, both development repositories fail closed.
  Production Flutter uses the same-origin registration Worker for both forms.
  Each form has an independent server-side flag that defaults to disabled.
  Forwarding requires Cloudflare routing, Worker configuration, and the
  approved HubSpot form. Production Stripe Checkout creation has its own
  disabled-by-default flag.
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
  All five legal routes now load selected `en-GB` publications at runtime from
  `https://legal.funapp.world/manifest.json`; the legal repository is the sole
  content authority. The shared footer exposes Privacy Notice, Website Terms,
  Founding Friend purchase terms, User Agreement, and Acceptable Use Policy.
  Refund/cancellation and cookie placeholder routes remain restricted. The
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
  family, weight, or style, add its correctly named official font file and
  applicable license asset, then keep the bootstrap license registration in sync.
- Release builds use `--no-web-resources-cdn` to load CanvasKit from the site's
  own `canvaskit/` directory. The engine's default Roboto Regular is declared in
  `pubspec.yaml` and bundled with its Apache 2.0 license; Manrope and Instrument
  Serif remain the application fonts. Roboto is the unmodified font from the
  pinned Flutter 3.47.2 SDK (`engine/src/flutter/txt/third_party/fonts/`, SHA-256
  `79e851404657dac2106b3d22ad256d47824a9a5765458edb72c9102a45816d95`).
  Default Roboto loading is separate from dynamic glyph fallback: unsupported
  characters (including user-entered scripts or emoji) may still request fonts
  from `fonts.gstatic.com`. No `fontFallbackBaseUrl` override or fallback
  disabling is applied. Instrument Serif lacks Belarusian glyphs; the existing
  engine fallback remains available, and bundled Manrope and Roboto cover the
  four current UI catalogs. This is not complete font self-hosting.
  Keep the renderer flag in every release command and run
  `puro dart run tool/verify_web_resources.dart` after artifact preparation.
  CanvasKit filenames are not version-hashed: retain host cache revalidation;
  do not add an immutable cache policy to `canvaskit/`.
- Flutter localization supports complete application-UI catalogs for English,
  Spanish, Welsh, and Belarusian, with English as the source and unsupported-
  locale fallback language. Published legal documents remain English (`en-GB`); interface labels are
  localized without translating legal prose.
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
puro flutter run -d chrome -t lib/main_dev.dart --no-web-resources-cdn
```

Both entrypoints expose the Here & Now and Founding Friend forms. Their BLoCs
validate and attempt submission. Development remains fail-closed by default,
and does not load local HubSpot configuration. If the ignored local `.env`
does not exist, copy it from `.env.example`. Use only approved portal and
form identifiers for direct HubSpot testing. The Venue form identifier is retained
only as a local reference for configuring the Worker-specific `.dev.vars` file;
Flutter does not read it. The shared portal identifier and two registration
form identifiers configure only an explicitly configured temporary
direct-HubSpot development test:

```bash
puro flutter run -d chrome -t lib/main_dev.dart \
  --dart-define-from-file=.env \
  --dart-define=FUN_APP_REGISTRATION_TRANSPORT=direct_hubspot \
  --dart-define=FUN_APP_PAYMENT_TRANSPORT=deferred
```

These are public form identifiers, not credentials. Do not put private HubSpot
access tokens or secrets in Dart defines or a Flutter Web bundle. The direct
transport sends no `legalConsentOptions`; independently verify each form's
required fields and legal-consent settings in HubSpot before any authorized
live test. Production ignores browser-side HubSpot defines and uses the first-party
Worker for Here & Now. Consent and age-eligibility decisions remain open.
Refund/cookie placeholder routes remain restricted.

VS Code and VSCodium use the shared Chrome launch profiles in
`.vscode/launch.json`. Run the Puro editor setup above on a new machine.

- **Fun App Landing — Development** is the first and recommended everyday
  profile. It uses the deterministic Venue repository and defers user
  registration and payment. It serves Flutter's web resources locally and
  needs neither `.env` nor local Workers.
- **Fun App Landing — Development (Booking .env)** loads
  `FUN_APP_VENUE_BOOKING_URL` from the ignored root `.env` and explicitly
  keeps registration and payment deferred. The equivalent terminal launch is
  shown below.
- **Fun App Landing + Mock Registration** starts the registration Worker and
  the **Development (Mock Registration)** Flutter profile. Use it to test
  Here & Now registration at `http://localhost:7357` with payment deferred.
- **Fun App Landing + Mock Registration and Payment** starts both mock Workers
  and the **Development (Mock Registration + Payment)** Flutter profile. Use
  it for the deterministic Founding Friend registration and Checkout journey.
- **Fun App Registration Worker — Local Mock** and **Fun App Payment Worker —
  Local Mock** start just their respective Worker on port `8787` or `8788`.
  The Flutter profiles in the compounds are also available for Workers you
  have already started.
- **Fun App Landing — Development (Direct HubSpot)** loads the approved public
  identifiers from `.env`. Submitting Here & Now or Founding Friend can
  create real HubSpot records. Payment remains deferred.
- **Fun App Landing — Production (Local Inspection)** uses the production
  dependency graph without `.env`. Venue and both registration endpoints
  resolve to localhost. Payment requests can target `https://funapp.world`.
  Use the local mock profiles for end-to-end development.

To launch the booking profile from a terminal:

```bash
puro flutter run -d chrome -t lib/main_dev.dart --no-web-resources-cdn \
  --dart-define-from-file=.env \
  --dart-define=FUN_APP_REGISTRATION_TRANSPORT=deferred \
  --dart-define=FUN_APP_PAYMENT_TRANSPORT=deferred
```

For mock integration, run `npm ci` in each Worker directory you will start.
Copy the registration Worker's `.dev.vars.example` to its ignored `.dev.vars`.
Use the root `.env.example` for the loopback URL settings. If you already have
a root `.env` for booking, add any missing Worker URL settings to it. The
default payment mock needs no additional file or credential.

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
puro flutter build web --no-web-resources-cdn -t lib/main_prod.dart
puro dart run tool/prepare_intermediate_release_artifact.dart
puro dart run tool/verify_web_resources.dart
```

The second command rejects any bundled `assets/assets/legal` directory and
restores production robots/header state if `build/web` previously held a staging
artifact. It refuses to delete an unrecognized `_headers` file. No local legal
Markdown is bundled; refund/cookie drafts remain inactive source references.

## Environment and execution guide

The entrypoint chooses the dependency graph. Builds never submit forms, create
Checkout Sessions, or deploy anything; provider activity is possible only when
a running browser submits through an explicitly selected transport. The
staging artifact is deliberately separate from `web/CNAME`, which remains the
production declaration for `funapp.world`.

### Venue booking and email logo

The Venue waitlist action submits the existing enquiry form. The booking action
opens a separate browser tab and preserves the current draft. On wide layouts
the orange booking button is on the left and the blue waitlist button is on the
right. On narrow layouts the waitlist button comes first.

Set the public `FUN_APP_VENUE_BOOKING_URL` in the ignored `.env` file for local
development and choose **Development (Booking .env)** or use its terminal
command above.
Keep the value quoted if it contains a URL fragment.
Hosted builds read the same-named Actions variable from the `staging` or
`production` Environment. A missing or invalid HTTPS URL leaves the button
available and displays localized feedback on activation. A URL change needs a
new web build.

`web/email/fun-app-logo.png` is copied to `/email/fun-app-logo.png` in both
artifacts. After publishing and verifying the production site, use
`https://funapp.world/email/fun-app-logo.png` in HTML email signatures or
footers. The production URL is intended for anonymous access. Staging retains
its existing site protection.

### Environment matrix

| Environment or mode | Purpose | Flutter entrypoint or build command | VS Code/VSCodium | Website location | Configuration and preparation |
| --- | --- | --- | --- | --- | --- |
| Local fake development | Default UI work with no registration or payment I/O. Venue submissions are deterministic local success; user registration and payment fail closed. | `puro flutter run -d chrome -t lib/main_dev.dart --no-web-resources-cdn`; build-only: `puro flutter build web --no-web-resources-cdn -t lib/main_dev.dart` | **Fun App Landing — Development** (first/default). | Flutter-selected localhost; build output is `build/web`. | Booking configuration is optional. The default mode requires no external services. |
| Local booking configuration | Use the configured scheduler with deferred registration and payment. | Use the booking terminal launch above. | **Fun App Landing — Development (Booking .env)** | Flutter-selected localhost. | Set `FUN_APP_VENUE_BOOKING_URL` in the ignored root `.env`. |
| Local direct HubSpot testing | Explicit browser-to-HubSpot testing for Here & Now and Founding Friend only. | `puro flutter run -d chrome -t lib/main_dev.dart --dart-define-from-file=.env --dart-define=FUN_APP_REGISTRATION_TRANSPORT=direct_hubspot --dart-define=FUN_APP_PAYMENT_TRANSPORT=deferred` | **Fun App Landing — Development (Direct HubSpot)** | Flutter-selected localhost. | Copy `.env.example` to ignored `.env` and set the public portal and two registration form IDs. No private token belongs in Flutter. |
| Local mocked registration Worker | Exercise first-party registration serialization, validation, rate limiting, and deterministic responses without starting payment. | Start `npm run dev` in `cloudflare/venue-interest-worker`, then run `lib/main_dev.dart` on port `7357` with `.env`, `FUN_APP_REGISTRATION_TRANSPORT=local_worker`, and `FUN_APP_PAYMENT_TRANSPORT=deferred`. | **Fun App Landing + Mock Registration** compound. | Flutter at `http://localhost:7357`; registration Worker at `http://localhost:8787`. | Copy the registration `.dev.vars.example` to ignored `.dev.vars` and root `.env.example` to ignored `.env`. |
| Local mocked Worker integration | Exercise registration plus the complete deterministic Checkout/verification journey, without HubSpot or Stripe. | Start registration `npm run dev` and payment `npm run dev:mock`, then run `lib/main_dev.dart` on port `7357` with both `local_worker` defines. | **Fun App Landing + Mock Registration and Payment** compound. | Flutter at `http://localhost:7357`; Workers at ports `8787` and `8788`. | Same ignored `.env` and registration `.dev.vars`; payment `dev:mock` needs no file or credential. Copy its `.dev.vars.example` only to choose another scenario. |
| Production-mode local run/build | Compile or inspect the exact production composition without deploying it. | Run: `puro flutter run -d chrome -t lib/main_prod.dart`; build: `puro flutter build web --no-web-resources-cdn -t lib/main_prod.dart`, then `puro dart run tool/prepare_intermediate_release_artifact.dart`. | **Fun App Landing — Production (Local Inspection)** | Localhost when run; `build/web` when built. | Venue and both registrations resolve to localhost. Payment routes target `https://funapp.world`, subject to browser CORS. Builds make no requests. |
| Staging artifact build | Compile the staging composition and produce an upload-safe artifact. This is a build, not a supported local integration runtime. | `puro flutter build web --no-web-resources-cdn -t lib/main_staging.dart`, then `puro dart run tool/prepare_staging_release_artifact.dart`. | No extra launch configuration; use the terminal tasks above to avoid implying localhost is staging. | `build/web` only. The preparation tool removes `CNAME`, rejects bundled local legal assets, and adds staging canonical/noindex metadata. | Booking configuration is optional. No provider credential is required. Registration and payment requests target `https://staging.funapp.world`. |
| Hosted staging | Protected staging UI, mocked registration, and optionally real Stripe sandbox Checkout. | Pushes to `dev` validate, then automatically publish the two staging API Workers and staging site. | Not launched by Run; GitHub `staging` permits deployments from `dev` only. | `https://staging.funapp.world` on Workers Static Assets Worker `funapp-landing-staging`. | GitHub `staging` Environment, Cloudflare Workers credentials, Stripe sandbox configuration, custom domain, routes, and Access. Existing resources and environment configuration are maintained externally; CI does not provision them. |
| Hosted production | Current public site and existing Venue flow. | `.github/workflows/deploy.yml` builds `lib/main_prod.dart`; both production Worker workflows deploy only when manually dispatched on `main`. | **Fun App Landing — Production (Local Inspection)** is local inspection only. | GitHub Pages at `https://funapp.world`; the existing narrow Venue Worker route is externally managed. | Each registration workflow and Checkout creation default to disabled and require authorized Worker configuration and exact routes. |

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
| Production-mode local run | Same-origin localhost request | Both registrations resolve to localhost | Requires separate local routing | Fixed `https://funapp.world` payment endpoints, subject to browser CORS | Production payment service boundary | No during build; runtime payment routes can attempt production requests | Payment requests target production | Use local mocked Worker integration for payment development. |
| Staging artifact build | No runtime activity | No runtime activity | No runtime activity | No runtime activity | No runtime activity | No | No | Implemented build path; artifact is not deployed. |
| Hosted staging | In-memory fake success; no staging Venue API route | `funapp-venue-interest-staging` staging-only adapter | Mocked, with no HubSpot identifiers or fallback | `funapp-founding-friend-payment-staging` | Stripe **sandbox only**; creation follows the required `STAGING_PAYMENT_CREATION_ENABLED` environment variable | Can create sandbox Checkout/Customer/payment records while enabled; never HubSpot records | No, when the documented identities/routes/Environment are used | Automated deployment verified; registration, sandbox Checkout and verification reported successful by the operator. See [operational status](#operational-configuration-and-rollback). |
| Hosted production | Existing `funapp-venue-interest` route may submit to HubSpot | Both forms are Worker-backed and require independent activation | Venue and each registration's approved form after activation | Production-capable Worker with Checkout creation disabled by default | Live-mode configuration required | Venue can create HubSpot records. Registration and payment need authorized setup. | This is production | Founding Friend purchasing has not been launched. |

### Trigger matrix

| Event or command | Builds/tests | Deploys | Target and safety boundary |
| --- | --- | --- | --- |
| Press Run in VSCodium | Starts only the selected launch configuration. The first/default choice is fake development. | Nothing | The profile name identifies the booking, mock integration, direct HubSpot, or production inspection mode. |
| Start **Landing + Mock Registration** | Starts Flutter plus the registration mock. | Nothing | Localhost only; payment remains deferred. |
| Start **Landing + Mock Registration and Payment** | Starts Flutter plus both deterministic Workers. | Nothing | Localhost only; no HubSpot or Stripe request. |
| Run any local `flutter build web --no-web-resources-cdn` command | Compiles the selected entrypoint into `build/web`. | Nothing | Build commands perform no provider I/O. Run the matching artifact preparation command before upload. |
| Push a feature branch other than `dev` or `main` | No repository workflow is triggered solely by the push. | Nothing | No staging Worker uses Cloudflare Git integration or an automatic repository trigger. |
| Open or update a PR targeting `dev` or `main` | `pr_checks.yml` formats, generates, analyzes, tests, dry-runs the site Worker and both API Workers, and builds production plus staging artifacts. | Nothing | Hosted CI validation only. |
| Push a commit to `main` | `deploy.yml` regenerates, analyzes, tests, and builds production. | **Deploys production GitHub Pages** | Existing production behavior is intentionally preserved. It does not deploy either Worker or staging. |
| Manually dispatch `deploy.yml` | Same production validation/build when dispatched on `main`. | **Deploys production GitHub Pages** | Production action; unrelated to staging. |
| Manually dispatch either production Worker workflow on `main` | Validates the selected root Worker and production settings. | **Deploys that production Worker identity** | Uses GitHub `production`. Each enabled capability requires its matching dispatch authorization. Cloudflare routes are managed separately. |
| Push a commit to `dev` (including a PR merge) | Reuses every `pr_checks.yml` validation, including production/staging builds and all three Worker suites. | **Deploys staging registration, sandbox payment, then site** | `deploy-staging-site.yml` uses GitHub `staging` after all checks pass, complete read-only preflight, and the dev-HEAD check under the publishing lock. |

The staging workflow has no manual or PR deployment trigger. The former
individual staging API deployment workflows have been retired so there is one
validation gate and no manual checkbox that resets payment creation. Production
Worker workflows remain manual-only and use the GitHub `production` environment.
The production Pages build uses the `production` Environment. Publishing
continues through `github-pages`.

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
puro flutter build web --no-web-resources-cdn -t lib/main_staging.dart
puro dart run tool/prepare_staging_release_artifact.dart
puro dart run tool/verify_web_resources.dart
bash tool/verify_staging_artifact.sh
cd cloudflare/staging-site-worker
npm ci
npm run typecheck
npm test
npm run wrangler:validate
```

The **Deploy Staging** workflow (`deploy-staging-site.yml`) runs on pushes to
`dev` only and calls the same credential-free checks used by PRs. Required-check
names remain **Worker checks**, **Payment Worker checks**, and **Flutter and
staging site checks**. PRs targeting `dev` or `main` validate only, without the
staging Environment or deployment credentials. Common deployment-safety tests and
Wrangler backport regressions run once in **Flutter and staging site checks**;
each API Worker job filters the deployment suite to its own upload-metadata test.
The site upload-metadata test runs with the common tests. Staging artifact upload is enabled
only for dev pushes; coverage upload remains available to PRs.

After all checks pass, the build job enters GitHub `staging` and compiles the
same revision with its public booking URL. The deploy job downloads that
verified artifact. The Flutter build receives no deployment credentials.
Publishing holds `funapp-staging-deployment` with `cancel-in-progress: false`.
The dev-HEAD check under that lock rejects superseded revisions and stale reruns.
A newer push waits for an active publish to finish. Order remains registration,
sandbox payment, then site. These sequential deployments are not atomic: a later
failure can still leave a partial release.

`tool/staging-wrangler/` is the isolated staging deployment toolchain. Install it
with `npm ci --prefix tool/staging-wrangler`; invoke it with
`node tool/staging-wrangler/wrangler.mjs` from the repository root. All staging
publishing, generated-config dry runs, and upload-metadata tests use this wrapper.
Production Worker deployments use the Wrangler version locked in each Worker project.

The package locks Wrangler **4.155.0** with npm integrity checks. Its postinstall
backports [workers-sdk PR #16531](https://github.com/cloudflare/workers-sdk/pull/16531)
from immutable revision
[`416ed05ea788852c9c06784c370d77603ee10936`](https://github.com/cloudflare/workers-sdk/commit/416ed05ea788852c9c06784c370d77603ee10936).
The checked-in patch requires the exact original bundle SHA-256, applies without
fuzz, and verifies the resulting SHA-256. Every wrapper invocation verifies the
installed version and patched bundle. A different version, changed bundle, or
reapplied patch fails closed; reinstall with `npm ci`. No mutable prerelease build
or maintained fork is used.

The backport limits dashboard-origin metadata reads to route categories actually
being deployed. With no local routes/Custom Domains it queries neither endpoint;
configured categories still require their metadata permissions. Versions upload
omits unrelated routes from its comparison. Binding/environment checks,
configuration diffs, and Worker identity validation remain active. As verified
on 2026-11-01, PR #16531 is open and stable 4.156.0 still has the defect. Remove
the backport only after inspecting a stable release's implementation and upstream
tests, pinning it in this isolated toolchain, and passing the local CLI permission,
strict-diff, identity, and upload-preservation regressions.

`tool/prepare_staging_deployment.mjs` validates the complete environment before
writing any deployment files. For all three existing identities and their own
tokens it reads service metadata, the service's actual internal environment's
bindings/subdomain/environment metadata, script schedules/settings/deployments,
and Worker metadata (`/workers/workers/<name>`) used by trigger publishing.
A multi-version current deployment also requires its version metadata reads.
Payment deployment additionally checks secret names for conflicts with public
variables. Preflight checks required binding types (including rate limiters,
site assets, registration mock enablement, and encrypted payment secrets) and
consistent settings/environment binding inventories. The purchase-reference
secret must contain at least 32 characters and no CR/LF, matching runtime
validation; invalid values fail before metadata reads or deployment-file writes.
Preflight never queries routes or Custom Domains, follows redirects, publishes,
or logs provider bodies/values.
Denied or unusable required reads fail before any Worker publishes. Successful
reads reduce partial-release risk; they do not prove write permission or make
the release atomic.

Run regressions after preparing the staging artifact:

```bash
npm ci --prefix tool/staging-wrangler
node --test test/tool/staging_wrangler.test.mjs test/tool/staging_deployment.test.mjs
```

The CLI tests use a loopback mock API with denied route/domain endpoints; they
perform no authenticated Cloudflare verification or actual deployment.
Temporary generated configs contain public payment settings, absolute staging
entrypoints/assets, and preservation metadata. Dashboard variable values are not
copied into files or logs.

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
interface is version-sensitive; CI tests the exact fixed staging tool output.
Changing that tool requires rerunning these tests.

### Operational configuration and rollback

As verified on 2026-11-03, [Deploy Staging run 41300396058, attempt 2](https://github.com/FunApp25/FunApp.LandingPage/actions/runs/41300396058/attempts/2)
succeeded on 2026-11-01 for `dev` revision
`83c5c2a775d15feda56db2dfc4a9cb24d2ab4a4a`. GitHub records successful
preflight, artifact verification, and registration, sandbox payment, and site
deployment steps. This is deployment evidence, not a fresh browser or provider
test.

The Checkout-creation HTTP 500 reported on 2026-11-01 is a historical incident.
The operator reports it was resolved by correcting the staging purchase-reference
secret, and that registration, Stripe sandbox Checkout, and payment verification
subsequently passed. These runtime results are operator-reported, not independently
repeated in this audit. Registration remains mocked without HubSpot I/O; payment
uses Stripe sandbox only. The staging diagnostics remain available for future
failures; the incident is not a current unresolved blocker.

The `general_audit` changes after that deployed revision, including the local
audit fixes and A08 image optimizations, are not covered by that deployment
evidence. The A09/A10 CI and documentation edits are also local and undeployed.
The Stripe business account has been approved. The production-capable code in
this repository defaults Founding Friend registration and Checkout creation to
disabled. Approved legal applicability, production configuration, controlled
live verification, and public launch authorization remain separate release steps.

For subsequent deployments:

1. Retain GitHub `staging` restricted to `dev`, `production` restricted to `main`,
   and the existing `github-pages` environment and required checks.
2. Preserve least-privilege token access, the site Custom Domain, the two API
   Routes, unique rate-limit namespaces, and hostname-wide Cloudflare Access,
   including the Stripe Checkout return path.
3. Keep payment enablement explicit, automatic tax disabled, and sandbox
   configuration synchronized. Preserve the canonical mappings
   `STRIPE_SANDBOX_RESTRICTED_KEY` → `STRIPE_SECRET_KEY` and
   `STAGING_PURCHASE_REFERENCE_SECRET` → `PURCHASE_REFERENCE_SECRET`.
   Secret-name existence does not prove equal values; privately check against
   the operator's source of truth when configuration changes, never print values.
4. Review the hosted run and all three deployed versions, then perform an
   authorized sandbox smoke test. A later deployment failure can still leave
   components at different revisions because publishing is sequential.

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
Each catalog's country rows are ordered by the displayed localized name using
locale collation. Preserve that order when updating countries; full-ICU Node.js
tests check all four locales, including accents and Welsh digraphs. Chrome tests
check dropdown ordering changes, search, selection, and keyboard interaction.
Changing locale updates the order without changing the selected canonical value.
This also preserves Welsh ordering in browsers whose `Intl.Collator` falls back
to English. Run `node --test test/tool/country_ordering.test.mjs` after editing
country catalogs.

Regenerate localization output after changing an ARB file:

```bash
puro flutter gen-l10n
```

Generated localization Dart files are local build inputs and are not committed.

## Routing

Flutter routing uses `auto_route` with generated typed route classes and
`MaterialApp.router`. The public paths are `/`, `/venues`, `/privacy`,
`/terms`, `/founding-friend/purchase-terms`, `/user-agreement`,
`/acceptable-use-policy`, `/here-and-now`, `/founding-friend`,
`/founding-friend/payment`, and `/founding-friend/payment/cancelled`; deployed URLs retain Flutter Web's hash
form (for example, `/#/privacy`). Visits to `/#/refunds`, `/#/cookies`, or `/#/cookie-banner` redirect to `/` without rendering
the unfinished legal document. Unknown paths fall back to `/`. Direct-route
loads do not synthesize a landing-page history entry, while in-app pushes,
logo navigation, Back, and Forward are handled by Router 2. Landing-section
targets are typed route arguments rather than URL fragments.

Route source is declared in `lib/presentation/core/routing/app_router.dart`.
The generated `app_router.gr.dart` file is a local build input and remains
uncommitted; regenerate it with the repository's standard `build_runner`
command after changing route declarations or `@RoutePage` constructors.

## Published legal documents and release constraint

The independent `FunApp.LegalDocumentation` repository owns content, metadata,
versions and publication. The landing website reads only its public production
manifest and selected JSON assets; PDFs use validated manifest references.

| Hash route | Publisher ID |
| --- | --- |
| `/#/privacy` | `privacy_notice` |
| `/#/terms` | `terms_of_use` |
| `/#/founding-friend/purchase-terms` | `founding_member_purchase_terms` |
| `/#/user-agreement` | `user_agreement` |
| `/#/acceptable-use-policy` | `acceptable_use_policy` |

Each route resolves `active[id]["en-GB"]` and requires one matching entry.
The data repository validates schema, metadata, timestamps, MIME, strict UTF-8,
asset destinations and manifest/document hash equality. Hash equality is an
identity consistency check, not an independent digest recomputation or signature.
Requests reject redirects, share a 15-second deadline, and bound manifest/JSON
bodies to 256 KiB/1 MiB. A missing or mismatched asset permits one fresh manifest
resolution within that deadline. There is no persistent cache, guessed URL,
background refresh or old bundled fallback. Browser HTTP caching follows the
publisher's revalidation headers; one loaded snapshot remains stable per open
route. Retry starts a fresh operation. A PDF link does not fetch or gate JSON;
a removed PDF can report the service's 404 in its separate browser tab.

The shared branded Markdown shell displays the exact title, version, English
language, publication timestamp and effective timestamp, retaining published
offsets. Only interface labels are localized. Legal text remains selectable;
HTTPS/email links have focus and keyboard controls. Unsupported Markdown, raw
HTML, images and unsafe links fail explicitly rather than dropping clauses.
There is no arbitrary HTML execution. Browser link destinations are exposed
through semantics. A scoped, app-lifetime listener prevents native anchor
navigation from duplicating the existing Flutter callbacks, preserving new-tab
form links and typed same-tab footer history. Current publications require paragraphs,
headings, ordered/unordered lists, emphasis, autolinks and hard line breaks.

**Release constraint:** all five initially selected documents have
`effectiveAt: 2026-11-14T00:00:00+01:00` (13 November at 23:00 UTC), distinct
from `publishedAt: 2026-11-08T11:57:22.034Z`. The page labels future-effective
publications. Selection/publication does not establish current applicability.
This feature branch prepares the pages; it does not authorize production
replacement of the currently applicable notice before the effective-date
transition is approved. If a prior applicable notice must remain available,
obtain its authoritative source and a publication-contract decision: the public
manifest exposes no prior applicable version. Never guess one or restore obsolete
bundled wording as current authority. Payment/registration activation remains a
separate approval.

Here & Now links Privacy and Website Terms before submission. Founding Friend
also links purchase terms before its automatic Checkout transition, with access
retained in Checkout retry/cancellation presentation. These links are informational;
they do not create acceptance, consent, eligibility rules or backend fields.
Venue retains its optional presentation-only acknowledgement and new-tab link.

`test/fixtures/legal/` contains exact public JSON responses captured on
10 November 2026 solely for regression tests; it is not an application asset or
runtime fallback. The refund/cookie drafts in `assets/legal/` remain unbundled
references. Their routes still redirect home. Both artifact preparation tools
reject accidentally bundled local legal material while preserving host metadata
safeguards. A pre-integration build may retain a stale legal directory; build
from a fresh `build/web` directory if the guard detects one. Roll back landing code through the existing release process, without
silently making old legal wording current. Legal publication rollback is separate.

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
puro flutter test --platform chrome \
  test/data/founding_friend_payment/session_pending_founding_friend_payment_store_web_test.dart \
  test/presentation/user_sign_up/country_ordering_web_test.dart \
  test/presentation/legal/legal_link_navigation_web_test.dart
puro flutter build web --no-web-resources-cdn -t lib/main_prod.dart
puro dart run tool/prepare_intermediate_release_artifact.dart
puro dart run tool/verify_web_resources.dart
```

Validation limits and length semantics are documented in
[SPECIFICATIONS.md, user input](SPECIFICATIONS.md#8-user-input-and-future-backend-direction).
Founding Friend email is checked before registration against the existing
254-unit Checkout limit; Venue text and quantities match its Worker contract.
Validation feedback wraps fully at narrow widths and enlarged text scales.
Checkout recovery ignores disposed completions and preserves newer stored
attempts before writing storage or starting another request.

The approved cancellation FAQ asks for 48 hours' notice for the ongoing
Here & Now subscription. Its existing Founding Friend 14-day purchase refund
statement remains unchanged; no pending legal document is modified.

The test suite covers domain validation, Venue and prospective-user form
orchestration, the Founding Friend Checkout and payment-verification lifecycle,
the user sign-up widgets, and the active landing surface's branding,
localization, theme, interactions, and responsive viewport contracts.

A07 local release measurements (2026-11-02, Flutter 3.47.2, headless Chrome):
fresh-cache landing screenshots were byte-identical before/after for `en`,
`es`, `cy`, and `be` at 390px and 1440px. Startup changed from three Google
resource requests across two external origins to zero external requests in
those eight cases; updated builds rendered with Google resource hosts blocked.
The prepared production artifact grew from 50,656,659 to 50,840,645 bytes
(+183,986); the existing 37,851,412-byte renderer directory was unchanged.
Roboto and its license add 183,098 bytes. Summing each artifact file compressed
with gzip level 9 gives 21,264,454 versus 21,358,688 bytes (+94,234); this is a
local size comparison, not a hosted transfer measurement. The observed desktop
startup transfer was 12,194,588 versus 16,237,542 bytes: the temporary local
server served renderer files uncompressed while Google's CDN compressed them,
so that transfer increase does not predict production performance. Hosted
compression, cache behavior, and deployment remain unverified. Dynamic fallback
for additional scripts/emoji remains an external dependency: typing synthetic
emoji and Han characters into the local form successfully fetched Noto Color
Emoji and Noto Sans SC from `fonts.gstatic.com`. No form was submitted.

A08 photography uses WebP at quality 95 (cwebp 1.6.0), with lossless alpha
encoding and the same sRGB interpretation, composition, cropping, semantics,
and responsive breakpoints. Hero retains separate mobile/desktop assets, and
Connection retains its source dimensions. The two promotional images use
Flutter's standard 1×/2× asset variants: their maximum painted size is 673 × 410,
so DPR 1 uses that resolution while DPR 2/3 retain the original 1346 × 820 files.
No custom selection code or new build dependency is needed. Original PNGs remain
in Git history at `cb7f977` and are removed from active asset directories.

| Photography | Original pixels / PNG bytes | DPR 1 WebP pixels / bytes | DPR 2/3 WebP pixels / bytes |
| --- | --- | --- | --- |
| Mobile Hero | 864 × 878 / 660,012 | 864 × 878 / 92,378 | Same |
| Desktop Hero | 1412 × 1434 / 1,525,413 | 1412 × 1434 / 195,972 | Same |
| Connection | 1360 × 614 / 1,404,150 | 1360 × 614 / 187,270 | Same |
| Founding Friends | 1346 × 820 / 1,463,719 | 673 × 410 / 66,616 | 1346 × 820 / 205,750 |
| Venue | 1346 × 820 / 1,613,807 | 673 × 410 / 80,674 | 1346 × 820 / 265,450 |

Reproduce full-resolution conversions from original PNGs outside active assets:

```bash
cwebp -q 95 -m 6 -sharp_yuv -alpha_q 100 -exact -metadata icc input.png -o output.webp
```

For the two 1× promotional assets, use the same command without `-exact` and
add `-resize 673 0`; keep the full-resolution outputs under `2.0x/`. Existing
directory declarations include these variants.
Benchmarks also covered PNG recompression, lossless WebP, quality 90, and
half-size quality-95 WebP. Quality 95 retains more photographic detail than
quality 90 while saving 84–87% at unchanged resolution. Further dimension cuts
were rejected to preserve existing high-density sharpness. AVIF was not
selected because its engine/browser support matrix was not established.

The 390px DPR-1 photography payload drops from 5,141,688 to 426,938 bytes
(91.7%); desktop DPR 1 drops from 6,007,089 to 530,532 bytes (91.2%). At DPR 2/3,
payloads are 750,848 and 854,442 bytes respectively. Four-byte decoded RGBA
estimates fall from 15,204,288 to 8,581,968 bytes on mobile DPR 1 and from
20,269,152 to 13,646,832 on desktop DPR 1: a 6,622,320-byte reduction. DPR 2/3
decoded sizes remain unchanged. These estimates exclude temporary copies and
GPU storage; they are not browser heap/peak-memory measurements.
The prepared production artifact drops from 50,840,646 to 45,268,073 bytes
(5,572,573 bytes smaller), including both promotional resolutions.

Local release checks on 2026-11-02 covered all four locales at 320/390/1440px
and DPR 1/2/3, plus 599/600/1024px breakpoint cases (39 cold-load cases).
Whole-page scrolling captures at DPR 1 retained matching page dimensions and
composition; representative DPR-3 scrolling and photo-detail comparisons also
passed. Every case fetched exactly four photos at startup and selected the
expected promotional resolution, with no console/network failures. These are
headless desktop simulations, not physical mobile tests. A controlled 390px
DPR-1 pair used fresh caches, no HTTP compression, 6 Mbps and 80 ms latency:
photography request durations changed from approximately 4.2–7.7 seconds to
1.2–1.4 seconds; total startup transfer was 15,371,390 versus 10,656,879 bytes.
First-frame time remained approximately 13.5 seconds in both runs because the
unchanged renderer/application payload dominated this uncompressed simulation.
No hosted performance or browser peak-memory result is claimed.

Sections remain eager: the three below-fold images still download 334,560 bytes
at DPR 1 (658,470 at DPR 2/3). Deferring them would require a separate viewport
policy in the current `SingleChildScrollView`/`Column` composition. It remains
a potential future optimization; no lazy-loading framework is added.

## Cloudflare Worker development

`cloudflare/venue-interest-worker/` is the isolated TypeScript project for the
existing `funapp-venue-interest` Worker. It preserves `POST
/api/venue-interest` and implements exact dispatch for `POST
/api/registrations/here-and-now` and `POST
/api/registrations/founding-friend`. Both registrations use the same first-party
transport, with independent production activation. The Worker validates each
Fun App-owned request contract and maps to HubSpot internally.
GitHub Pages remains the origin for every non-API path.

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
ignored root `.env`; then use **Fun App Landing + Mock Registration**. Change
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
Founding Friend also requires a canonical `country` and a self-declared
integer age of at least 18. The Flutter form and the registration Worker
enforce 18+ before submission, with localized feedback in the form. Here &
Now keeps its integer-age contract. Registration does not verify date of birth,
age, or identity. The payment API's email and attempt ID do not prove that an
eligible registration exists. Reconcile Purchase Terms clause 3.1 and its
exception wording with the strict form rule before launch.
Unknown properties, malformed JSON, unsupported gender/country values,
non-safe-integer ages, non-JSON content, and bodies over 16 KiB are rejected.
The Flutter Worker client applies the same JavaScript safe-integer and
UTF-8 body-size boundaries before sending.
Responses are provider-neutral: `204` success, `400` invalid request, `404`
unknown route, `405` unsupported method, `422` provider validation rejection,
`429` rate limited, `503` disabled/unavailable, and `500` unexpected or invalid
configuration. Provider bodies and submitted personal data are never returned
or logged.

The Worker uses `HUBSPOT_PORTAL_ID` and the authoritative
`HUBSPOT_FORM_GUID` for Venue (`HUBSPOT_VENUE_FORM_GUID` is a fallback when
the authoritative binding is absent). Production registration requires a
numeric portal ID and the source-declared `REGISTRATION_RATE_LIMITER`.
`HERE_AND_NOW_SUBMISSIONS_ENABLED=true` requires a valid
`HUBSPOT_HERE_AND_NOW_FORM_GUID`. `FOUNDING_FRIEND_SUBMISSIONS_ENABLED=true`
requires a valid `HUBSPOT_FOUNDING_FRIEND_FORM_GUID` for its own approved form,
distinct from the Venue and Here & Now forms. Both flags default to `false`.
Only the exact string `true` enables forwarding. Disabled requests return
`503` and invalid settings fail closed. Venue remains independent of both flags.
The shared `REGISTRATION_SUBMISSIONS_ENABLED` switch continues to gate
deterministic registration in local Worker development. Hosted staging uses its
separate staging-only enablement and mock entrypoint.

The production `wrangler.jsonc` sets `keep_vars: true`, declares the rate
limiter, and leaves routing externally managed. The Worker makes at most one
HubSpot attempt with a 10-second timeout. Loopback requests require
`LOCAL_DEVELOPMENT_ALLOWED_ORIGIN` and a supported `HUBSPOT_MOCK_SCENARIO`.
The deployed Worker rejects local mock settings.

The manual `deploy-venue-interest-worker.yml` workflow on `main` targets
`funapp-venue-interest`. It preflights the production entrypoint, rate-limit
namespace `1001`, Cloudflare account and token, numeric `HUBSPOT_PORTAL_ID`,
and `HUBSPOT_FORM_GUID`. Set each enabled flag and its form GUID in the GitHub
`production` Environment and select the matching dispatch authorization.
Preflight rejects unauthorized enablement and requires each registration form
GUID only when that workflow is enabled.

After installing both API Worker projects, run the production preflights
against synthetic settings from the repository root with
`node --test test/tool/production_worker_preflight.test.mjs`.

For Workers last deployed from the Cloudflare dashboard, the locked production
Wrangler version also reads route and Custom Domain metadata before uploading.
Confirm the production deployment token can perform the required metadata reads.

Before an authorized rollout, verify the approved forms and their field and
consent settings, and arrange the exact dashboard-managed routes
`funapp.world/api/registrations/here-and-now` and
`funapp.world/api/registrations/founding-friend` as applicable. Verify Worker
routing before publishing the corresponding Pages build. Roll back forwarding
by setting the affected flag to `false` and redeploying the forms Worker.

### Founding Friend payment Worker

`cloudflare/founding-friend-payment-worker/` is a separate Worker project. It
does not modify, share deployment with, or add bindings to the existing Venue
Worker. It owns two first-party JSON endpoints:

- `POST /api/founding-friend-payments/checkout-sessions` accepts exactly a
  validated `email` and UUID v4 `attemptId`. When creation is enabled, the
  Worker validates its configured tax-inclusive Stripe Price, creates one
  Stripe Checkout Session in `payment` mode for quantity 1 and a £249 GBP
  base price, explicitly applies the configured automatic-tax setting, and
  restricts the Session to `payment_method_types[0]=card` on the pinned
  `2026-08-26.dahlia` API. It supplies the email for the new Stripe Customer
  and returns only `checkoutUrl`, `sessionId`, and an opaque request ID.
- `POST /api/founding-friend-payments/checkout-sessions/verify` accepts exactly
  a Stripe Checkout `sessionId`. It retrieves that specific session and its
  line item, verifies environment, mode, configured Price, quantity, currency,
  amount, paid state, purchase reference, and the latest-charge refund/dispute
  signals available from Stripe. It returns only a provider-neutral status and
  exposes the purchase reference after confirmed payment.

Eligible Apple Pay and Google Pay remain possible through Stripe-hosted
Checkout, subject to browser, device, wallet, currency, and Stripe settings.
Klarna, bank debit, bank transfer, and other delayed methods are outside the
card allowlist. Adaptive Pricing remains account-configured. Check wallet
presentation and local currency together during controlled testing.
[Stripe Checkout version change](https://docs.stripe.com/changelog/endive/2026-09-30/remove-payment-method-types-checkout-sessions),
[Wallet testing](https://docs.stripe.com/testing/wallets).

The browser never supplies a Price, amount, currency, methods, or redirect URL. The
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
idempotency key. After registration Flutter records the email, attempt ID, and
creation start time in session storage before contacting Checkout. The validated
Session ID and hosted URL are saved together when returned. Reopening the
registration page with a pending attempt offers an explicit recovery action.
It blocks a new form submission while the record is unresolved.

Recovery verifies a known Session through the Worker. An expired-payment
return can retry only the stored Session matching its `session_id`. Cancellation
stays inert until retry. A verified open, unpaid Session can resume through its
saved URL if `canResumeCheckout` is true. Known Session recovery performs no
creation replay and has no timestamp cutoff. Only a verified unpaid expiry can
start a replacement attempt. Paid, pending, refunded, disputed, invalid, and
unverifiable outcomes cannot start a replacement. Stale completions preserve
newer tab state. A legacy known Session can still be verified. If it remains
open and the old record lacks a hosted URL, the UI directs the user to support.

For an unknown creation outcome, a user can explicitly replay the same attempt
only within one hour of the recorded start. Stripe API v1 can prune keys at 24
hours or later and can cache errors. Retrying preserves the original start and
does not generate a new key to bypass an error. Missing, unreadable, invalid,
future, or expired replay timestamps require support. An ordinary lost response
inside the window can be recovered and is verified before any redirect.
[Stripe idempotency](https://docs.stripe.com/api/idempotent_requests).

Storage is tab-scoped. A cleared or duplicated tab, another browser or device,
or a direct API caller can still produce independent payments. Stripe holds
the purchase record, and support must manually reconcile ambiguous or duplicate
purchases. Confirmation requires server verification and does not activate
membership.

Run the browser storage regression separately from the normal Flutter suite:

```bash
puro flutter test --platform chrome \
  test/data/founding_friend_payment/session_pending_founding_friend_payment_store_web_test.dart
```

Staging Checkout-creation HTTP 500 responses emit one JSON diagnostic containing
only the response's generated `requestId`, a fixed `stage`, and a fixed
`category`. Match `error.requestId` from the response to the Worker console
record. Categories are `configuration_invalid` and `runtime_unexpected`; no
exception messages, stacks, request/response bodies, headers, cookies, emails,
purchase references, attempt IDs, or secret values are logged. Only the staging
entrypoint supplies the logger; production emits no additional diagnostics,
including when reached through a staging hostname. A logging failure does not
change the response. Successes, verification, and existing 400/404/405/429/502/503
outcomes emit no additional diagnostics.

Allowlisted execution stages are:

| Stage | Operation |
| --- | --- |
| `staging_livemode`, `staging_origin`, `staging_stripe_key` | Staging environment guards |
| `mock_configuration`, `payment_availability`, `rate_limiter` | Configuration before request processing |
| `request_validation` | Read and validate the bounded request |
| `app_origin`, `automatic_tax`, `purchase_reference_secret` | Checkout configuration validation |
| `purchase_reference_hmac` | HMAC key import, signing, and reference preparation |
| `stripe_configuration` | Stripe key, Price ID, and expected-mode validation |
| `stripe_price_lookup` | Retrieve and validate the Stripe Price |
| `stripe_session_creation` | Prepare, create, and validate the Checkout Session |

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
Flutter origin and never calls Stripe. Point Flutter at it with
**Fun App Landing + Mock Registration and Payment** or:

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
Flutter gives Checkout creation 25 seconds for the sequential Price lookup and
Session creation, including 5 seconds of transport/processing allowance beyond
the two independent Stripe deadlines. Verification keeps a separate 15-second
deadline for one lookup. Deadlines include response-body reads. Browser aborts
can leave creation ambiguous. An explicit retry may use the original attempt
inside the one-hour window.
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

`.github/workflows/deploy-founding-friend-payment-worker.yml` is manual on
`main` and targets `funapp-founding-friend-payment`. Supply these settings
through the GitHub `production` Environment for an authorized deployment.

| Setting | Production requirement |
| --- | --- |
| `PAYMENT_CREATION_ENABLED` | Defaults to `false`. `true` also requires the dispatch authorization for live Checkout creation. |
| `STRIPE_EXPECTED_LIVEMODE` | Exactly `true`. |
| `STRIPE_SECRET_KEY` | Encrypted Stripe restricted live key with the `rk_live_` prefix and the operation permissions below. |
| `STRIPE_PRICE_ID` | A syntactically valid `price_…` ID for the active live £249 GBP, one-time, tax-inclusive Price. |
| `STRIPE_AUTOMATIC_TAX_ENABLED` | Explicit `true` or `false`, based on the separately approved tax setting. |
| `PUBLIC_APP_ORIGIN` | Exactly `https://funapp.world`. |
| `PURCHASE_REFERENCE_SECRET` | Encrypted, independently generated high-entropy secret of at least 32 characters, with no surrounding whitespace, CR/LF, or NUL. Keep it stable across deploys. |
| `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_API_TOKEN` | Target account ID and encrypted production deployment token. |

Preflight checks the same Stripe settings as the production entrypoint and the
source-declared `PAYMENT_RATE_LIMITER` in namespace `1002`. Wrangler uploads
both payment secrets with the Worker code using a protected temporary file.
The production entrypoint pins Stripe-backed requests to `https://funapp.world`.
Staging remains sandbox-only and the local mock remains loopback-only.

Provision the restricted key for Price read (`GET /v1/prices/{id}`), Checkout
Sessions Write (`POST /v1/checkout/sessions`), which includes permission to
retrieve Checkout Sessions (`GET /v1/checkout/sessions/{id}`). Verification
expands the Price, PaymentIntent, and latest charge. Confirm the least-privilege grants
for those operations and expansions in the Stripe Dashboard and controlled
tests. The key prefix establishes the key type and mode, while the permissions
are assigned in Stripe. [Restricted API keys](https://docs.stripe.com/keys/restricted-api-keys),
[Price retrieval](https://docs.stripe.com/api/prices/retrieve),
[Checkout creation](https://docs.stripe.com/api/checkout/sessions/create),
[Checkout retrieval](https://docs.stripe.com/api/checkout/sessions/retrieve).

Arrange external route attachment for exactly the two payment paths above.
Keep creation disabled while validating deployment and read-only verification
with valid production configuration. For a controlled live Checkout test,
restrict access to the creation route to authorized testers and obtain
separate approval to enable creation and perform the test payment.
Public launch requires its own authorization after controlled verification and
legal applicability approval. Founding Friend purchasing has not been launched.
To pause sales, set `PAYMENT_CREATION_ENABLED=false` and redeploy while
retaining verification routing, the live key's read access, and the applicable
Price and secret bindings.
Already-issued Stripe Checkout Sessions continue their existing lifecycle.

Before activation, approve the tax treatment and then set
`STRIPE_AUTOMATIC_TAX_ENABLED` deliberately. Enabling it also requires the
business's confirmed Stripe Tax settings, origin address, applicable active
registrations, and approved Product tax code; the code does not choose any of
those legal or business inputs. Approve the refund/cancellation policy,
dispute/support handling, and applicable terms before launch.

Enable **Successful payments** under Stripe's **Customer emails** in the live
account and verify delivery during controlled live testing. Checkout supplies
`customer_email` with `customer_creation=always`, so Stripe can use the paid
Customer's email for automatic receipts. This MVP uses Stripe receipts and
manual reconciliation. It has no custom email delivery, paid invoice creation,
webhooks, or automatic HubSpot payment synchronization. Review the emailed
order confirmation described in Purchase Terms clause 4.6 alongside the
receipt-only implementation. Purchasing secures future benefits. Account creation
and membership activation remain separate from payment confirmation.
[Stripe automatic receipts](https://docs.stripe.com/receipts#automatic).

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
assets/legal/                Inactive, unbundled refund/cookie reference drafts
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
profile. Unconfigured development remains deferred. Both production
registrations use the same-origin Worker transport. Payment uses its own
first-party Worker. Flutter has no Stripe SDK or secret. The explicit development and production
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
typechecking, tests, and Wrangler dry runs, both production Worker preflight
suites, plus Flutter formatting, generation,
analysis, full-suite coverage, Chrome session-storage and country-ordering tests,
legal-link and Venue booking browser navigation, and production/staging builds
through the credential-free `PR Checks` workflow. Pushes to `dev` reuse these
checks before the [staging release sequence](#staging-validation-and-deployment).

Pushes to `main` and manual dispatches on `main` run the GitHub Pages workflow.
The `dev` branch deploys to Cloudflare staging and has no Pages environment.
Hosted CI installs Flutter 3.47.2 directly through
`subosito/flutter-action@v2`, then generates localizations and Dart sources,
analyzes, tests, and explicitly builds `lib/main_prod.dart` without browser-side
provider configuration. Local development continues to use Puro. The workflow
then rejects bundled local legal assets before it uploads
`build/web` and deploys to
[https://funapp.world](https://funapp.world).

The custom domain remains configured in GitHub Pages. `web/CNAME` records the
repository's active domain declaration and is copied into the Flutter artifact.

## Contributing

Keep commits small and focused, preserve the documented decision status, and
run verification appropriate to the files changed before requesting review.
For staging automation changes, install each Worker's locked dependencies and
the isolated staging tool with `npm ci --prefix tool/staging-wrangler`, prepare
the staging artifact, and run `node --test test/tool/staging_wrangler.test.mjs
test/tool/staging_deployment.test.mjs` from the repository root. This suite uses
mock metadata responses, the actual CLI against a loopback API, and Wrangler dry runs, with no provider credentials or
deployments. PRs to either long-lived branch validate only; a merge into `dev`
starts automatic staging deployment after those checks pass.
