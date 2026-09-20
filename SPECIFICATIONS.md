# Fun App Landing Page Specification

## 1. Purpose

This repository owns the public Fun App website and landing page. The site should communicate the Fun App product and brand through responsive public marketing content.

The landing page is expected eventually to collect information from interested
users. The provider-neutral venue-lead workflow has a production data path that
submits directly from Flutter Web to HubSpot Forms, and the venue CTA now opens
its functional localized form. That form now shows the approved informational
privacy acknowledgement and links to the hosted Privacy Notice; it does not
submit a consent field. Prospective-user fields, flows, analytics, marketing
consent behavior, and other business behavior remain unspecified.

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
  and Founding Member explanation section. Its static and responsive
  presentation is stable, and its current restrained motion pass is complete
  before business, domain, application, or data implementation.
- Fun App logos and decorative shapes are established under `assets/branding/`; active presentation paths are centralized through the project asset helper.
- The Flutter shell retains the platform-neutral typography and Material 3
  foundation adapted from the main Fun App application. The current Figma
  landing-page design is authoritative when its visual tokens differ from that
  starting point.
- The Flutter Web host scaffold uses the Fun App symbol for favicon and PWA icon artwork.
- Dart analysis follows the main Fun App Flutter project's `very_good_analysis` policy.
- Flutter generated localization supports English, Spanish, Welsh, and Belarusian; English is the source and fallback language.
- GitHub Pages is the production hosting and deployment target at `https://funapp.world`.
- GitHub Pages builds Flutter through Puro and publishes `build/web` from the repository root at base href `/`.
- The approved English Fun App Ltd Privacy Notice is hosted at
  `https://funapp.world/#/privacy`. Its canonical website source is
  `assets/legal/privacy_notice.md`; the hash route supports direct access,
  refresh, and browser history without requiring a GitHub Pages rewrite.
- The landing footer opens the hosted Privacy Notice in a new browser tab. The venue form shows
  the approved English privacy acknowledgement immediately before submission,
  with an inline link that opens the same page in a new tab, preserving the
  current form draft. This disclosure is informational: no
  consent checkbox or submitted consent field is required for the current MVP.
- `web/CNAME` is the active repository declaration for `funapp.world`; the external GitHub Pages custom-domain setting remains authoritative.
- `web/robots.txt` owns the active crawler policy.
- Production venue-lead submission uses HubSpot's unauthenticated Forms v3
  submission endpoint directly from Flutter Web. This public-form integration
  supports CORS and requires no authentication secret.
- The deprecated pre-Flutter Astro implementation is archived under `archive/astro_site/` for historical reference only. It is not active application code, built by CI, or deployed.

### Open

- The final landing-page content, information architecture, and interaction details.

## 4. Scope

### Established

- Public Fun App product and brand communication.
- Responsive Flutter Web presentation.
- Deliberate public-web, accessibility, and SEO behavior throughout implementation and release work.

### Provisional

- Collection of deliberately defined interested-user information.
- A future server-side submission proxy may replace the direct provider
  transport without changing the established domain or application contracts.
- Azure hosting may be considered later, but it is not current deployment scope.

### Open

- The interested-person form fields and validation rules.
- Any future submitted marketing-consent contract, analytics, and marketing behavior.
- Prospective-user backend, API, authentication, retention, deletion, and
  error-handling contracts.

## 5. Repository shape

The repository is an active Flutter Web project:

- `lib/` contains the Flutter bootstrap, active presentation, and the first
  venue-lead domain/application/data foundation.
- `lib/l10n/` contains committed ARB localization inputs; generated localization Dart files remain uncommitted.
- `assets/branding/` contains reusable Fun App logos and decorative brand shapes.
- `assets/legal/privacy_notice.md` is the canonical website representation of
  the currently approved English Privacy Notice.
- `test/` contains tests for active Flutter behavior.
- `web/` contains the Flutter Web host scaffold and canonical web-root static inputs, including `CNAME` and `robots.txt`.
- `archive/astro_site/` contains the deprecated pre-Flutter Astro implementation for historical reference only; it is outside the active architecture.
- `.github/workflows/deploy.yml` validates and builds Flutter through Puro, uploads `build/web`, and deploys it through GitHub Pages.

