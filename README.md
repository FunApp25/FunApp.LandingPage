# Fun App Landing Page

This repository owns the public Fun App website and landing page. The site is being migrated incrementally from Astro to a Flutter Web-only application.

## Where to start

- [`SPECIFICATIONS.md`](SPECIFICATIONS.md) is the authoritative source for product scope, technical decisions, open questions, and change policy.
- [`AGENTS.md`](AGENTS.md) tells coding agents how to work in this repository.
- `README.md` provides practical setup and contributor onboarding.

## Current repository state

- A web-only Flutter project exists at the repository root with package name `fun_app_landing_page`.
- The generated minimal Flutter UI is temporary bootstrap code, not the Fun App landing page.
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
```

Puro records the local selection in `.puro.json`. That file is currently excluded locally rather than committed, so each fresh checkout must create or select the environment.

## Run Flutter Web

```bash
puro flutter run -d chrome
```

## Validation

```bash
puro flutter analyze
puro flutter test
puro flutter build web
```

Run `puro flutter test` once tests exist. The current empty Flutter template does not include a test suite.

## Repository structure

```text
lib/                         Flutter application source
web/                         Generated Flutter Web host scaffold
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
