import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_legal_link.dart';
import 'package:fun_app_landing_page/presentation/legal/legal_routes.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';

/// Allows only non-executable absolute web and email destinations.
bool isSafeLegalLink(Uri? uri) =>
    uri != null &&
    uri.userInfo.isEmpty &&
    !uri.toString().contains(RegExp(r'[\x00-\x20\x7f]')) &&
    ((uri.scheme == 'https' &&
            uri.host.isNotEmpty &&
            (!uri.hasPort || uri.port == 443)) ||
        (uri.scheme == 'mailto' &&
            !uri.hasAuthority &&
            !uri.hasQuery &&
            !uri.hasFragment &&
            RegExp(r'^[^\s@/?#]+@[^\s@/?#]+\.[^\s@/?#]+$').hasMatch(uri.path)));

/// Focusable inline legal link retaining the existing branded link styling.
final class LegalTextLink extends StatelessWidget {
  /// Creates a link; validation also applies to programmatic activation.
  const LegalTextLink({
    required this.label,
    required this.uri,
    this.style,
    this.onOpen,
    super.key,
  });

  /// Readable text; never replaced by a transport URL.
  final String label;

  /// Validated destination.
  final Uri uri;

  /// Optional inherited Markdown typography.
  final TextStyle? style;

  /// Optional test seam for external navigation.
  final ValueChanged<Uri>? onOpen;

  void _open() {
    if (isSafeLegalLink(uri)) {
      if (onOpen case final callback?) {
        callback(uri);
      } else if (uri.scheme == 'mailto') {
        launchContactLink(uri);
      } else {
        launchExternalLinkInNewTab(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    identifier: managedLegalLinkIdentifier,
    link: true,
    linkUrl: isSafeLegalLink(uri) ? uri : null,
    label: label,
    onTap: _open,
    child: ExcludeSemantics(
      child: TextButton(
        onPressed: _open,
        style:
            TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 44),
              alignment: AlignmentDirectional.centerStart,
              foregroundColor: AppColors.energeticPlum,
              textStyle: style?.copyWith(decoration: TextDecoration.underline),
            ).copyWith(
              side: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? const BorderSide(color: AppColors.energeticPlum, width: 2)
                    : BorderSide.none,
              ),
            ),
        child: Text(label, softWrap: true),
      ),
    ),
  );
}

/// Informational navigation only; does not represent acceptance or consent.
final class LegalDocumentLinks extends StatelessWidget {
  /// Links shown before registration submission and Checkout retries.
  const LegalDocumentLinks({this.includePurchaseTerms = false, super.key});

  /// Adds the purchase document before automatic Checkout entry.
  final bool includePurchaseTerms;

  @override
  Widget build(BuildContext context) {
    final base = Uri.base;
    Widget link(String label, String path) {
      final destination = Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: '/',
        fragment: path,
      );
      return FooterLegalLink(
        semanticKey: Key('contextualLegalLink-$path'),
        label: label,
        url: destination,
        onSelected: () => launchExternalLinkInNewTab(destination),
      );
    }

    return Wrap(
      key: const Key('contextualLegalLinks'),
      spacing: 20,
      runSpacing: 8,
      children: [
        link(context.l10n.privacyNoticeNavigationLabel, LegalRoutes.privacy),
        link(context.l10n.landingFooterTermsOfUse, LegalRoutes.terms),
        if (includePurchaseTerms)
          link(context.l10n.legalPurchaseTermsLabel, LegalRoutes.purchaseTerms),
      ],
    );
  }
}