Flutter code uses `presentation`, `application`, `domain`, `data`, and `core`
areas only when active behavior needs them. `domain` is active for reusable
validation and the provider-neutral venue-lead model. The narrow active
`application/venue` surface owns the venue-lead form BLoC. `data/venue` owns one
provider-neutral repository, its DTO, and environment-specific data sources;
`data/core` retains the external field-name constants. `core` owns typed
environment selection and dependency composition. The landing-page repository
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
V1`. Responsive adaptations are constraint-driven because Figma supplies no
tablet or phone frames. Research statistics use four, two, or one column as
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
Statistics, Different Way to Connect, Limited-time Founding Friend offer,
Founding Member explanation, Founding Friends, Venue, Welcome Statement, FAQ,
and Footer. The Header remains fixed outside the primary scrolling content.
Membership presents static Free, Here & Now, and Lifetime pricing cards, but is
temporarily hidden from the MVP composition; its implementation, localization,
assets, and focused tests remain available for restoration. Those cards and the
Founding Member descriptions are approved marketing presentation only;
subscription, payment, cancellation, entitlement, badge, and other business
behavior is not implemented. Pricing cards use three, two, or one column based
on usable card width, and Founding Member benefit cards similarly reflow from
the desktop intro-plus-three-card composition without forcing desktop heights
onto narrow single-column layouts.

Header and footer section navigation scrolls within the single landing page
while the header remains fixed above the scrolling content. Below a 600px
outer viewport width, the fixed header uses a compact logo, Contact Us, and
burger composition. The burger opens a full-screen, presentation-local menu
with the same three active anchor destinations; selecting one closes the menu
before reusing the existing anchor navigation. At 600px and above, the
established wide, intermediate, and narrow constraint-driven header variants
remain in use; larger text can select the intermediate composition when the
single-row header no longer fits. Internal navigation controls provide at least
a 44px effective target and an explicit keyboard-focus outline; hover and focus
treatments cover the complete padded control surface. The active MVP mapping is Our Belief to
Hero, Founding Friends to Founding Friends, and For Venues to Venue. Membership
navigation is temporarily hidden with its rendered section. Anchor positions
derive from the rendered sections. Navigation duration scales with the current
viewport-normalized distance and uses `easeInOutCubic`; a higher bounded duration gives long jumps
enough time to accelerate, travel, and decelerate while nearby targets remain
responsive.
Brief hover interpolation applies only to internal navigation backgrounds;
keyboard focus remains immediate. Navigation movement and hover interpolation
become immediate when reduced motion is requested. Contact Us in the header
and mobile menu opens the same localized, presentation-only Coming soon dialog
as Founding Friends. Waitlist, product, email, and other marketing CTA
destinations remain open and intentionally unwired.
The Founding Friends prospective-user CTA currently opens a localized,
presentation-only Coming soon dialog. It collects no information and performs
no business operation; the interested-person contract remains unresolved. The
venue CTA opens a localized functional form in the reusable landing dialog. A
fresh `VenueLeadFormBloc` owns each dialog session and submits through the
established environment-selected venue repository/data-source graph.

Below a 600px outer viewport width, Research statistics use a horizontal,
page-snapping carousel with one primary card, a trailing adjacent-card peek,
previous/next controls, and four decorative page indicators. The carousel is
clamped and non-looping pending explicit contrary design direction. At 600px
and above, the established responsive Research grids remain in use.
The Great Friendship Project attribution links to
`https://friendship-project.co.uk/` in a new tab. Other source names in that
line use bold text emphasis without link styling.
The mobile Research scroll accent reveals the initial carousel viewport and
navigation once as a single group rather than staggering offscreen cards;
reduced motion renders that group immediately and makes programmatic page
changes immediate while preserving direct swipe interaction.
The Figma-responsive mobile Research card height remains a minimum. When
localized or scaled text needs more room, every carousel page shares the
tallest required height so text is not clipped or truncated to preserve the
design minimum.

Below a 600px outer viewport width, the three Founding Member benefits use the
shared horizontal, page-snapping carousel with three decorative page indicators
derived from the real content count. Figma node `2270:2640` currently shows four
indicators despite containing only three cards; implementation follows the three
cards pending design clarification. The carousel is clamped and non-looping. At
600px and above, the established Founding Member cards and grids remain in use.
Founding Member has no scroll-entry reveal, and reduced motion makes its
programmatic carousel page changes immediate while preserving direct swipe.

Below a 600px outer viewport width, Problem, Membership, Limited Offer, Welcome,
and FAQ opt into the approved mobile 16px page bounds and section-specific
Figma rhythm and type roles. Membership remains a one-column, naturally sized
pricing-card stack with its approved reveal unchanged. FAQ retains its existing
independent expansion, semantics, focus, and motion behavior while using its
mobile-specific spacing and type. Marketing copy remains shared across
responsive layouts unless product or design explicitly changes it.

Below a 600px outer viewport width, Hero uses a dedicated centered-overflow
composition with one artwork instance clipped by the Hero card and centered
copy beneath a reserved artwork region. Its height remains content-aware for
localization, and Hero remains static. Connection uses centered copy, 16px
horizontal bounds, 80px vertical section padding, and a near-square
`BoxFit.cover` image crop. The repository Connection copy remains shared across
responsive layouts pending content approval. At 600px and above, the
established Hero and Connection compositions remain unchanged.

