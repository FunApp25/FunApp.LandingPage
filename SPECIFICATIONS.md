# Fun App Landing Page Specification

## 1. Purpose

This repository owns the public Fun App website and landing page. The site should communicate the Fun App product and brand through responsive public marketing content.

The landing page is expected eventually to collect information from interested
users. Flutter production submits Venue enquiries to the deployed same-origin
first-party venue-interest boundary; its Cloudflare Worker maps to HubSpot
outside the browser. The venue CTA now navigates to the dedicated `/venues`
hash route, whose localized form preserves the established application and
data workflow. That form shows the approved informational
privacy acknowledgement with a presentation-local checkbox and links to the
hosted Privacy Notice; it does not submit a consent field. The Here & Now and
Founding Friend forms are public routes at `/here-and-now` and
`/founding-friend`. Each has an independent domain model, provider-neutral
repository contract, and application BLoC. Development can explicitly select
temporary direct HubSpot testing or a first-party local Worker transport backed
by deterministic mocks. The default development graph and every production
graph remain fail-closed without registration I/O.

After a confirmed Founding Friend registration, the implemented purchase
workflow can prepare a separate one-time Stripe-hosted Checkout with a
£249 GBP base price and Stripe Adaptive Pricing through
`cloudflare/founding-friend-payment-worker/`. That Worker is independent of the existing forms Worker and is the only Stripe boundary. It
stores the purchase reference and payment record in Stripe, verifies a
specific Checkout Session before Flutter displays payment confirmation, and
uses no D1 or other payment database. Local development is fully mocked. New
payment creation and Founding Friend registration both remain disabled in
production pending separate external configuration and authorization.

The repository also prepares an isolated staging composition for
`https://staging.funapp.world`. Staging keeps Venue submissions deterministic
and local to Flutter, sends Here & Now and Founding Friend registration to a
staging-only no-I/O Worker entrypoint, and sends payment requests to a separate
Worker pinned to Stripe sandbox mode. The operator confirmed on 2026-10-31
that staging resources and GitHub environment configuration exist and sandbox
Checkout plus payment verification passed after purchase-reference secret
rotation. Hosted state is managed externally and was not reverified by the CI
implementation.

## 2. Decision model

Decisions use three statuses:

- **Established:** approved project truth that implementation must preserve unless deliberately changed.
- **Provisional:** intended direction that may change as requirements or evidence develop.
- **Open:** unresolved; implementation must not silently decide it.

Current implementation is evidence of repository state, not automatically a permanent product decision.

## 3. Current status

### Established

- This is a single Flutter project with package name `fun_app_landing_page`.
- Flutter targets web only. Mobile and desktop platform scaffolds are out of scope.
- Flutter and Dart commands use Puro environment `fun-app-landing`, which tracks Flutter stable.
- Flutter Web is the active production implementation. The migration from Astro is complete.
- The current Ready-for-Dev design in Figma file
  `J326dKMVr5dHcC92xLkfbm`, frame `2190:1567` (`Landing Page - V1`), is fully
  represented in Flutter, including the current three-tier Membership design
  and Founding Friend explanation section. Its static and responsive
  presentation is stable, and its current restrained motion pass is complete
  before business, domain, application, or data implementation.
- Fun App logos and decorative shapes are established under `assets/branding/`; active presentation paths are centralized through the project asset helper.
- The Flutter shell retains the platform-neutral typography and Material 3
  foundation adapted from the main Fun App application. The current Figma
  landing-page design is authoritative when its visual tokens differ from that
  starting point.
- The Flutter Web host scaffold uses the Fun App symbol for favicon and PWA icon artwork.
- Dart analysis follows the main Fun App Flutter project's `very_good_analysis` policy.
- Flutter generated localization supports complete application-UI catalogs for
  English, Spanish, Welsh, and Belarusian; English is the source and the
  fallback for unsupported locales. The canonical Privacy Notice legal prose
  remains English until separately approved legal translations are supplied.
- GitHub Pages is the production hosting and deployment target at `https://funapp.world`.
- GitHub Pages builds Flutter directly through `subosito/flutter-action@v2` and
  publishes `build/web` from the repository root at base href `/`; local Flutter
  and Dart commands continue to use Puro.
- The approved English Fun App Ltd Privacy Notice is hosted at
  `https://funapp.world/#/privacy`. Its canonical website source is
  `assets/legal/privacy_notice.md`; the hash route supports direct access,
  refresh, and browser history without requiring a GitHub Pages rewrite.
- Footers expose only Privacy Policy. Terms of Use, Refund & Cancellation
  Policy, Cookie Policy, and Cookie Banner are hidden and their direct routes
  redirect to `/`. Those documents remain English review-only documents that do
  not save preferences or control cookies. Cookie Policy reuses the
  self-contained cookie section from the canonical approved Privacy Notice
  without duplicate legal copy. Approval of a standalone Cookie Policy remains
  open.
- Landing, form, success, Privacy, and legal-document pages use one reusable
  viewport-aware scrolling shell. When content is short, the shared footer
  rests at the bottom of the available viewport; longer or text-scaled content
  expands into normal scrolling without a fixed overlay, artificial spacer
  section, or clipping.
- The landing and shared routed-page footers open the hosted Privacy Notice in
  the current app tab. The venue form shows
  the approved English privacy acknowledgement immediately before submission,
  with an inline link that opens the same page in a new tab, preserving the
  current form draft. Its checkbox is presentation-local, optional, and
  non-persistent. This disclosure remains informational: no submitted consent
  field is required for the current MVP.
- `web/CNAME` is the active repository declaration for `funapp.world`; the external GitHub Pages custom-domain setting remains authoritative.
- `web/robots.txt` owns the active crawler policy.
- Flutter production posts Venue enquiries to the same-origin, unauthenticated
  `POST /api/venue-interest` endpoint. Browser code sends only the Fun App
  request contract and has no HubSpot identifiers, fields, or direct endpoint.
- `cloudflare/venue-interest-worker/` is the repository-controlled,
  independently testable Worker project targeting the existing
  `funapp-venue-interest` Worker. Its code implements `POST
  /api/venue-interest`, `POST /api/registrations/here-and-now`, and `POST
  /api/registrations/founding-friend`. Only the Venue endpoint is currently
  routed and active in production; registration routes and activation remain
  unprovisioned. It has no route, account ID, or zone ID in repository
  configuration. Its source-controlled
  GitHub Actions deployment is manual only and uses the GitHub `production`
  Environment for runtime bindings and Cloudflare authentication. GitHub Pages
  remains the web origin for every other path.
- The deprecated pre-Flutter Astro implementation is archived under `archive/astro_site/` for historical reference only. It is not active application code, built by CI, or deployed.
- The Here & Now and Founding Friend forms are responsive public routes backed
  by separate provider-neutral registration models, repository contracts, and
  application BLoCs. Explicit development selection uses either the public
  unauthenticated HubSpot Forms endpoint or the local mocked first-party Worker;
  unconfigured development and all production builds use deferred repositories
  that perform no registration network or persistence operation. Here & Now
  retains its established terminal success. Founding Friend instead continues
  from confirmed registration into its independent Checkout workflow.
- `cloudflare/founding-friend-payment-worker/` is a separate, independently
  testable TypeScript Worker for Checkout creation and read-only session
  verification. Flutter contains no Stripe SDK or credential. Creation is
  disabled by default; verification remains independently available for
  recovery. The existing Venue Worker, its bindings, and its deployment remain
  unchanged.
- `lib/main_staging.dart` selects an isolated hosted dependency graph. It uses
  `https://staging.funapp.world` for both first-party registration and payment
  API families, uses no browser-side provider credential or arbitrary endpoint,
  and does not change `lib/main_prod.dart`.
- The existing registration Worker project has a named `staging` environment
  deploying as `funapp-venue-interest-staging`. Its distinct `src/staging.ts`
  entrypoint accepts only the two exact registration paths on the staging host,
  requires exact staging enablement plus its rate-limit binding, and injects a
  deterministic no-I/O adapter. It has no HubSpot portal or form identifier and
  cannot fall back to HubSpot. The production entrypoint does not select this
  adapter from a request or binding.
