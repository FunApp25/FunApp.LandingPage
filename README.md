# Fun App Landing Page

This repository owns the public Fun App website and landing page. The site is being migrated incrementally from Astro to a Flutter Web-only application.

## Where to start

- [`SPECIFICATIONS.md`](SPECIFICATIONS.md) is the authoritative source for product scope, technical decisions, open questions, and change policy.
- [`AGENTS.md`](AGENTS.md) tells coding agents how to work in this repository.
- `README.md` provides practical setup and contributor onboarding.

## Current repository state

- A web-only Flutter project exists at the repository root with package name `fun_app_landing_page`.
- A temporary Flutter application shell now uses Fun App branding and the shared visual-language foundation; it is not the redesigned landing page.
- Reusable branding assets live under `assets/branding/`, with active widget paths centralized in project code.
- The Flutter Web scaffold uses the Fun App symbol for its favicon and PWA icon artwork.
- Dart analysis follows the main Fun App Flutter project's `very_good_analysis` policy.
- Flutter localization supports English, Spanish, Welsh, and Belarusian, with English as the source and fallback language.
- The existing Astro implementation remains under `src/` while the migration proceeds.
- GitHub Pages still builds and deploys Astro through `.github/workflows/deploy.yml`.
- Production has not switched to the Flutter build.

The current Astro site serves a public Coming Soon page at `/` and retains a fuller, indexing-discouraged page at `/quiet-entry/7m4q9x2k/`. The redesigned route and content model has not yet been decided.

## Setup

Flutter and Dart commands use the named Puro environment `fun-app-landing`, which tracks Flutter stable.

For a fresh checkout:

```bash
puro create fun-app-landing stable
puro use fun-app-landing
puro flutter pub get
puro flutter gen-l10n
```

Puro records the local selection in `.puro.json`. That file is currently excluded locally rather than committed, so each fresh checkout must create or select the environment.

VS Code and VSCodium users should also generate local editor SDK settings:

```bash
puro use fun-app-landing --vscode --no-intellij
```

Those machine-specific settings remain ignored.

## Run Flutter Web

```bash
puro flutter run -d chrome
```

VS Code and VSCodium users can also launch `lib/main.dart` on Chrome in debug mode through the committed **Fun App Landing Page** run configuration.

## Localization

Localization source files live under `lib/l10n/` using Flutter ARB generation configured by `l10n.yaml`. English (`en`) is the source/default language; Spanish (`es`), Welsh (`cy`), and Belarusian (`be`) are also supported.

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

The current widget tests cover the active application shell, branding, theme, and representative narrow and wide layouts.

## Repository structure

```text
lib/                         Flutter application source
lib/l10n/                    Localization ARB source files
assets/branding/             Shared Fun App logos and decorative brand shapes
test/                        Flutter widget tests for active behavior
web/                         Generated Flutter Web host scaffold
l10n.yaml                    Flutter localization generation configuration
src/                         Existing Astro implementation during migration
public/                      Existing Astro public files
.github/workflows/deploy.yml Current Astro GitHub Pages workflow
SPECIFICATIONS.md            Authoritative project decisions
AGENTS.md                    Coding-agent working rules
```

## Architecture direction

Application behavior will use a layer-first direction with `presentation`, `application`, `domain`, and `data` responsibilities when active code requires them. `core` may own bootstrap and shared wiring. BLoC/Cubit, domain validation, repositories, and data sources should be introduced only when corresponding state, rules, or external I/O exists.

See [`SPECIFICATIONS.md`](SPECIFICATIONS.md) for the complete direction and dependency boundaries.

## Deployment

Production is currently published at [https://funapp.world](https://funapp.world) through the existing Astro GitHub Pages workflow. It runs the npm/Astro build and uploads `dist/`.

`puro flutter build web` produces `build/web`, but that output is not yet connected to production deployment. The GitHub Pages migration is intentionally deferred to a later reviewable change.

## Contributing

Current migration work is occurring on `flutter_web_redesign`. Keep commits small and focused, preserve the documented decision status, and run verification appropriate to the files changed before requesting review.
