import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_route_controller.dart';
import 'package:fun_app_landing_page/presentation/legal/legal_routes.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_document_page.dart';

/// Hosts the approved Fun App Ltd Privacy Notice as a dedicated web page.
final class PrivacyNoticePage extends StatelessWidget {
  /// Creates the Privacy Notice page.
  const PrivacyNoticePage({
    this.markdownData,
    this.onLinkLaunch,
    this.landingRouteController,
    super.key,
  });

  /// Optional already-loaded canonical content used by deterministic tests.
  final String? markdownData;

  /// Optional link-launch override used by deterministic tests.
  final ValueChanged<Uri>? onLinkLaunch;

  /// Coordinates navigation to landing-page anchors.
  final LandingRouteController? landingRouteController;

  /// Flutter route represented by the GitHub-Pages-safe hash URL.
  static const String routeName = LegalRoutes.privacy;

  /// Canonical public URL for the currently hosted Privacy Notice.
  static const canonicalUrl = 'https://funapp.world/#/privacy';

  /// Canonical website representation of the approved legal copy.
  static const assetPath = 'assets/legal/privacy_notice.md';

  static final Future<String> _privacyNotice = rootBundle.loadString(assetPath);

  @override
  Widget build(BuildContext context) => LegalDocumentPage(
    documentId: 'privacy',
    title: context.l10n.privacyNoticeNavigationLabel,
    markdownData: markdownData,
    markdownFuture: _privacyNotice,
    pageKey: const Key('privacyNoticePage'),
    scrollKey: const Key('privacyNoticeScrollView'),
    contentKey: const Key('privacyNoticeContent'),
    markdownKey: const Key('privacyNoticeMarkdown'),
    documentHeadingKey: const Key('privacyNoticeDocumentHeading'),
    onLinkLaunch: onLinkLaunch,
    landingRouteController: landingRouteController,
  );
}