- The payment Worker has a named `staging` environment deploying as
  `funapp-founding-friend-payment-staging`. Its distinct `src/staging.ts`
  entrypoint accepts only the two exact payment paths on the staging host,
  requires `STRIPE_EXPECTED_LIVEMODE=false`, fixes the public origin to staging,
  and rejects non-restricted or non-sandbox Stripe keys before provider I/O. The
  source environment retains fail-closed Price/tax placeholders and a disabled
  creation default for local validation. Automatic deployment removes those
  defaults and explicitly supplies reviewed sandbox environment values, including
  required creation enablement; automatic tax remains disabled.
  Its rate-limit namespace is distinct from production and registration.
- Staging hosting uses the independent Cloudflare Workers Static Assets project
  in `cloudflare/staging-site-worker/`, deploying with Worker identity
  `funapp-landing-staging`. It has SPA fallback for non-asset navigation and a
  minimal Worker-first `/api` handler that returns `404` when no more-specific
  API Worker Route exists. Its `workers.dev` and preview URLs are disabled, and
  it declares no route or Custom Domain. The prepared staging artifact removes
  the production `CNAME`, removes review-only legal assets, uses a staging
  canonical URL, and adds HTML, robots, and response-header noindex controls.
  Cloudflare Access remains the required access-control boundary; noindex is not
  authorization.

### Open

- The final landing-page content, information architecture, and interaction details.

## 4. Scope

### Established

- Public Fun App product and brand communication.
- Responsive Flutter Web presentation.
- Deliberate public-web, accessibility, and SEO behavior throughout implementation and release work.
- Approved Here & Now waitlist and Founding Friend sign-up fields, copy,
  domain validation, application submission lifecycles, and route navigation.
- One-time £249 GBP base-price Founding Friend Stripe-hosted Checkout preparation
  with Stripe Adaptive Pricing, backend-verified payment status, purchase-reference confirmation, and fully
  deterministic local mock behavior without external service configuration.

### Provisional

- Collection of deliberately defined interested-user information.
- Azure hosting may be considered later, but it is not current deployment scope.

### Open

- Any future submitted marketing-consent contract, analytics, and marketing behavior.
- Prospective-user backend, API, authentication, retention, deletion, and
  error-handling contracts.
- Approved Terms of Use, Refund & Cancellation Policy, and Cookie Policy copy,
  plus the production cookie-consent/preferences solution.

## 5. Repository shape

The repository is an active Flutter Web project:

- `lib/` contains the Flutter bootstrap, active presentation, and the first
  venue-lead domain/application/data foundation.
- `lib/l10n/` contains committed ARB localization inputs; generated localization Dart files remain uncommitted.
- `assets/branding/` contains reusable Fun App logos and decorative brand shapes.
- `assets/legal/privacy_notice.md` is the canonical website representation of
  the currently approved English Privacy Notice.
- `assets/legal/` also contains explicitly review-only Markdown documents for
  unresolved legal routes; the Cookie Policy route reads its copy from the
  canonical Privacy Notice instead of a second document.
- `test/` contains tests for active Flutter behavior.
- `web/` contains the Flutter Web host scaffold and canonical web-root static inputs, including `CNAME` and `robots.txt`.
- `cloudflare/venue-interest-worker/` contains the isolated TypeScript
  first-party forms Worker and its focused tests; it is not part of
  Flutter's `lib/` architecture.
- `cloudflare/founding-friend-payment-worker/` contains the isolated Stripe
  Checkout and payment-verification Worker, deterministic mocks, and focused
  tests. It has no storage binding and is deployed separately, if authorized.
- `cloudflare/staging-site-worker/` contains the staging-only Static Assets
  hosting configuration and minimal fail-closed `/api` handler. It does not
  contain either API integration and declares no route or Custom Domain.
- `archive/astro_site/` contains the deprecated pre-Flutter Astro implementation for historical reference only; it is outside the active architecture.
- `.github/workflows/deploy.yml` validates and builds Flutter directly through
  `subosito/flutter-action@v2`, uploads `build/web`, and deploys it through
  GitHub Pages.

Flutter code uses `presentation`, `application`, `domain`, `data`, and `core`
areas only when active behavior needs them. `domain` is active for reusable
validation and provider-neutral submission models. The active `application`
surfaces own the Venue, Here & Now, and Founding Friend form BLoCs. `data/venue`
owns one provider-neutral repository, its DTO, first-party request model, and
environment-specific data sources. `data/user_registration` contains the two
workflow repositories, direct HubSpot and first-party Worker development data
sources and request mappings, and fail-closed repository implementations.
`application/founding_friend_payment` owns separate Checkout preparation and
reloadable payment-verification BLoCs. `domain/founding_friend_payment` defines
provider-neutral contracts and statuses. `data/founding_friend_payment` owns
the payment Worker client, deferred repository, and tab-scoped pending-attempt
store.
`core` owns typed
environment selection, public development configuration, and dependency
composition. The landing-page repository
aligns architectural concepts with the main Fun App Flutter application where
appropriate, but the repositories do not share source code or packages.

## 6. Architecture

### Established direction

Architecture is layer-first where application behavior justifies separation:

- **presentation** owns Flutter UI and may depend on application/domain abstractions and shared presentation code.
- **application** coordinates state and workflows and depends on domain abstractions.
- **domain** contains pure Dart entities, value objects, validation rules, and contracts. It contains no Flutter, web-host, vendor, or raw API implementation concerns.
- **data** implements repositories, data sources, DTO/boundary mapping, and raw external I/O.
- **core** may own bootstrap, configuration, environment handling, dependency wiring, and genuinely shared application infrastructure. It must not become a miscellaneous folder.

BLoC/Cubit is the intended application-state pattern when real state or workflows exist. Static content does not require blocs merely for architectural consistency.

Stable rules for user input intended for backend submission should live in appropriate domain value objects or validation, with application coordination as needed. UI validation alone is not a backend security or integrity boundary.

Repositories and data sources should be introduced when backend interaction exists. Flutter widgets must not perform raw backend I/O, and vendor/backend details must not leak into widgets or stable domain contracts.

Do not introduce layers, folders, abstractions, or dependencies before active code requires them. There is no default `use_cases/` layer.

## 7. Presentation and responsive web baseline

### Established direction

- Responsive layouts are constraint-driven.
- Use `LayoutBuilder` for local adaptive decisions.
- Use `MediaQuery.sizeOf` when application or window sizing is genuinely needed.
- Avoid device-name assumptions such as an “iPhone layout.”
- Keep app-owned widgets focused and reusable; avoid deeply nested monolithic `build` methods.
- Define reusable design values centrally when a real design system is introduced.
- Keyboard interaction, focus visibility, reduced motion, meaningful controls, and appropriate Flutter web semantics are part of implementation quality.
- Exact Figma colors remain authoritative for the current landing-page design.
- Known contrast limitations in those approved colors are temporarily accepted
  and remain an explicit design and accessibility review item before
  production. Keyboard focus remains deliberately stronger than Figma because
  the static source design does not define interaction states.

The active presentation foundation centralizes established Fun App color,
typography, sizing, and Material 3 theme values. The complete section topology,
desktop typography, and broad desktop color rhythm follow Figma `Landing Page -
V1`. Responsive adaptations are constraint-driven where Figma does not supply
a targeted mobile frame; the current FAQ and Footer use their approved 390px
mobile frames. Research statistics use four, two, or one column as
available width decreases; desktop card minimum heights do not automatically
apply to single-column phone cards. Major section, statement, and FAQ type roles
scale down deliberately on narrower viewports while preserving the desktop
Figma values.

Landing presentation ownership is section-oriented under
`lib/presentation/landing/sections/`: every landing section or surface owns an
explicit directory, and its section-specific widgets live alongside it. Each
landing Widget class has its own Dart file, apart from the private State class
associated with a StatefulWidget, and landing widget components are public so
they are not hidden inside another widget file. Widgets used by multiple
sections live under `lib/presentation/landing/shared/widgets/`; pages, localized
presentation content, and landing theme values remain under `pages/`,
`content/`, and `theme/` respectively.