Below a 600px outer viewport width, Footer uses a centered 16px/80px mobile
composition: the established anchor navigation wraps naturally beneath the
logo, a divider separates it from the static email presentation, and all
existing anchor behavior remains unchanged. The approved Privacy Notice is
available through a visible localized footer link. Other Figma legal-policy
controls remain blocked until authoritative destinations and localized copy
exist; inert legal-looking controls must not be rendered. At 600px and above,
the established Footer composition remains unchanged apart from the approved
Privacy Notice link.

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
- User-facing Flutter copy must come from generated localizations rather than hardcoded presentation strings. New source copy and its supported translations belong in the same implementation scope.
- Locale-specific product and marketing copy remains subject to product and translation review as content expands.

## 8. User input and future backend direction

### Established

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
  The venue information group reuses the established beige surface and card
  radius; text inputs use the same rounded radius. The dialog keeps its action
  footer pinned below the independently scrolling form body. Scroll-position
  fades soften the top edge after scrolling and the bottom edge while more
  content remains beneath the pinned footer.
- Generated Freezed and Injectable source is regenerated locally and in CI and
  remains uncommitted.
- HubSpot property names are exact external identifiers owned only by
  `data/core/hubspot_fields.dart` and consumed only at the HubSpot data
  boundary. HubSpot-generated trailing and repeated underscores are
  intentional. In particular, chain status is
  `independent_or_part_of_chain_` and venue count is
  `if_chain__number_of_venues`.
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
- A successful or failed submission preserves the complete form draft. The
  venue dialog shows "Form Submitted", "Thank you for reaching out, we'll be
  in touch shortly.", and "The Fun App team." with a Close action instead of
  Send, without immediately closing. Operational failure keeps the form open
  and editable for retry, with a concise retry-later message above Send.
  While submission is pending, Send is visibly disabled and an indeterminate
  linear progress indicator appears immediately above it in the pinned footer.
  The success content has vertical space from the pinned dialog chrome and
  starts at the top of its own scroll position after submission.
  Each later dialog opening starts with a fresh BLoC and empty draft.
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
  `HubSpotVenueLeadDataSource`.
- `HubSpotVenueLeadDataSource` posts the provider-neutral DTO through HTTPS to
  HubSpot's unauthenticated, CORS-compatible Forms v3 submission endpoint:
  `POST https://api.hsforms.com/submissions/v3/integration/submit/{portalId}/{formGuid}`.
  It uses no authenticated HubSpot API, bearer token, client secret, private-app
  token, OAuth flow, API key, or Fun App backend proxy.
- The HubSpot request body contains only a `fields` array of string `name` and
  `value` entries. Required DTO fields are always emitted. Optional absent
  values are omitted rather than sent as empty strings, integral quantities use
  decimal strings, and phone numbers remain strings so leading zeroes survive.
- HubSpot form-definition validation remains enabled. `skipValidation` is not
  sent. Every submitted `HubSpotFields` property must exist on the target
  HubSpot venue form, and every field that HubSpot marks required on that form
  must be supplied by this contract.
- Each HubSpot submission has a 15-second abortable deadline. A HubSpot 200
  response acknowledges success after its response stream is drained without
  interpreting a redirect URI or inline HTML message. Status 400 is submission
  rejected; 429 and 5xx responses plus known HTTP transport failures and
  deadline aborts are service unavailable; other statuses are unexpected. No
  automatic retry occurs.
- Classified data-source service-unavailable and submission-rejected conditions
  map to their matching `AppFailure` categories. Unclassified exceptions map to
  `AppFailure.unexpected`. Data-source exceptions do not cross the domain
  repository boundary.
- GetIt and Injectable own composition now that environment-dependent
  implementations exist. `VenueLeadFormBloc` is a factory registration, the
  repository is a provider-neutral lazy singleton, and core composition
  registers the selected data-source lazy singleton. Production composition
  passes validated primitive HubSpot identifiers into the data source.
  Application and data classes use constructor injection rather than reading
  GetIt or importing application configuration.
- Environment selection is structural: `lib/main_dev.dart` passes the typed
  `AppEnvironment.development` value into bootstrap and resolves deterministic
  development dependencies, while `lib/main_prod.dart` passes
  `AppEnvironment.production` and resolves the HubSpot production graph. No
  environment-selection dart-define or string parsing is used.
