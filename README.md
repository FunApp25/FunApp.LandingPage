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
- All 13 surfaces in Figma `Landing Page - V1` now have a static Flutter
  implementation, including the Free, Here & Now, and Lifetime Membership
  cards and the Founding Member explanation. The header remains fixed above the
  scrolling page, repeated header/footer navigation moves to the corresponding
  page sections, and the independently expandable FAQ supports its complete
  item surface. Contact and product CTAs remain intentionally unwired; pricing
  is static marketing UI rather than subscription functionality. The stable
  responsive presentation includes restrained anchor/FAQ interaction motion
  and one-time scroll accents only for Research Statistics, Membership pricing
  cards, Founding Friends, and Venue; the Hero and all other landing sections
  remain static. Business, domain, application, and data behavior is not
  implemented.
- Reusable branding assets live under `assets/branding/`, with active widget
  paths centralized in project code. Figma assets consumed by implemented
  landing sections live under `assets/landing/`.
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
puro flutter run -d chrome
```

VS Code and VSCodium users can also launch `lib/main.dart` on Chrome in debug
mode through the committed **Fun App Landing Page** run configuration.

## Localization

Localization source files live under `lib/l10n/` using Flutter ARB generation
configured by `l10n.yaml`. English (`en`) is the source/default language;
Spanish (`es`), Welsh (`cy`), and Belarusian (`be`) are also supported.

Regenerate localization output after changing an ARB file:

```bash
puro flutter gen-l10n
```

Generated localization Dart files are local build inputs and are not committed.

## Validation

```bash
puro flutter gen-l10n
puro flutter analyze
puro flutter test
puro flutter build web
```

The widget tests cover the active landing surface, branding, localization,
theme, interactions, and responsive viewport contracts.

## Repository structure

```text
lib/                         Active Flutter application source
lib/l10n/                    Localization ARB source files
assets/branding/             Shared Fun App logos and decorative brand shapes
assets/landing/              Figma assets consumed by active landing sections
test/                        Flutter widget tests for active behavior
web/                         Flutter Web shell and web-root static inputs
l10n.yaml                    Flutter localization generation configuration
archive/astro_site/          Deprecated pre-Flutter historical reference
.github/workflows/deploy.yml Flutter GitHub Pages workflow
SPECIFICATIONS.md            Authoritative project decisions
AGENTS.md                    Coding-agent working rules
```

## Architecture direction

Application behavior will use a layer-first direction with `presentation`,
`application`, `domain`, and `data` responsibilities when active code requires
them. `core` may own bootstrap and shared wiring. BLoC/Cubit, domain validation,
repositories, and data sources should be introduced only when corresponding
state, rules, or external I/O exists.

See [`SPECIFICATIONS.md`](SPECIFICATIONS.md) for the complete direction and
dependency boundaries.

## Deployment

Pushes to `main` and manual workflow dispatches run the GitHub Pages workflow.
CI installs Puro, creates the `fun-app-landing` stable environment, generates
localizations, analyzes, tests, and builds Flutter Web. The workflow uploads
`build/web` and deploys it to [https://funapp.world](https://funapp.world).

The custom domain remains configured in GitHub Pages. `web/CNAME` records the
repository's active domain declaration and is copied into the Flutter artifact.

## Contributing

Keep commits small and focused, preserve the documented decision status, and
run verification appropriate to the files changed before requesting review.