Implemented landing sections preserve their Figma desktop compositions. Their
narrower wrapping, stacking, and card reflow are constraint-driven
implementation inferences because Figma provides no responsive variants. Hero
artwork remains a single, aspect-preserving image edge-anchored and clipped at
the upper-right of the card in every responsive composition. When the wide copy
and artwork regions no longer fit together, the copy clears the artwork
vertically instead of moving the artwork below the copy; source and semantic
order remain logical without duplicating the image. Founding Friends and venue
promotional cards use content-driven wide, intermediate, and narrow
compositions. Their narrow layouts remain copy-first, and committed raster
artwork preserves its intrinsic aspect ratio through sizing, alignment, and
clipping rather than geometric distortion. Founding Friends artwork remains
anchored to the trailing edge, while venue artwork remains anchored to the
leading edge.

Below a 600px outer viewport width, Founding Friends and Venue use vertical,
centered promotional cards with 16px internal horizontal bounds, an 80px
content/artwork rhythm, and full-width visual-only CTAs. Their artwork
intentionally overscans horizontally but is clipped by the card, and final
heights remain content-driven for localization. The existing one-time card
reveals remain. At 600px and above the established promotional-card
compositions remain in use; CTA constraints must remain overflow-safe across
the 599px/600px boundary.

The current landing-page order is Header, Hero, Problem Statement, Research
Statistics, Different Way to Connect, Membership, Limited-time Founding Friend
offer, Founding Friend explanation, Founding Friends, Venue, Welcome Statement,
FAQ, and Footer. The Header remains fixed outside the primary scrolling
content. Membership presents static Free, Here & Now, and Founding Friend
pricing cards. Those cards and the Founding Friend descriptions are approved
marketing presentation. They do not themselves prove payment, entitlement, or
membership activation. The Founding Friend form can continue to the separately
implemented one-time £249 GBP base-price purchase workflow with Stripe Adaptive
Pricing; subscriptions, immediate entitlement, badges, and other membership behavior remain unimplemented. The
pricing controls retain their approved appearance and navigate to the public
`/here-and-now` and `/founding-friend` routes.
Pricing cards use three, two,
or one column based on usable card width, and Founding Friend benefit cards
similarly reflow from the desktop intro-plus-three-card composition without
forcing desktop heights onto narrow single-column layouts.

Header and footer section navigation scrolls within the single landing page
while the header remains fixed above the scrolling content. The header and
footer expose the same four active anchor destinations. Below a 600px
outer viewport width, the fixed header uses a compact logo, the localized
"Join the queue" action, and burger composition. The CTA remains a single-line,
content-sized control with a minimum 44px target and overflow-safe constraints.
The burger
opens a full-screen, presentation-local menu
with the same four header anchor destinations; selecting one closes the menu
before reusing the existing anchor navigation. At 600px and above, the
established wide, intermediate, and narrow constraint-driven header variants
remain in use; larger text can select the intermediate composition when the
single-row header no longer fits. Internal navigation controls provide at least
a 44px effective target and an explicit keyboard-focus outline; hover and focus
treatments cover the complete padded control surface. The active header mapping
is Our Belief to Hero, Membership to Membership, Founding Friends to Founding
Friends, and For Venues to Venue. Anchor positions derive from the rendered
sections. Navigation duration scales with the current viewport-normalized
distance and uses `easeInOutCubic`; a higher bounded duration gives long jumps
enough time to accelerate, travel, and decelerate while nearby targets remain
responsive.
Brief hover interpolation applies only to internal navigation backgrounds;
keyboard focus remains immediate. Navigation movement and hover interpolation
become immediate when reduced motion is requested. The localized
header/mobile-menu queue action, Limited Offer queue CTA, Free Membership CTA,
Here & Now membership CTA, Lifetime Membership CTA, and Founding Friends
prospective-user CTA navigate to their established `/here-and-now` or
`/founding-friend` mappings. The routes contain the implemented registration
workflows; production registration remains disabled. A confirmed Founding
Friend registration proceeds to Checkout preparation, while a return redirect
is verified through `/founding-friend/payment` and cancellation renders
`/founding-friend/payment/cancelled`. Reloading either payment route never
creates another Checkout Session. The venue CTA
navigates to the dedicated `/venues` page. A fresh
`VenueLeadFormBloc` owns each Venue route lifecycle and submits through the
established environment-selected venue repository/data-source graph. Shared
header and footer navigation returns to `/` with a render-derived landing
section target rather than trying to scroll keys that are absent on `/venues`.
The shared header and footer logos push a landing-page root entry with the
requested rendered anchor. Routing uses `auto_route`, generated typed route
classes, and `MaterialApp.router`; the landing-section target is a typed route
argument. Router-managed in-app pushes preserve sequential history for repeated
browser Back and Forward operations without custom browser-history
manipulation. Direct hash routes initialize only the requested route rather
than fabricating a prior landing-page history entry. Unknown routes redirect to
the landing page.

Below a 600px outer viewport width, Research statistics use a horizontal,
page-snapping carousel with one primary card, a trailing adjacent-card peek,
previous/next controls, and four decorative page indicators. The carousel is
clamped and non-looping pending explicit contrary design direction. At 600px
and above, the established responsive Research grids remain in use.
The Great Friendship Project attribution links to
`https://friendship-project.co.uk/` in a new tab and uses the established warm
orange link treatment. Other source names in that line use bold text emphasis
without link styling.
The mobile Research scroll accent reveals the initial carousel viewport and
navigation once as a single group rather than staggering offscreen cards;
reduced motion renders that group immediately and makes programmatic page
changes immediate while preserving direct swipe interaction.
The Figma-responsive mobile Research card height remains a minimum. When
localized or scaled text needs more room, every carousel page shares the
tallest required height so text is not clipped or truncated to preserve the
design minimum.

Below a 600px outer viewport width, the three Founding Friend benefits use the
shared horizontal, page-snapping carousel with three decorative page indicators
derived from the real content count, matching the three indicators now present
in Figma node `2270:2640`. The carousel is clamped and non-looping. At
600px and above, the established Founding Friend cards and grids remain in use.
Founding Friend has no scroll-entry reveal, and reduced motion makes its
programmatic carousel page changes immediate while preserving direct swipe.

Below a 600px outer viewport width, Problem, Membership, Limited Offer, Welcome,
and FAQ opt into the approved mobile 16px page bounds and section-specific
Figma rhythm and type roles. Membership remains a one-column, naturally sized
pricing-card stack with its approved reveal unchanged. Its Founding Friend
supporting line follows the distinct approved mobile copy. FAQ retains its
existing independent expansion, semantics, focus, and motion behavior while using its
mobile-specific spacing and type. Marketing copy remains shared across
responsive layouts unless product or design explicitly changes it.

Below a 600px outer viewport width, Hero uses a dedicated centered-overflow
composition with one artwork instance clipped by the Hero card and centered
copy beneath a reserved artwork region. Its height remains content-aware for
localization, and Hero remains static. Connection uses leading-aligned copy,
16px horizontal bounds, 80px vertical section padding, and a near-square
`BoxFit.cover` image crop. The approved Connection copy remains shared across
responsive layouts and preserves its two-paragraph structure. At 600px and
above, Hero and Connection use their established wider compositions.

Below a 600px outer viewport width, Footer uses the approved centered 16px/80px
mobile composition: the four anchor controls wrap beneath the logo and a divider
separates them from the `mailto:info@funapp.world` contact link. At 1200px and
above, logo/navigation and
email/legal content form the two approved desktop rows around the full-width
divider;
intermediate widths stack those groups without fixed heights or horizontal
overflow. Privacy Policy opens the authoritative hosted Privacy Notice and is
the only legal control visible. Terms of Use, Refund & Cancellation Policy,
Cookie Policy, and Cookie Banner remain inaccessible until their approval and
release requirements are resolved; their presence establishes no consent
behavior.

