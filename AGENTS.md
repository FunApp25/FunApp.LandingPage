# Coding Agent Guidance

These rules apply repository-wide. More specific nested `AGENTS.md` files may add constraints if introduced later.

## Source order

1. Follow system and current task instructions.
2. Follow the applicable `AGENTS.md` files.
3. Read `SPECIFICATIONS.md` before product, architecture, data-handling, SEO, accessibility, or deployment changes; it is the authoritative project truth.
4. Use `README.md` for setup and current contributor workflow.
5. Verify documentation against source and configuration. Report discrepancies instead of silently resolving them.

## Working approach

- Make the smallest coherent change that satisfies the task.
- Preserve established decisions and label provisional or open matters accurately.
- Do not implement speculative features, folders, abstractions, integrations, or dependencies.
- Do not create `PLANS.md`, architecture notes, or other governance files unless explicitly requested.
- Treat `archive/astro_site/` as read-only historical reference by default. Do not implement production work there or restore Astro dependencies/build steps unless explicitly requested.
- Review the complete diff, preserve unrelated work, and leave a clear handoff with verification results and remaining risks.

## Flutter Web and tooling

- This project targets Flutter Web only. Do not add Android, iOS, macOS, Linux, or Windows platforms or guidance.
- Use the Puro environment `fun-app-landing`, which tracks Flutter stable.
- Run Flutter and Dart commands through `puro flutter ...` and `puro dart ...`.
- On a fresh checkout, create/select the environment with `puro create fun-app-landing stable` and `puro use fun-app-landing`.
- When Dart/Flutter MCP tooling is available, register the repository root before project-scoped tools and use it for supported analysis or package investigation. Puro remains the command runner for repository verification.
- Do not add IDE configuration unless the task requests it.

## Architecture boundaries

- Introduce layer-first structure only as active behavior requires it: `presentation`, `application`, `domain`, and `data`; use `core` for bootstrap, configuration, and shared wiring rather than miscellaneous code.
- `presentation` owns Flutter UI and may depend on application/domain abstractions and shared presentation code.
- `application` coordinates workflows and state and depends on domain abstractions.
- `domain` contains pure Dart rules, entities, value objects, and contracts without Flutter, web, vendor, or raw API concerns.
- `data` implements repositories, data sources, DTO mapping, and raw external I/O.
- Use BLoC/Cubit when real application state or workflows justify it. Do not add blocs to static content merely for consistency.
- Put stable user-input rules in suitable domain value objects/validation, with application coordination where needed; UI-only validation is insufficient for backend-bound data.
- Put external I/O behind repository/data-source boundaries. Widgets must not perform raw backend calls, and backend/vendor details must not leak into stable domain contracts.
- Do not create a default `use_cases/` layer or assume backend integration already exists.

## Public-web implementation

- Make responsive decisions from constraints. Prefer `LayoutBuilder` locally and `MediaQuery.sizeOf` only when app/window size is genuinely needed; avoid device-name assumptions.
- Keep app-owned widgets focused and reusable, and avoid deeply nested monolithic `build` methods.
- Centralize reusable design values when a real design system is introduced.
- Treat keyboard operation, focus visibility, reduced motion, meaningful controls, Flutter web semantics, crawlability, and document metadata as implementation quality—not cleanup.
- Do not assume Flutter provides Astro-equivalent SEO. Preserve or deliberately replace public-web metadata and indexing behavior when relevant.

## Security, privacy, and dependencies

- Apply privacy by design/default and minimize collected data.
- Never place secrets or credentials in Flutter code, configuration, examples, or web bundles. Values injected into Flutter Web are publicly recoverable.
- Treat client-side validation as usability, not a security boundary; validate and authorize on the backend where applicable.
- Do not put personal information in logs, analytics, diagnostics, crash reports, fixtures, or examples without explicit justified handling.
- Validate untrusted backend responses at data boundaries and use HTTPS for production calls.
- Avoid unnecessary third-party scripts and SDKs. Review dependency changes for maintenance, supply-chain, privacy, and data-handling impact.
- Do not infer Entra, OIDC, mobile-app API, or authentication contracts for this landing page.

## Verification and documentation

- For Flutter changes, normally run `puro flutter analyze`, relevant tests when they exist, and `puro flutter build web` when build behavior may be affected.
- For documentation-only changes, proofread all affected documents and run `git diff --check`.
- Keep `README.md`, `AGENTS.md`, and `SPECIFICATIONS.md` aligned with implementation status. Never describe intended behavior as already implemented.
- For runtime/layout debugging, reason from code, tests, and errors first. Do not claim Flutter DevTools evidence without a live runtime/DTD connection; if runtime evidence is needed, tell the developer exactly what to inspect in DevTools.
