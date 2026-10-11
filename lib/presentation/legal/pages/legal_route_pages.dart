import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_placeholder_page.dart';

/// Typed route for the review-only Terms document.
@RoutePage()
final class TermsPage extends StatelessWidget {
  /// Creates the Terms route page.
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) => const LegalPlaceholderPage(
    kind: LegalPlaceholderKind.terms,
  );
}

/// Typed route for the review-only Refund and Cancellation document.
@RoutePage()
final class RefundsPage extends StatelessWidget {
  /// Creates the Refund and Cancellation route page.
  const RefundsPage({super.key});

  @override
  Widget build(BuildContext context) => const LegalPlaceholderPage(
    kind: LegalPlaceholderKind.refunds,
  );
}

/// Typed route for the Cookie Policy excerpt.
@RoutePage()
final class CookiePolicyPage extends StatelessWidget {
  /// Creates the Cookie Policy route page.
  const CookiePolicyPage({super.key});

  @override
  Widget build(BuildContext context) => const LegalPlaceholderPage(
    kind: LegalPlaceholderKind.cookies,
  );
}

/// Typed route for the review-only Cookie Banner document.
@RoutePage()
final class CookieBannerPage extends StatelessWidget {
  /// Creates the Cookie Banner route page.
  const CookieBannerPage({super.key});

  @override
  Widget build(BuildContext context) => const LegalPlaceholderPage(
    kind: LegalPlaceholderKind.cookieBanner,
  );
}