- `FUN_APP_HUBSPOT_PORTAL_ID` and
  `FUN_APP_HUBSPOT_VENUE_FORM_GUID` are required, non-empty production
  compile-time configuration. They are public account/form identifiers visible
  in the compiled Flutter Web application, not secrets. A gitignored `.env`
  may supply only these identifiers locally through
  `--dart-define-from-file=.env`; the production entrypoint selects the
  environment. Development neither requires `.env` nor constructs or validates
  HubSpot configuration. This is a build-input mechanism, not runtime dotenv
  storage.
- Compile-time Flutter Web configuration must not contain HubSpot credentials,
  tokens, API keys, or other secrets.
- There is no Fun App backend proxy for venue leads. A future server-side proxy
  remains possible without changing the domain repository or application BLoC
  contracts.

### Provisional

- The landing page is expected to collect interested-user information in the future; likely examples include name and email.
- The eventual backend may be the same Microsoft/Azure-backed backend used by the main Fun App product.
- Flutter should remain decoupled from backend implementation through interfaces, repositories, data sources, DTO/boundary mapping, and configuration.

### Open

- The prospective-user input model and its required/optional fields.
- An approved consent/privacy field contract and any corresponding HubSpot
  `legalConsentOptions` payload. Consent is not fabricated or submitted by the
  current implementation.
- The current venue privacy acknowledgement is approved informational copy,
  not a consent field. It adds no checkbox, BLoC state, domain value, DTO
  property, repository property, HubSpot field, or `legalConsentOptions` value.
- Approved venue-type choices and any future provider-side chain-value changes.
- Whether a future approved chain selection makes venue count conditionally
  required. The current domain contract deliberately has no chain/count
  cross-field invariant.
- Prospective-user API endpoints and DTOs, and venue-lead retention/deletion
  requirements.
- Whether venue submission later migrates from direct HubSpot Forms submission
  to a separately scoped server-side proxy.

Backend implementation must be driven by an actual approved contract rather than inferred from the main mobile application. Do not copy `/profiles`, Entra, OIDC, user-profile, onboarding, or other mobile-app contracts into this project without an explicit landing-page requirement.

## 9. Cybersecurity and privacy

### Established requirements

- Apply privacy by design and privacy by default.
- Minimize collected data to the defined purpose.
- Never place secrets or credentials in Flutter client code, configuration, examples, or built web bundles.
- Treat every value embedded in Flutter Web as publicly recoverable, including values injected by CI.
- Client-side validation improves usability but is not a security boundary; backend validation and authorization must exist where applicable.
- Do not include personal information in logs, analytics, diagnostics, crash reports, fixtures, or examples without explicit, justified handling.
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

The Flutter production shell establishes a static Fun App title, neutral description, canonical root URL, root indexing policy, branded icons, and manifest identity. The Privacy Notice uses the stable hash URL `https://funapp.world/#/privacy`; because the route is carried in the URL fragment, GitHub Pages serves the existing root document for direct access and refresh while Flutter owns in-app and browser-history navigation. Unknown hash routes render the landing page. Richer social metadata, sitemap strategy, and redesigned crawlable content remain future implementation and release concerns.

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
puro flutter build web -t lib/main_prod.dart --dart-define-from-file=.env
```

The active widget test suite covers the landing surface and its durable responsive and interaction contracts. Verification should grow with implemented behavior rather than speculative tooling.

The project tracks Flutter stable through Puro rather than establishing a permanent exact Flutter version pin.

## 12. Deployment

### Established

- GitHub Pages is the production deployment target.
- The production custom domain is `https://funapp.world` and uses root `/` deployment.
- The active workflow installs Puro 1.5.0, creates the named `fun-app-landing`
  environment from Flutter stable, generates localizations and Dart sources,
  analyzes, tests, and explicitly builds Flutter Web from `lib/main_prod.dart`.
  The build consumes the public HubSpot portal ID and venue-form GUID from
  GitHub Actions repository variables with matching names; those external
  values are not hardcoded in the workflow. The workflow fails before the
  production build and artifact upload when either variable is empty.
- Before releasing venue submission, an authorized person must confirm that
  the configured form GUID identifies the intended venue form, every
  `HubSpotFields` property exists on it, and its HubSpot-required fields match
  the application-required venue contract.
- The production artifact is `build/web`.
- `web/CNAME` and `web/robots.txt` are copied into the production artifact by the Flutter Web build.
- The production artifact includes the canonical Privacy Notice Markdown asset,
  and its `/#/privacy` route requires no Pages rewrite or `404.html` fallback.
- The archived Astro project is not built or deployed.

### Provisional

- Azure hosting may be considered in the future.

### Open

- Routing and any required 404/deep-link strategy for future non-hash paths or
  additional routes beyond the established Privacy Notice hash route.
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