The approved FAQ contains 13 independently expandable items. Expansion state
is local to the presentation widget, the first item starts expanded, and the
remaining items start collapsed. Expanding one item does not collapse another.
FAQ expansion grows naturally within the existing scrolling page. The complete
visible surface of an FAQ item toggles it for pointer input, while the question
remains the focused expanded/collapsed control for keyboard and assistive
technology and expanded answer text remains independently readable semantic
content. Hover and keyboard-focus treatments cover that complete clickable
surface, with an internal horizontal content inset, without merging the answer
into the question control's semantic label. Answer height and opacity transition
locally, the state icon fades between plus and minus, and the hover background
interpolates briefly. Keyboard focus remains immediate. Reduced motion removes
those transitions while preserving the final state and all feedback. The Hero
renders statically. At 600px and above, the Research Statistics cards receive
one restrained rise-and-fade reveal with a short group stagger; it triggers
deeper in the viewport and uses a slightly stronger, slower settlement than
the other accents. The three Membership pricing cards receive one subtle
trailing-side-to-final fade reveal while the Membership introduction remains
static. The complete Founding Friends promotional card receives one subtle
trailing-side-to-final reveal, and the complete Venue promotional card receives
one subtle leading-side-to-final reveal while its introduction remains static.
These four surfaces are the complete scroll-entry animation set. Each runs once
per mounted landing page, and reduced motion renders all four surfaces
immediately in their final state. All other landing sections remain static.
Safe Guard, Footprint, reporting, subscription, and moderation statements in
FAQ copy describe future product behavior only and do not establish those
capabilities as implemented.

### Localization baseline

- Supported locale identifiers are English (`en`), Spanish (`es`), Welsh (`cy`), and Belarusian (`be`). English is the authoritative source language and unsupported locales fall back to English.
- Flutter's generated localization system uses ARB inputs under `lib/l10n/`, configured through `l10n.yaml`.
- Locale negotiation follows the browser or platform locale. The application does not force a locale.
- The host document language follows Flutter's resolved application locale; the static web shell defaults to English before Flutter starts.
- No language selector or persisted manual locale choice exists yet.
- User-facing Flutter copy must come from generated localizations rather than hardcoded presentation strings. Approved new English source copy may use the established English fallback in other supported locales when translation completion is explicitly deferred and tracked.
- Locale-specific product and marketing copy remains subject to product and translation review as content expands.
- `Fun App`, `Here & Now`, `Founding Friend`, `Safe Guard`, and `Footprint` are
  protected product names across locales. Membership, Venue, and Waitlist are
  generic terms and use natural locale-specific equivalents. Country controls
  localize their display labels from Unicode CLDR while preserving the existing
  HubSpot-compatible stored values.

## 8. User input and future backend direction

### Established

- The Here & Now UI requires first name, last name, email, and integer age;
  gender and usage reason are optional. The Founding Friend UI adds required
  country while keeping gender and usage reason optional. Both forms expose a
  separate optional marketing-consent checkbox that starts unchecked and does
  not block local validation.
- Domain validation rejects blank required names, structurally invalid email,
  non-integer age input, and a missing Founding Friend country. It does not
  invent an age threshold. Presentation exposes those application-coordinated
  errors after a submit attempt. This validation is usability only and does
  not authorize production collection without matching backend validation.
- Current live HubSpot contact properties are `firstname`, `lastname`,
  `email`, `age`, `gender`, `country`, `usage_reason`, and
  `marketing_consent`. Gender stores `Man`, `Woman`, `Non-binary`, or
  `Prefer not to answer`. The Founding Friend country control uses the complete
  live `country` property label/value set captured in the English localization
  source rather than a shortened list. Its localized labels are searchable by
  case-insensitive partial name while selection retains the stable live value.
- Development integration references portal `149114580`, Here & Now form
  `3284e6bc-e3a2-4d2e-9e21-684399126f3b`, and Founding Friend form
  `39f027d9-e786-4768-b532-54ed44e1f718`. The identifiers are public and are
  supplied to development builds through `FUN_APP_HUBSPOT_PORTAL_ID`,
  `FUN_APP_HUBSPOT_HERE_AND_NOW_FORM_GUID`, and
  `FUN_APP_HUBSPOT_FOUNDING_FRIEND_FORM_GUID`; no private HubSpot credential is
  present in Flutter source or the browser bundle.
- `HereAndNowRegistration` and `FoundingFriendRegistration` are independent
  provider-neutral domain aggregates. Each has its own repository contract and
  form BLoC so the workflows can evolve without sharing payment, membership,
  or transport behavior. They reuse established name, email, single-line text,
  failure, and value-object foundations. `Age` requires only an integer and
  deliberately applies no eligibility threshold.
- Both BLoCs own editable drafts, validation-attempt visibility, pending state,
  semantic success/failure, retry, duplicate in-flight suppression, and stale
  completion rejection. Optional gender, usage reason, and marketing opt-in do
  not block submission. Founding Friend additionally requires country.
- Development resolves direct-HubSpot repositories only when that transport is
  explicitly selected and all three public identifiers are valid. It resolves
  the Worker-backed repositories only when the local Worker transport and a
  valid loopback origin are explicitly selected. Otherwise it resolves deferred
  repositories that return service unavailable without I/O. Production always
  resolves the deferred repositories, even if development settings are supplied.
  Confirmed Here & Now success replaces the submitted form with its established
  branded membership-specific confirmation. Confirmed Founding Friend
  registration does not render the prior terminal registration acknowledgement;
  it starts the separate Checkout-preparation BLoC with the validated email and
  a new opaque attempt ID. Retrying payment reuses that attempt and never
  resubmits HubSpot registration.

- The prospective-venue lead contract is provider-neutral and lives in
  `domain`. It uses `dartz` `Either` for validation results and `Option` for
  meaningful absence.
- Reusable pure-Dart value objects retain invalid editable input without
  throwing. Required strings reject whitespace-only content, single-line text
  rejects carriage returns and newlines, email validation is structural, and
  website validation accepts plausible DNS-style domains such as
  `example.com` and `venue.co.uk`, with or without an HTTP or HTTPS scheme,
  while rejecting malformed and non-web addresses.
- Domain validation does not trim, lowercase, rewrite, or otherwise normalize
  submitted text. Phone numbers are stored as strings, preserve leading zeroes,
  and, when present, accept decimal digits only. Venue count and venue capacity
  are optional positive integral quantities with no established upper bound.
- `VenueLead` requires venue name, website, contact first name, contact last
  name, role, and email. Venue type, independent/chain status, venue count,
  venue capacity, and phone number are optional.
- Present venue type and independent/chain status values are non-empty
  single-line text. The UI presents chain status as optional Independent or
  Part of chain choices using stable string values; this does not change the
  provider-neutral/domain contract. Venue count appears only for a chain and
  is cleared when switching away. Venue count and capacity controls accept
  digits only while domain validation still enforces positive integers.
  The conditional venue count expands and collapses with reduced-motion support,
  and its visible label is "Number of venues" in English.
  The venue information group and text inputs retain their established styling
  while the routed page shell is aligned separately. Detailed form-control
  restyling remains deferred to the dedicated Venue form pass.
- Generated Auto Route, Freezed, and Injectable source is regenerated locally
  and in CI and remains uncommitted.
- `VenueInterestRequest` is a data-layer first-party request model. It emits
  only `venueName`, `venueType`, `chainStatus`, `venueCount`,
  `venueCapacity`, `website`, `firstName`, `lastName`, `role`, `email`, and
  `phoneNumber`. Required values are always emitted; absent optional values
  are omitted. Venue count and capacity are JSON integers, and phone numbers
  remain strings so leading zeroes survive unchanged.
- Operational submission failures are provider-neutral `AppFailure` values,
  distinct from field-level `ValueFailure` values. The initial operational
  categories are service unavailable, submission rejected, and unexpected.
  They expose no provider codes, transport details, raw exceptions, or
  presentation-facing messages.
