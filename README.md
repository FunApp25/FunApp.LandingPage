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
  Membership cards and the Founding Member explanation. The header remains
  fixed above the scrolling page, repeated header/footer navigation moves to
  the corresponding page sections, and the independently expandable FAQ
  supports its complete item surface. Contact and product CTAs remain
  intentionally unwired; pricing
  is static marketing UI rather than subscription functionality. The stable
  responsive presentation includes the mobile navigation menu, a mobile
  Research-statistics and Founding Member carousels, restrained anchor/FAQ
  interaction motion, and
  one-time scroll accents only for Research Statistics, Membership pricing
  cards, Founding Friends, and Venue; the Hero and all other landing sections
  remain static. The first provider-neutral prospective-venue domain model and
  application form workflow now sit above one concrete provider-neutral
  repository. Dependency injection selects a deterministic development data
  source or the production HubSpot data source. Production submits
  provider-neutral venue leads directly to HubSpot's unauthenticated Forms v3
  API through the injected web-compatible HTTP client. The Venue CTA opens a
  localized responsive form backed by a fresh `VenueLeadFormBloc`; success is
  confirmed in the dialog, while failures preserve the draft for retry. The
  form shows the approved informational privacy acknowledgement immediately
  before Send and links to the hosted Privacy Notice without adding a consent
  checkbox or submitted field. The Privacy Notice is also discoverable in the
  footer at [https://funapp.world/#/privacy](https://funapp.world/#/privacy).
  Its approved English legal copy lives in
  `assets/legal/privacy_notice.md`. The
  Founding Friends CTA remains a presentation-only Coming soon flow, and the
  Membership section remains temporarily hidden without removing its source.
- Reusable branding assets live under `assets/branding/`, with active widget
  paths centralized in project code. Figma assets consumed by implemented
  landing sections live under `assets/landing/`.
- Google Fonts typography remains implemented through `google_fonts`, but its
  required Manrope and Instrument Serif files are bundled under `assets/fonts/`.
  Runtime font fetching is disabled in the common bootstrap. When adding a
  family, weight, or style, add its correctly named official font file and OFL
  license asset, then keep the bootstrap license registration in sync.
- Flutter localization supports English, Spanish, Welsh, and Belarusian, with
  English as the source and fallback language.
- Dart analysis follows the main Fun App Flutter project's
  `very_good_analysis` policy.
- GitHub Pages builds Flutter through Puro and deploys `build/web` to
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

VS Code and VSCodium users can also launch either explicit Flutter entrypoint
on Chrome in debug mode through the committed configurations:

- **Fun App Landing — Development (Fake Repositories)** selects the
  deterministic local data source.
- **Fun App Landing — HubSpot** selects the production HubSpot data source.

For a local production/HubSpot composition, copy the tracked fake-value
template and replace both HubSpot identifiers in the gitignored local file:

```bash
cp .env.example .env
puro flutter run -d chrome \
  -t lib/main_prod.dart \
  --dart-define-from-file=.env
```

The **Fun App Landing — HubSpot** VS Code configuration consumes the same
`.env` file while `lib/main_prod.dart` structurally selects the production
environment. It does not load dotenv at runtime; Flutter reads the file as
compile-time build input. The file must contain non-empty values for:

```text
FUN_APP_HUBSPOT_PORTAL_ID=123456789
FUN_APP_HUBSPOT_VENUE_FORM_GUID=00000000-0000-0000-0000-000000000000
```

The example values are deliberately fake. The HubSpot account/portal ID and
form GUID are public client configuration and will be recoverable from the
compiled Flutter Web application. They are kept out of tracked local settings
to avoid committing environment-specific configuration, not because they are
secrets. Never put authentication credentials, tokens, API keys, or client
secrets in `.env` or any Flutter Web build define.

The entrypoint selects the dependency environment; dart-defines provide only
configuration required by that environment. Development uses
`lib/main_dev.dart`, needs no `.env`, and neither constructs nor validates
HubSpot configuration. Production composition fails at startup when either
required HubSpot identifier is empty.

Build the production entrypoint locally with the same public configuration:

```bash
puro flutter build web \
  -t lib/main_prod.dart \
  --dart-define-from-file=.env
```

## Localization

Localization source files live under `lib/l10n/` using Flutter ARB generation
configured by `l10n.yaml`. English (`en`) is the source/default language;
Spanish (`es`), Welsh (`cy`), and Belarusian (`be`) are also supported.

Regenerate localization output after changing an ARB file:

```bash
puro flutter gen-l10n
```

Generated localization Dart files are local build inputs and are not committed.

## Privacy Notice content and preview

`assets/legal/privacy_notice.md` is the canonical website representation of
the currently approved Fun App Ltd Privacy Notice. Do not rewrite or translate
its legal prose independently. Replace or update it only from a newly approved
source document.

The site exposes the notice through Flutter's GitHub-Pages-safe hash route:

```text
https://funapp.world/#/privacy
```

During local development, append `#/privacy` to the root URL printed by
`puro flutter run -d chrome -t lib/main_dev.dart`. The build bundles the
Markdown asset declared in `pubspec.yaml`; `flutter_markdown_plus` renders the
document, and the web link adapter handles only the approved `mailto:` contact
links.

Freezed and Injectable sources are generated locally and remain uncommitted.
Regenerate all generated Dart source after changing a model or dependency
registration:

```bash
puro flutter pub run build_runner build
```

## Validation

```bash
puro flutter gen-l10n
puro flutter pub run build_runner build
puro flutter analyze
puro flutter test
puro flutter build web -t lib/main_dev.dart
```

The test suite covers domain validation, venue-lead form orchestration, and the
active landing surface's branding, localization, theme, interactions, and
responsive viewport contracts.

## Repository structure

```text
lib/                         Active Flutter application source
lib/main_dev.dart            Development/fake Flutter entrypoint
lib/main_prod.dart           Production/HubSpot Flutter entrypoint
lib/application/venue/       Venue-lead form state and submission orchestration
lib/core/config/              Typed application-environment selection
lib/core/injection/           GetIt/Injectable composition root
lib/domain/core/             Pure-Dart failures, validators, and value objects
lib/domain/venue/            Provider-neutral prospective-venue domain model
lib/data/core/                External field-name mapping constants
lib/data/venue/               Venue repository, DTO, and selectable data sources
lib/l10n/                    Localization ARB source files
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
l10n.yaml                    Flutter localization generation configuration
archive/astro_site/          Deprecated pre-Flutter historical reference
.github/workflows/deploy.yml Flutter GitHub Pages workflow
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
them. `domain` owns validation and the provider-neutral prospective-venue
contract; the application BLoC coordinates the form through that contract. One
data repository maps validated leads into a provider-neutral DTO and delegates
to an environment-selected data source. The explicit development and production
entrypoints pass a typed environment into `core`, which configures GetIt through
Injectable before the app starts.
The production data boundary maps the DTO to exact HubSpot property names and
uses the public Forms endpoint with an abortable 15-second request deadline.
Core composition passes validated public identifiers into that boundary
without exposing provider concerns above the data layer. A future server-side
proxy can replace this transport without changing the domain/application
contracts.

See [`SPECIFICATIONS.md`](SPECIFICATIONS.md) for the complete direction and
dependency boundaries.

## Deployment

Pull requests targeting `main` run formatting, generation, analysis, the full
test suite with coverage, and a synthetic-config production compile through
the read-only `PR Checks` workflow. These checks do not deploy anything.

Pushes to `main` and manual workflow dispatches run the GitHub Pages workflow.
CI installs Puro, creates the `fun-app-landing` stable environment, generates
localizations and Dart sources, analyzes, tests, and explicitly builds
`lib/main_prod.dart`. The production build consumes these public GitHub Actions
repository variables:

```text
FUN_APP_HUBSPOT_PORTAL_ID
FUN_APP_HUBSPOT_VENUE_FORM_GUID
```

Repository administrators must configure both values before relying on the
deployed production submission path; the workflow does not fabricate or
hardcode them and fails before the production build when either is empty. The
workflow uploads `build/web` and deploys it to
[https://funapp.world](https://funapp.world).

HubSpot validates unauthenticated submissions against the target form
definition. Every property in `HubSpotFields` must exist on that venue form,
and all HubSpot-required fields must be provided. The implementation leaves
validation enabled and does not send deprecated `skipValidation`. Consent API
payloads remain deferred until product/legal requirements establish an
approved privacy and consent contract.

Before releasing venue submission, an authorized person must confirm in
HubSpot that the configured form GUID identifies the intended venue form, every
`HubSpotFields` property exists on that form, and HubSpot-required fields match
the application-required venue contract.

The custom domain remains configured in GitHub Pages. `web/CNAME` records the
repository's active domain declaration and is copied into the Flutter artifact.

## Contributing

Keep commits small and focused, preserve the documented decision status, and
run verification appropriate to the files changed before requesting review.
