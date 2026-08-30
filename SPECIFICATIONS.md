# Fun App Landing Page Specification

## 1. Purpose

This repository owns the public Fun App website and landing page. The site should communicate the Fun App product and brand through responsive public marketing content.

The landing page is expected eventually to collect information from interested users and submit it to a backend. Likely examples include name, email, and other deliberately defined interest or sign-up information. Exact fields, flows, consent language, analytics, business behavior, and backend contracts are not yet specified.

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
- The current Flutter application establishes the complete structural skeleton
  for Figma `Landing Page - V1`. The header and hero implement Figma nodes
  `2190:1568` and `2190:1569`; the problem statement, research statistics, and
  connection-experience sections implement nodes `2190:1581`, `2190:1587`, and
  `2190:1596`; the membership and limited-time-offer sections implement nodes
  `2190:1606` and `2190:1613`; the Founding Friends and venue sections implement
  nodes `2190:1620`, `2190:1627`, and `2190:1631`. The remaining detailed
  welcome-statement, FAQ, and footer content remains intentionally
  unimplemented.
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
- `web/CNAME` is the active repository declaration for `funapp.world`; the external GitHub Pages custom-domain setting remains authoritative.
- `web/robots.txt` owns the active crawler policy.
- The deprecated pre-Flutter Astro implementation is archived under `archive/astro_site/` for historical reference only. It is not active application code, built by CI, or deployed.

### Retired historical behavior

- The archived Astro implementation previously served a Coming Soon page at `/`.
- Its fuller `/quiet-entry/7m4q9x2k/` page is retired and is not part of Flutter routing or the active crawler policy.

### Open

- The final landing-page content, information architecture, and interaction details.

## 4. Scope

### Established

- Public Fun App product and brand communication.
- Responsive Flutter Web presentation.
- Deliberate public-web, accessibility, and SEO behavior throughout implementation and release work.

### Provisional

- Collection of deliberately defined interested-user information.
- Submission of that information to a backend through decoupled application and data boundaries.
- Azure hosting may be considered later, but it is not current deployment scope.

### Open

- Exact form fields, validation messages, consent copy, sign-up flow, analytics, and marketing behavior.
- Exact backend, API, authentication, retention, deletion, and error-handling contracts.

## 5. Repository shape

The repository is an active Flutter Web project:

- `lib/` contains the Flutter bootstrap and active presentation foundation.
- `lib/l10n/` contains committed ARB localization inputs; generated localization Dart files remain uncommitted.
- `assets/branding/` contains reusable Fun App logos and decorative brand shapes.
- `test/` contains tests for active Flutter behavior.
- `web/` contains the Flutter Web host scaffold and canonical web-root static inputs, including `CNAME` and `robots.txt`.
- `archive/astro_site/` contains the deprecated pre-Flutter Astro implementation for historical reference only; it is outside the active architecture.
- `.github/workflows/deploy.yml` validates and builds Flutter through Puro, uploads `build/web`, and deploys it through GitHub Pages.

Future Flutter code may introduce `presentation`, `application`, `domain`, `data`, and `core` areas only when active behavior needs them. The landing-page repository aligns architectural concepts with the main Fun App Flutter application where appropriate, but the repositories do not currently share source code or packages.

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

The active presentation foundation centralizes established Fun App color,
typography, sizing, and Material 3 theme values. The complete section topology
and broad desktop color rhythm follow Figma `Landing Page - V1`; its temporary
placeholder heights will be replaced by natural content sizing as sections are
implemented. Exact breakpoints, detailed components, and final narrow-layout
behavior remain open.

Implemented landing sections preserve their Figma desktop compositions. Their
narrower wrapping, stacking, and card reflow are constraint-driven
implementation inferences because Figma provides no responsive variants. Header
navigation and contact or waitlist CTA destinations remain open and are
intentionally unwired.

### Localization baseline

- Supported locale identifiers are English (`en`), Spanish (`es`), Welsh (`cy`), and Belarusian (`be`). English is the authoritative source language and unsupported locales fall back to English.
- Flutter's generated localization system uses ARB inputs under `lib/l10n/`, configured through `l10n.yaml`.
- Locale negotiation follows the browser or platform locale. The application does not force a locale.
- No language selector or persisted manual locale choice exists yet.
- User-facing Flutter copy must come from generated localizations rather than hardcoded presentation strings. New source copy and its supported translations belong in the same implementation scope.
- Locale-specific product and marketing copy remains subject to product and translation review as content expands.

## 8. User input and future backend direction

### Provisional

- The landing page is expected to collect interested-user information in the future; likely examples include name and email.
- The eventual backend may be the same Microsoft/Azure-backed backend used by the main Fun App product.
- Flutter should remain decoupled from backend implementation through interfaces, repositories, data sources, DTO/boundary mapping, and configuration.

### Open

- Exact input model and required/optional fields.
- API endpoints, DTOs, authentication requirements, consent behavior, retention/deletion rules, and error contract.
- Whether the landing page uses an existing backend or a separately scoped service.

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

The temporary Flutter production shell establishes a static Fun App title, neutral description, canonical root URL, root indexing policy, branded icons, and manifest identity. Richer social metadata, sitemap strategy, and redesigned crawlable content remain future implementation and release concerns.

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
puro flutter analyze
puro flutter test
puro flutter build web
```

The active widget test suite covers the current shell. Verification should grow with implemented behavior, not through placeholder tests or speculative tooling.

The project tracks Flutter stable through Puro rather than establishing a permanent exact Flutter version pin.

## 12. Deployment

### Established

- GitHub Pages is the production deployment target.
- The production custom domain is `https://funapp.world` and uses root `/` deployment.
- The active workflow installs Puro 1.5.0, creates the named `fun-app-landing` environment from Flutter stable, generates localizations, analyzes, tests, and builds Flutter Web.
- The production artifact is `build/web`.
- `web/CNAME` and `web/robots.txt` are copied into the production artifact by the Flutter Web build.
- The archived Astro project is not built or deployed.

### Provisional

- Azure hosting may be considered in the future.

### Open

- Routing and any required 404/deep-link strategy if multiple Flutter routes are introduced.
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