- `VenueLeadRepositoryInterface` is the domain submission boundary. Its
  `submitVenueLead(VenueLead)` operation performs one logical venue-interest
  submission and returns `Either<AppFailure, Unit>`; `Unit` acknowledges only
  application-level success.
- `VenueLeadFormBloc` owns the editable venue-lead draft, raw field-input
  interpretation, validation-attempt visibility, submission state, and the
  semantic submission result. Invalid domain values block repository calls and
  remain `ValueFailure` values rather than becoming operational failures.
- Blank optional input represents absence. Non-blank optional and required
  input is preserved when constructing the established domain value objects.
- A successful or failed submission preserves the complete form draft in the
  application state. A confirmed successful submission replaces the routed
  form with the responsive Figma success presentation while keeping `/venues`
  as the route. The success state is neither persisted nor reconstructed from
  URL data, so refresh and each later Venue route lifecycle start with a fresh
  BLoC and empty form. Its underlined `info@funapp.world` treatment uses the
  same approved `mailto:info@funapp.world` behavior as the shared footer.
  Operational failure
  keeps the form open and editable for retry, with a concise retry-later
  message above Send.
  While submission is pending, Send is visibly disabled and an indeterminate
  linear progress indicator appears immediately above it.
- The application suppresses concurrent submit events while one repository call
  is in flight. This is client workflow protection, not server idempotency,
  deduplication, or duplicate-lead prevention.
- The draft remains editable during submission. A completed result is exposed
  only when the current draft still equals the submitted snapshot; otherwise
  the stale result is discarded while validation-attempt visibility remains.
- One concrete `VenueLeadRepository` implements the domain repository contract.
  It validates the aggregate before extracting values, translates a valid lead
  into a provider-neutral `VenueLeadDto`, and delegates to
  `VenueLeadDataSourceInterface`. Invalid aggregate input is treated as an
  unexpected repository-boundary failure and does not call a data source.
- Environment/provider variation exists only beneath the repository.
  `development` resolves a deterministic successful development data source
  with no persistence or external I/O. `production` resolves
  `ProductionVenueLeadDataSource`.
- `ProductionVenueLeadDataSource` resolves `/api/venue-interest` against the
  current browser origin and posts the `VenueInterestRequest` JSON with
  `application/json`. It is public and unauthenticated: no bearer token,
  session data, client secret, API key, or CORS workaround is used.
- HubSpot mapping, account/form identifiers, provider validation, and response
  bodies are confined to the Worker boundary and are not required by Flutter.
- Each production submission has a 15-second abortable deadline. A 204 response
  acknowledges success after its response stream is drained without parsing its
  body. Statuses 400 and 422 are submission rejected; 429 and 503 plus known
  HTTP transport failures and deadline aborts are service unavailable; 500 and
  unrecognised statuses are unexpected. No automatic retry occurs.
- Classified data-source service-unavailable and submission-rejected conditions
  map to their matching `AppFailure` categories. Unclassified exceptions map to
  `AppFailure.unexpected`. Data-source exceptions do not cross the domain
  repository boundary.
- The development-only registration data source posts JSON directly to
  `https://api.hsforms.com/submissions/v3/integration/submit/{portalId}/{formGuid}`
  without authentication. It maps `firstname`, `lastname`, `email`, numeric
  `age`, optional `gender`, Founding Friend `country`, optional `usage_reason`,
  and boolean `marketing_consent` to the Forms API's string-valued field entries.
  Absent optional values are omitted. Marketing opt-in is a contact property,
  not processing consent; the request deliberately contains no
  `legalConsentOptions`, tracking cookie, page context, or submitted timestamp.
- Direct registration submissions use one abortable 15-second deadline and no
  automatic retry. A 200 response succeeds; 400 is submission rejected; 429,
  every 5xx response, transport failures, and timeout aborts are service
  unavailable; other statuses are unexpected. Response bodies and submitted
  personal data are neither parsed nor logged.
- `HereAndNowRegistrationRequest` and `FoundingFriendRegistrationRequest` are
  first-party request models. Both emit required `firstName`, `lastName`,
  `email`, integer `age`, and boolean `marketingConsent`; absent `gender` and
  `usageReason` are omitted. Founding Friend additionally emits required
  canonical `country`. They contain no portal/form identifier or HubSpot field
  name.
- `WorkerUserRegistrationDataSource` posts those models to exact local Worker
  paths `/api/registrations/here-and-now` and
  `/api/registrations/founding-friend`. It uses one abortable 15-second deadline
  and no retry. A 204 succeeds; 400/422 are submission rejected; 429/503 and
  transport/deadline failures are service unavailable; 500 and unrecognised
  statuses are unexpected. It neither parses nor logs response bodies.
- GetIt and Injectable own composition now that environment-dependent
  implementations exist. `VenueLeadFormBloc` is a factory registration, the
  repository is a provider-neutral lazy singleton, and core composition
  registers the selected data-source lazy singleton.
  Application and data classes use constructor injection rather than reading
  GetIt or importing application configuration.
- Environment selection is structural: `lib/main_dev.dart` passes the typed
  `AppEnvironment.development` value into bootstrap, while `lib/main_prod.dart`
  passes `AppEnvironment.production`. Development additionally requires an
  explicit `FUN_APP_REGISTRATION_TRANSPORT` selection (`deferred`,
  `direct_hubspot`, or `local_worker`); omission selects deferred. The local
  Worker selection accepts only an HTTP(S) loopback origin. Production ignores
  every development registration selection and remains deferred.
- Flutter production needs no Venue submission runtime configuration. A local
  production browser run resolves the same-origin endpoint to localhost and
  therefore cannot reach the deployed Worker without separate local routing;
  development remains the deterministic fake path.
  Payment configuration instead targets fixed `https://funapp.world` endpoints,
  including in local production-mode runs, subject to browser CORS restrictions.
- The repository-controlled Cloudflare Worker performs exact route dispatch,
  validates each untrusted Fun App request independently, maps to HubSpot only
  at its provider boundary, and obtains public provider identifiers from Worker
  bindings. It rejects unknown properties, malformed JSON, non-JSON content,
  non-safe-integer ages, unsupported canonical gender/country values, and
  requests over 16 KiB. The Flutter Worker transport applies the same exact
  JavaScript integer-serialization and UTF-8 total-body boundaries before I/O.
  It applies no age eligibility threshold and no extra registration field-length
  constraints beyond that total-body limit.
- Registration Worker forwarding is disabled unless
  `REGISTRATION_SUBMISSIONS_ENABLED` is exactly `true`. Activation additionally
  requires valid portal/form IDs and the `REGISTRATION_RATE_LIMITER` binding;
  missing or malformed mandatory configuration fails closed. The binding
  provides approximate, Cloudflare-location-local protection targeting 10
  attempts per 60 seconds per route and connecting-IP key, not a strict
  globally consistent quota. It is an abuse control, not authentication:
  shared IPs may group unrelated users into collective throttling, and requests
  handled in different Cloudflare locations may exceed the nominal aggregate
  rate.
- The Worker preserves the current `HUBSPOT_FORM_GUID` Venue binding as
  authoritative and accepts `HUBSPOT_VENUE_FORM_GUID` only as a fallback alias
  when the established binding is absent. Venue remains
  independent of registration enablement, form IDs, and rate limiting. Every
  provider call is a single attempt with a 10-second deadline. Provider bodies,
  submitted values, request headers, and cookies are not returned or logged.
- Local Wrangler development requires an explicit localhost origin plus one of
  six deterministic mock scenarios. Missing, partial, or invalid local mock
  configuration fails closed, and loopback Venue and registration requests
  never contact HubSpot. Non-loopback execution rejects either local-only
  setting. Local-only CORS responses support the fixed Flutter dev origin;
  production remains same-origin and emits no CORS allowance.
