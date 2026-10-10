import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_route_controller.dart';
import 'package:fun_app_landing_page/presentation/legal/legal_routes.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_document_page.dart';
import 'package:fun_app_landing_page/presentation/privacy/pages/privacy_notice_page.dart';

/// Review state for the public legal-document routes.
enum LegalPlaceholderKind {
  /// Terms of Use review document.
  terms,

  /// Refund & Cancellation Policy review document.
  refunds,

  /// Cookie information taken from the approved Privacy Notice.
  cookies,

  /// Review-only cookie-banner information with no consent controls.
  cookieBanner,
}

/// Branded Markdown page for review-only and cookie-information documents.
final class LegalPlaceholderPage extends StatelessWidget {
  /// Creates one legal-document route.
  const LegalPlaceholderPage({
    required this.kind,
    this.markdownData,
    this.landingRouteController,
    super.key,
  });

  /// Review-only Terms of Use route.
  static const String termsRouteName = LegalRoutes.terms;

  /// Review-only Refund & Cancellation Policy route.
  static const String refundsRouteName = LegalRoutes.refunds;

  /// Cookie Policy route.
  static const String cookiesRouteName = LegalRoutes.cookies;

  /// Review-only cookie-banner route.
  static const String cookieBannerRouteName = LegalRoutes.cookieBanner;

  /// Determines the document source and localized title/status.
  final LegalPlaceholderKind kind;

  /// Optional already-loaded Markdown used by deterministic tests.
  final String? markdownData;

  /// Coordinates navigation to landing-page anchors.
  final LandingRouteController? landingRouteController;

  static final Future<String> _terms = rootBundle.loadString(
    'assets/legal/terms_of_use.md',
  );
  static final Future<String> _refunds = rootBundle.loadString(
    'assets/legal/refund_cancellation_policy.md',
  );
  static final Future<String> _cookieBanner = rootBundle.loadString(
    'assets/legal/cookie_banner.md',
  );
  static final Future<String> _cookies = rootBundle
      .loadString(PrivacyNoticePage.assetPath)
      .then(extractCookiePolicyMarkdown);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (kind) {
      LegalPlaceholderKind.terms => l10n.landingFooterTermsOfUse,
      LegalPlaceholderKind.refunds =>
        l10n.landingFooterRefundCancellationPolicy,
      LegalPlaceholderKind.cookies => l10n.landingFooterCookiePolicy,
      LegalPlaceholderKind.cookieBanner => l10n.landingFooterCookieBanner,
    };
    final future = switch (kind) {
      LegalPlaceholderKind.terms => _terms,
      LegalPlaceholderKind.refunds => _refunds,
      LegalPlaceholderKind.cookies => _cookies,
      LegalPlaceholderKind.cookieBanner => _cookieBanner,
    };
    final status = kind == LegalPlaceholderKind.cookies
        ? l10n.cookiePolicyPrivacyExcerptStatus
        : l10n.legalPlaceholderDraftStatus;

    return LegalDocumentPage(
      documentId: kind.name,
      title: title,
      markdownData: markdownData,
      markdownFuture: future,
      status: status,
      statusKey: Key('legalPlaceholderStatus-${kind.name}'),
      showLocalizedHeading: true,
      headingKey: Key('legalPlaceholderHeading-${kind.name}'),
      pageKey: Key('legalPlaceholderPage-${kind.name}'),
      scrollKey: Key('legalPlaceholderScrollView-${kind.name}'),
      contentKey: Key('legalPlaceholderContent-${kind.name}'),
      markdownKey: Key('legalDocumentMarkdown-${kind.name}'),
      landingRouteController: landingRouteController,
    );
  }
}

/// Extracts the approved cookie section from the canonical Privacy Notice.
String extractCookiePolicyMarkdown(String privacyNoticeMarkdown) {
  const startHeading = '## 10. Cookies and similar technologies';
  const endHeading = '## 11. Your data protection rights';
  final start = privacyNoticeMarkdown.indexOf(startHeading);
  final end = privacyNoticeMarkdown.indexOf(endHeading, start + 1);

  if (start >= 0 && end > start) {
    return privacyNoticeMarkdown.substring(start, end).trim();
  } else {
    throw const FormatException(
      'The canonical Privacy Notice cookie section could not be found.',
    );
  }
}
