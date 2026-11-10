import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/domain/legal/entities/legal_document.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_document_page.dart';

/// Stable route for the selected published legal document.
@RoutePage()
final class TermsPage extends StatelessWidget {
  /// Creates the document page.
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) => const LegalDocumentPage(
    documentId: LegalDocumentId.termsOfUse,
  );
}

/// Stable route for the selected published legal document.
@RoutePage()
final class PurchaseTermsPage extends StatelessWidget {
  /// Creates the document page.
  const PurchaseTermsPage({super.key});

  @override
  Widget build(BuildContext context) => const LegalDocumentPage(
    documentId: LegalDocumentId.foundingFriendPurchaseTerms,
  );
}

/// Stable route for the selected published legal document.
@RoutePage()
final class UserAgreementPage extends StatelessWidget {
  /// Creates the document page.
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) => const LegalDocumentPage(
    documentId: LegalDocumentId.userAgreement,
  );
}

/// Stable route for the selected published legal document.
@RoutePage()
final class AcceptableUsePolicyPage extends StatelessWidget {
  /// Creates the document page.
  const AcceptableUsePolicyPage({super.key});

  @override
  Widget build(BuildContext context) => const LegalDocumentPage(
    documentId: LegalDocumentId.acceptableUsePolicy,
  );
}