- Founding Friend payment uses the separate first-party Worker endpoints `POST
  /api/founding-friend-payments/checkout-sessions` and `POST
  /api/founding-friend-payments/checkout-sessions/verify`. Request bodies are
  exact-schema JSON and limited to 4 KiB. Creation accepts only validated
  `email` and UUID v4 `attemptId`; verification accepts only a specific
  Checkout `sessionId`. There is no public email-lookup or enumeration API.
- Checkout parameters are server-owned. The Worker first retrieves and validates
  the configured active one-time Stripe Price, including the expected live/test
  environment, GBP currency, fixed 24900 minor-unit amount, tax-inclusive
  behavior, and absence of custom unit amounts. It then requests exactly one
  line item, quantity 1, in `payment` mode, prefills the validated registration
  email, requires `customer_creation=always`, explicitly sends the configured
  automatic-tax boolean, and supplies only fixed return/cancel URLs derived
  from `PUBLIC_APP_ORIGIN`. The client cannot select a Price, amount, currency,
  quantity, mode, tax setting, or redirect.
- The Worker generates a non-email purchase reference in `FF-...` form with a
  server-only HMAC secret and the attempt ID. It records that reference in
  Stripe `client_reference_id`, Checkout Session metadata, and PaymentIntent
  metadata. It also stores the explicit automatic-tax choice in Session and
  PaymentIntent metadata, allowing future verification to validate the
  per-purchase setting independently of a later configuration change. Stripe
  holds the purchase record; no D1, KV, Durable Object, or other payment
  database is used.
- Checkout creation uses the attempt-derived Stripe idempotency key
  `founding-friend-checkout-v1-{attemptId}`. Flutter creates the attempt only
  after confirmed registration and retains its email and attempt ID in
  current-tab session storage for explicit payment retry. This prevents a
  payment retry from resubmitting registration and correlates retries while
  Stripe retains its idempotency result. It is not durable exactly-once
  creation: a lost response after Stripe's retention window, expired session,
  cleared tab state, or independent browser session can require a new attempt
  and can leave another unpaid Stripe Session. Stripe remains authoritative.
- Stripe Adaptive Pricing remains enabled in Stripe settings. The Worker does
  not override it or calculate FX. £249 GBP (24900 minor units) is the original
  tax-inclusive, one-time Price contract; Stripe may collect its localized
  equivalent. Checkout creation still validates the configured active GBP Price
  and requires the creation response to have GBP/24900 totals; no localized
  creation response has been verified. Quantity, tax, references, idempotency,
  fixed redirects, and all creation safeguards remain in place.
- The read-only verification endpoint retrieves the named Checkout Session with
  expanded line items, original Price, PaymentIntent, and latest charge using
  the pinned `Stripe-Version: 2026-08-26.dahlia`. It requires the exact configured
  original GBP/24900 one-time per-unit inclusive Price, quantity 1, the expected
  environment, Customer creation mode, and matching stored automatic-tax choice
  and purchase references. It accepts GBP/24900 Session and payment totals,
  with optional Stripe `presentment_details` describing the localized payment.
  It also accepts localized Session totals when `adaptive_pricing.enabled` is
  true, with the original expanded GBP/24900 Price. Session, sole line item,
  PaymentIntent, and captured charge must agree in that localized currency
  and amount.
  All amounts must be safe integers; totals must be positive, use a recognized
  ISO currency, and reconcile without discounts, shipping, or additional items.
  Inclusive line-item tax must match Session tax; disabled automatic tax cannot
  introduce tax. Every supplied presentment amount/currency must be valid and
  agree across Session, PaymentIntent, and charge; for localized Sessions it
  must also agree with Session totals. Missing or contradictory required data
  and legacy non-null `currency_conversion` shapes fail closed. No exchange
  rate or fixed converted price is assumed.
- A paid outcome additionally requires a valid Customer and an expanded
  successful PaymentIntent with the full amount received, matching Customer,
  livemode, purchase reference, and stored tax choice. Its successful paid,
  captured charge must reference that intent, match the Customer/environment,
  and reconcile the full captured amount. Refund/dispute fields must be valid;
  disputes, full refunds, and partial refunds retain their provider-neutral
  statuses. Other results remain `pending`, `expired`, or `invalid`; only a
  complete, paid Session can return `confirmed` and its purchase reference.
  An unpaid Session can have no PaymentIntent yet or a matching processing
  intent. Refund/dispute checks remain a current-status best effort, not a
  durable event ledger.
