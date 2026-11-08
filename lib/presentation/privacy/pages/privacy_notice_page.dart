import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/domain/legal/entities/legal_document.dart';
import 'package:fun_app_landing_page/presentation/legal/legal_routes.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_document_page.dart';

/// Stable Privacy route backed solely by the published legal service.
@RoutePage()
final class PrivacyNoticePage extends StatelessWidget {
  /// Creates the Privacy Notice page.
  const PrivacyNoticePage({this.onLinkLaunch, super.key});

  /// Optional browser navigation override.
  final ValueChanged<Uri>? onLinkLaunch;

  /// Stable GitHub-Pages-safe hash route.
  static const String routeName = LegalRoutes.privacy;

  /// Stable public website URL.
  static const canonicalUrl = 'https://funapp.world/#/privacy';

  @override
  Widget build(BuildContext context) => LegalDocumentPage(
    documentId: LegalDocumentId.privacyNotice,
    onLinkLaunch: onLinkLaunch,
  );
}
