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
  exactly £249 GBP. A payment return page shows confirmation and the purchase
  reference only after the payment Worker verifies the Checkout Session; it
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
- **Fun App Landing — Development (Local Worker)** uses Flutter port `7357`,
  loads both Worker origins from `.env`, and sends provider-neutral
  registration and payment JSON only to their separate local Workers.
- **Fun App Worker — Local Mock** runs Wrangler on `localhost:8787`; the
  **Fun App Landing + Local Mock Worker** compound starts both local processes.
- **Fun App Payment Worker — Local Mock** runs the deterministic Stripe mock on
  `localhost:8788`; the **Fun App Landing + Local Mock Workers** compound starts
  Flutter and both isolated Workers without contacting HubSpot or Stripe.
- **Fun App Landing — Production** selects the production first-party Venue
  source and same-origin payment verification boundary without loading `.env`.
  Registration remains deferred, so the purchase flow cannot start, and the
  payment Worker separately defaults creation to disabled.

For a terminal production launch, use the production entrypoint without the
development-only registration configuration:

```bash
puro flutter run -d chrome -t lib/main_prod.dart
```

The explicit entrypoints select the dependency environment. Development uses
`lib/main_dev.dart` and its deterministic fake source; production uses
`lib/main_prod.dart` and sends same-origin requests. A local production browser
run resolves `/api/venue-interest` to localhost and therefore does not reach
the deployed Worker. Use development for local form behavior, or test the
production data source with its deterministic request-target seam.

Build the production entrypoint locally without runtime defines:

```bash
puro flutter build web -t lib/main_prod.dart
puro dart run tool/prepare_intermediate_release_artifact.dart
```

The second command removes the three review-only legal Markdown files from the
production artifact. The source files remain intact for review and testing, but
their routes remain inaccessible in the public application.

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
  Stripe Checkout Session in `payment` mode for quantity 1 and exactly £249
  GBP, explicitly applies the approved automatic-tax setting, always creates a
  Stripe Customer after Checkout completion, prefills the Customer email, and
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
registration and keeps the email and attempt ID in tab-scoped browser session
storage for an explicit payment retry. A retry therefore does not resubmit the
registration and, while Stripe retains the idempotency result, reuses the
logical Checkout creation. This is not durable exactly-once behavior: no D1,
KV, Durable Object, or other payment database exists. A lost response after
Stripe's idempotency retention window, cleared tab storage, an independent
browser session, or an expired Checkout Session can require a new attempt and
may produce another unpaid session. In the original browser tab, an explicitly
retried expired session rotates only the payment attempt and does not resubmit
registration; without that tab state, the UI fails safely to support guidance.
Stripe remains the only purchase record; customers must not be treated as paid
from a redirect alone.

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
must be tax-inclusive so the customer-facing total remains exactly £249
whether the separately approved automatic-tax setting is enabled or disabled.

`.github/workflows/deploy-founding-friend-payment-worker.yml` is a separate,
manual-only validation and deployment workflow and has not been run. Later
external setup requires Cloudflare Environment variables
`PAYMENT_CREATION_ENABLED=false`, `STRIPE_PRICE_ID`,
`STRIPE_EXPECTED_LIVEMODE`, `STRIPE_AUTOMATIC_TAX_ENABLED`,
`PUBLIC_APP_ORIGIN=https://funapp.world`, and
`CLOUDFLARE_ACCOUNT_ID`; Cloudflare/GitHub secrets `STRIPE_SECRET_KEY`
(prefer a least-privilege restricted key), `PURCHASE_REFERENCE_SECRET`, and
`CLOUDFLARE_API_TOKEN`; a unique rate-limit namespace for source ID `1002`;
and exact route attachment for the two payment paths. No Product, Price,
credential, secret, route, binding, GitHub Environment value, or deployment is
created by this repository change.

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

Pull requests targeting `main` run both Worker projects' typechecking, tests,
and dry-run validation plus Flutter formatting, generation, analysis, the full test suite
with coverage, and a production compile through
the read-only `PR Checks` workflow. These checks do not deploy anything.

Pushes to `main` and manual workflow dispatches run the GitHub Pages workflow.
The `dev` branch has no separate deployment workflow or Pages environment.
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