- Contract evidence (2026-10-29): Stripe's [Adaptive Pricing
  guide](https://docs.stripe.com/payments/checkout/localize-prices/adaptive-pricing?payment-ui=stripe-hosted)
  and [presentment-details changelog](https://docs.stripe.com/changelog/basil/2025-03-31/add_presentment_details)
  describe integration-currency Session/PaymentIntent totals with separate
  presentment details. A read-only connected Fun App sandbox retrieval instead
  showed EUR/29900 throughout Session, line item, PaymentIntent and captured
  charge, `adaptive_pricing.enabled=true`, the original GBP/24900 inclusive
  Price, and no `presentment_details`. The connector advertised a
  `2026-09-30.preview` operation schema and cannot override the request's API
  version; that is not proof of the pinned Dahlia response. Local tests assert
  the outgoing Dahlia header and cover both representations. A direct pinned-
  version sandbox GET and hosted validation remain unperformed. Neither this
  investigation nor the tests create a Stripe payment or mutate Stripe.
- Flutter trusts neither Checkout redirection nor browser parameters as proof
  of payment. The return route verifies its `session_id` through the Worker and
  shows the purchase reference only for confirmed payment. Cancelled, pending,
  expired, refunded, disputed, invalid, and temporarily unverifiable states
  receive localized recovery guidance. Verification can be retried without
  creating a Session. An explicitly retried expired Session rotates to a new
  payment attempt using current-tab registration state without resubmitting
  registration; missing tab state fails safely to support guidance. The
  confirmation states that membership is not active yet and asks customers to
  use the purchase email for their future Fun App account, whose authenticated
  backend will later verify a qualifying payment against its verified email.
- Flutter accepts Checkout redirects only from exact HTTPS
  `checkout.stripe.com`, or from its exact configured loopback origin in local
  mock mode. Payment requests use a 15-second browser deadline; Stripe requests
  use a 10-second Worker deadline. Errors remain provider-neutral, and neither
  boundary logs or returns emails, names, request bodies, billing/payment
  details, Checkout URLs, credentials, or complete provider responses.
- Payment creation is enabled only when `PAYMENT_CREATION_ENABLED` is exactly
  `true`. Production also requires a valid server-only Stripe key, configured
  tax-inclusive Price, declared expected live/test mode, exact
  `STRIPE_AUTOMATIC_TAX_ENABLED=true|false`, exact HTTPS public origin,
  purchase-reference secret, and `PAYMENT_RATE_LIMITER`; incomplete or
  incompatible configuration fails closed. The Worker always sends the tax
  value and never inherits Stripe's account-level Checkout default.
  Verification is deliberately not coupled to the creation flag, so an
  existing payment can still be recovered after sales are stopped.
- Loopback mock mode requires a matching local Flutter origin and one of the
  deterministic scenarios `created`, `paid`, `pending`, `cancelled`, `expired`,
  `provider_validation_failure`, `payment_mismatch`, `network_failure`,
  `provider_unavailable`, `timeout`, `duplicate_attempt`, `refunded`, or
  `disputed`. It never performs Stripe I/O. Any mock setting in non-loopback
  execution fails closed. `duplicate_attempt` deterministically returns the
  same mock Checkout result for repeated identical attempt IDs and a different
  result for a different attempt; it does not claim durable exactly-once
  behavior.
- The MVP uses Stripe-hosted Checkout and intentionally adds no Flutter Stripe
  SDK, subscription, webhook-driven entitlement, automatic HubSpot payment
  synchronization, account creation, or immediate membership provisioning.
  There is no payment-triggered side effect to fulfill. Any later delayed
  payment method, automatic fulfillment, or asynchronous side effect requires
  a separately approved event/webhook design before launch.

### Open

- An approved consent/privacy field contract and any corresponding HubSpot
  `legalConsentOptions` payload. Consent is not fabricated or submitted by the
  current implementation.
- Independent confirmation of each published registration form's required-field
  set, included fields, legal-consent configuration, and direct-submission test
  result. The former public form-definition lookup returns 404, so this requires
  authorized HubSpot portal inspection or an explicitly authorized synthetic
  submission.
- The current venue privacy acknowledgement is approved informational copy,
  not a consent field. Its optional checkbox state lives only in the routed
  presentation and adds no BLoC state, domain value, DTO property, repository
  property, HubSpot field, or `legalConsentOptions` value.
- Approved venue-type choices and any future provider-side chain-value changes.
- Whether a future approved chain selection makes venue count conditionally
  required. The current domain contract deliberately has no chain/count
  cross-field invariant.
- Prospective-user retention/deletion requirements.
- The minimum/maximum age eligibility policy and corresponding backend rule.
- Whether approved display labels should differ from the confirmed HubSpot
  gender values, and any explicit reversible mapping if they do.
- Ongoing synchronization of the HubSpot country option source before
  integration and release.
- Approved tax treatment, the corresponding explicit automatic-tax setting,
  Stripe Tax configuration and registrations if enabled, Refund & Cancellation
  Policy, Terms of Use, supported payment methods, dispute/support process, and
  the exact legal copy required around purchase. The implementation does not
  invent these terms.
- The later main Fun App backend contract for matching a qualifying Stripe
  purchase to an authenticated account's verified email and granting benefits.
- Timing and authorized deployment of the updated Worker, registration route
  attachment, payment Worker route/binding/secret configuration, controlled
  live verification, and any future production Flutter switch to the
  first-party registration transport.

Backend implementation must be driven by an actual approved contract rather than inferred from the main mobile application. Do not copy `/profiles`, Entra, OIDC, user-profile, onboarding, or other mobile-app contracts into this project without an explicit landing-page requirement.

## 9. Cybersecurity and privacy

### Established requirements

- Apply privacy by design and privacy by default.
- Minimize collected data to the defined purpose.
- Never place secrets or credentials in Flutter client code, configuration, examples, or built web bundles.
- Treat every value embedded in Flutter Web as publicly recoverable, including values injected by CI.
- Client-side validation improves usability but is not a security boundary; backend validation and authorization must exist where applicable.
- Do not include personal information in logs, analytics, diagnostics, crash reports, fixtures, or examples without explicit, justified handling.
- The first-party forms Worker must not log request bodies, submitted field values,
  HubSpot payloads, HubSpot response bodies, or request headers/cookies. It
  returns only provider-neutral response codes and opaque request IDs.
- The payment Worker must not log emails, names, request bodies, Checkout URLs,
  billing or payment details, Stripe credentials, or complete Stripe responses.
  Its public responses remain provider-neutral and expose a purchase reference
  only after verified payment.
- Use HTTPS for production backend communication.
- Validate untrusted backend responses at data boundaries.
- Avoid unnecessary third-party scripts and SDKs.
- Do not add analytics, advertising, non-essential cookies, session replay,
  marketing pixels, or visitor-profiling telemetry while the approved Privacy
  Notice states that those technologies are not currently used.
- The approved Privacy Notice legal prose is maintained in
  `assets/legal/privacy_notice.md`. It must not be changed casually. A future
  approved notice must replace or update that canonical source from the newly
  approved document without independent rewriting or translation.
- Evaluate dependency changes for supply-chain, maintenance, privacy, and data-handling impact.
- Settle consent, retention, and deletion requirements before collecting the corresponding personal data.
- Never introduce client secrets into this public web application.

## 10. SEO, accessibility, and public-web requirements

Flutter does not automatically provide Astro-equivalent SEO or server-rendered semantics. SEO strategy is an explicit implementation and release concern.

The redesign must deliberately address, as appropriate:

- Document title and meta description.
- Canonical URL.
- Open Graph and other social metadata.
- Favicon and site icons.
- `robots.txt`, indexing behavior, and route visibility.
- Sitemap when justified by the final content and route model.
- Crawlability and discoverability limitations of Flutter Web.
- Appropriate page/document semantics and Flutter web semantics.
- Keyboard operation, focus visibility, reduced motion, meaningful links, and meaningful controls.

The Flutter production shell establishes a static Fun App title, neutral description, canonical root URL, root indexing policy, branded icons, and manifest identity. The public routes are `/`, `/venues`, `/privacy`, `/here-and-now`, `/founding-friend`, `/founding-friend/payment`, and `/founding-friend/payment/cancelled`. Flutter Web retains their hash-based deployed form, including `https://funapp.world/#/privacy`. Draft-legal hashes redirect to `/` while the public form and payment-return hashes support direct access, refresh, and browser history. Because each route is carried in the URL fragment, GitHub Pages serves the existing root document for direct access and refresh while `auto_route` and Router 2 own typed in-app and browser-history navigation. Unknown hash routes render the landing page. Richer social metadata, sitemap strategy, and redesigned crawlable content remain future implementation and release concerns.

## 11. Tooling and verification

### Established

Create and select the named stable-channel environment for a fresh checkout:

```bash
puro create fun-app-landing stable
puro use fun-app-landing
```

Puro records the selected environment in local `.puro.json`. That file is currently excluded locally rather than committed, so a fresh checkout must create/select the environment.

Prefer Puro for Flutter and Dart commands:

```bash
puro flutter ...
puro dart ...
```

Current baseline verification is:

```bash
puro flutter gen-l10n
puro flutter pub run build_runner build
puro flutter analyze
puro flutter test
puro flutter build web -t lib/main_dev.dart
puro flutter build web -t lib/main_staging.dart
puro dart run tool/prepare_staging_release_artifact.dart
puro flutter build web -t lib/main_prod.dart
puro dart run tool/prepare_intermediate_release_artifact.dart

cd cloudflare/staging-site-worker
npm ci
npm run typecheck
npm test
npm run wrangler:validate

cd ../venue-interest-worker
npm ci
npm run typecheck
npm test
npm run wrangler:validate
npm run wrangler:validate:staging

cd ../founding-friend-payment-worker
npm ci
npm run typecheck
npm test
npm run wrangler:validate
npm run wrangler:validate:staging
```

The active suites cover the landing surface and its durable responsive and
interaction contracts, registration-to-Checkout orchestration, payment return
and cancellation states, fail-closed dependency injection, payment Worker
contracts, deterministic Stripe scenarios, idempotency, and sensitive-response
boundaries. Verification should grow with implemented behavior rather than
speculative tooling.

Local development tracks Flutter stable through Puro. Hosted workflows install
their documented Flutter version directly through `subosito/flutter-action@v2`.

## 12. Deployment

### Established

- GitHub Pages is the production deployment target.
- GitHub Pages remains the web origin. Its active `/api/venue-interest`
  exception is a dashboard-managed narrow Cloudflare Worker Route to the
  repository-controlled `funapp-venue-interest` Worker. The
  `deploy-venue-interest-worker.yml` workflow provides manual-only source
  deployment of that existing Worker after Worker validation. It uses the
  GitHub `production` Environment for public HubSpot and Cloudflare account
  configuration and the Cloudflare API-token secret; it does not configure the
  route.
- The registration Worker routes are not attached and
  `REGISTRATION_SUBMISSIONS_ENABLED` remains false. Later activation requires
  the two registration form variables, source-declared rate-limit binding,
  exact route attachment, controlled verification, and legal/product approval.
- The payment Worker has a separate manual-only
  `deploy-founding-friend-payment-worker.yml` workflow. It validates before
  deployment, configures no route, and defaults
  `PAYMENT_CREATION_ENABLED` to false. No live Stripe Product/Price or key,
  production Cloudflare secret, production payment route, or live deployment is
  introduced. The operator reports that the isolated sandbox staging integration
  is operational; its credentials are not stored in this repository. Later
  production setup requires `STRIPE_PRICE_ID`,
  `STRIPE_EXPECTED_LIVEMODE`, `STRIPE_AUTOMATIC_TAX_ENABLED`,
  `PUBLIC_APP_ORIGIN`, `STRIPE_SECRET_KEY`,
  `PURCHASE_REFERENCE_SECRET`, the source-declared rate-limit binding, exact
  payment endpoint route attachment, and controlled Stripe/Cloudflare review.
- Pull requests targeting `dev` or `main` run the staging site Worker's typechecking,
  tests, and dry-run validation, both API Worker projects' typechecking, tests,
  and root/staging dry-run validation, plus Flutter formatting, generation,
  analysis, full-suite coverage, and production/staging compile checks.
  Pull-request checks do not deploy; pushes to `main` remain the production
  Pages deployment trigger.
- The production custom domain is `https://funapp.world` and uses root `/` deployment.
- The active workflow installs Flutter 3.47.2 directly through
  `subosito/flutter-action@v2`, generates localizations and Dart sources,
  analyzes, tests, and explicitly builds Flutter Web from `lib/main_prod.dart`
  without browser-side HubSpot configuration. Local development continues to
  use Puro. The workflow then removes the three
  review-only legal Markdown files from `build/web`. The production artifact
  does not publish those draft source documents as static assets.
- Only pushes to `main` and manual dispatches run the production Pages
  deployment. Its `github-pages` environment remains unchanged. Production
  Worker deployment workflows remain manual-only and no live Stripe payment
  activation is introduced.
- Pushes to `dev`, including PR merges, run `deploy-staging-site.yml` (**Deploy
  Staging**). It calls the credential-free `pr_checks.yml` via `workflow_call`
  and requires every validation job to succeed before its sole publishing job
  may enter the GitHub `staging` environment. That environment is restricted to
  `dev`; GitHub `production` is restricted to `main`.
- PR events target `dev` and `main` and validate only. They never reference the
  staging environment, inherit deployment secrets, or invoke a deployment job.
  Stable PR check names are **Worker checks**, **Payment Worker checks**, and
  **Flutter and staging site checks**. No path filter skips these checks.
- The three prior staging workflows are consolidated into one push-only
  workflow; the individual manual staging API deployment workflows and payment
  enablement checkbox are retired. The publishing job uses a shared concurrency
  lock without cancelling an active publish and checks the revision against
  current `dev` HEAD under that lock, rejecting superseded queued jobs/reruns.
- The staging site artifact comes from the successful validation run for that
  revision. It is prepared with the existing tool and checked before upload and
  again after download. Flutter builds never receive deployment credentials.
  Both API Workers publish before the site; publishing is sequential, not atomic.
- Preflight validates the complete existing environment configuration and reads
  settings for all three existing staging identities with their respective
  tokens before any publish. Denied reads, missing resources/configuration, or
  malformed payment values fail without provisioning resources or widening
  token permissions. Generated configs hard-code the selected staging identities
  and entrypoints and do not include any routes or Custom Domains.
- `keep_vars` alone preserves only plain/JSON variables, not every binding.
  Generated configs use Wrangler `unsafe.metadata.keep_bindings` with every
  currently deployed binding type plus plain/JSON and encrypted-secret types.
  They omit source rate-limit declarations so deployed namespaces/limits and
  other dashboard bindings survive. Tests inspect the locked Wrangler upload
  metadata. Source defaults remain useful for dry-run checks; they are not
  deployed over working dashboard configuration. Dashboard settings must remain
  stable during the short preflight/publish interval.
- Required staging variables are `CLOUDFLARE_ACCOUNT_ID`,
  `STAGING_PAYMENT_CREATION_ENABLED`, `STRIPE_SANDBOX_PRICE_ID`, and
  `STRIPE_SANDBOX_AUTOMATIC_TAX_ENABLED`. Required secrets are
  `CLOUDFLARE_STAGING_SITE_API_TOKEN`, `CLOUDFLARE_WORKERS_API_TOKEN`,
  `STRIPE_SANDBOX_RESTRICTED_KEY`, and `STAGING_PURCHASE_REFERENCE_SECRET`.
  The site token remains distinct from the two-API-Worker token. Existing
  least-privilege credentials need settings read and deployment access to their
  respective Workers, with no added DNS, route, or Access permissions.
- `STAGING_PAYMENT_CREATION_ENABLED` is a required exact boolean string and is
  explicitly mapped to `PAYMENT_CREATION_ENABLED`, with no silent fallback.
  The current environment has sandbox creation enabled. Automatic tax must
  remain false, expected live mode is pinned false, the origin is fixed to
  staging, and the key must be restricted/sandbox. The five public payment
  variables are supplied explicitly; neither Price/tax placeholders nor the
  source disabled default are carried into deployment.
- Both existing encrypted payment secrets are supplied atomically with code
  using `--secrets-file` from a mode-0600 `RUNNER_TEMP` file, cleaned on every
  outcome. Secrets are not written to source, web bundles, artifacts, or logs.
  Rotations must keep GitHub and Cloudflare synchronized.
- The staging site uses `build/web` as its Static Assets directory with SPA
  fallback. Its script runs first for `/api` and `/api/*` and returns `404`,
  preventing an absent or mistyped API Route from returning the SPA document
  with `200`.
- The exact local staging site sequence is `puro flutter build web -t
  lib/main_staging.dart`, `puro dart run
  tool/prepare_staging_release_artifact.dart`, `bash
  tool/verify_staging_artifact.sh`, then from `cloudflare/staging-site-worker/`,
  `npm ci`, `npm run typecheck`, `npm test`, and `npm run wrangler:validate`.
  These commands validate only. Automatic publishing uses generated staging
  configs after complete preflight, rather than deploying source placeholders.
- A normal rollback reverts code through a PR to `dev`, then validates and
  republishes with current environment secrets. For an emergency version rollback,
  disable the staging workflow, cancel queued runs, let any active publish
  settle, and restore known-good versions on the affected staging Workers in
  Cloudflare. Review version-bound variables/secrets first: an older version may
  restore pre-rotation secrets. See the README operational procedure. No
  rollback automatically changes routing or production resources.
- Dashboard-managed staging routes remain only
  `staging.funapp.world/api/registrations/*` to the staging registration Worker
  and `staging.funapp.world/api/founding-friend-payments/*` to the staging
  payment Worker. The existing site Worker Custom Domain, Cloudflare-created DNS record
  and certificate, those routes, and hostname-based Access remain externally
  managed and must be preserved. The Access application must cover the exact
  hostname with no Path value. Hostname-based Access is
  required to cover requests handled by all three Workers; site-Worker Access
  alone does not cover the separate API Workers. No staging route belongs on
  `funapp.world`, and the existing
  `funapp.world/api/venue-interest` route is unchanged.
- The production artifact is `build/web`.
- `web/CNAME` and `web/robots.txt` are copied into the production artifact by the Flutter Web build.
- Production builds include the canonical Privacy Notice asset and remove the
  three review-only Markdown files during artifact preparation; protected
  hashes redirect without a Pages rewrite or `404.html` fallback. Client-side
  routing remains neither backend authorization nor a security boundary.
- The archived Astro project is not built or deployed.

### Provisional

- Azure hosting may be considered in the future.

### Open

- Routing and any required 404/deep-link strategy for future non-hash paths.
- Future Azure hosting or topology.
- Release automation beyond current needs.

## 13. Documentation

- `SPECIFICATIONS.md` is the authoritative project truth and records established, provisional, and open decisions.
- `AGENTS.md` defines repository-wide working rules for coding agents.
- `README.md` provides practical contributor setup and current-status onboarding.

Documentation must describe the implementation and decision status accurately. It must not present provisional or open behavior as implemented.

## 14. Change policy

- Prefer small, reviewable commits with one coherent purpose.
- Preserve established decisions unless a change explicitly updates this specification and explains the consequence.
- Do not let implementation silently resolve an open decision.
- Introduce architecture, dependencies, state management, data boundaries, and configuration only when active requirements justify them.
- Treat the archived Astro project as historical reference, not an active implementation surface. Do not restore its dependencies or deployment without an explicit project decision.
- Update documentation in the same change when project truth or contributor workflow changes.
