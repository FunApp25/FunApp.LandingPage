import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_privacy_notice_link.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Footer legal labels in their approved Figma display order.
final class FooterLegalItems extends StatelessWidget {
  /// Creates the legal-label group.
  const FooterLegalItems({
    required this.labels,
    required this.onPrivacyNoticeSelected,
    this.spacing = 40,
    this.runSpacing = 12,
    super.key,
  });

  /// Five labels, beginning with the functional Privacy destination.
  final List<String> labels;

  /// Opens the authoritative hosted Privacy Notice destination.
  final VoidCallback onPrivacyNoticeSelected;

  /// Horizontal spacing between labels.
  final double spacing;

  /// Vertical spacing between wrapped runs.
  final double runSpacing;

  @override
  Widget build(BuildContext context) => Wrap(
    key: const Key('footerLegalItems'),
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: spacing,
    runSpacing: runSpacing,
    children: [
      FooterPrivacyNoticeLink(
        label: labels.first,
        onSelected: onPrivacyNoticeSelected,
      ),
      for (var index = 1; index < labels.length; index++)
        Semantics(
          key: Key('footerLegalLabel$index'),
          label: labels[index],
          excludeSemantics: true,
          child: Text(
            labels[index],
            key: Key('footerLegalText$index'),
            style: LandingTextStyles.footerLegal,
          ),
        ),
    ],
  );
}
