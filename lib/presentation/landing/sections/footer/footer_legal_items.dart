import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_legal_link.dart';

/// Localized label and behavior for one footer legal control.
typedef FooterLegalItemData = ({
  Key semanticKey,
  String label,
  VoidCallback onSelected,
});

/// Footer legal labels in their approved Figma display order.
final class FooterLegalItems extends StatelessWidget {
  /// Creates the legal-label group.
  const FooterLegalItems({
    required this.items,
    this.spacing = 40,
    this.runSpacing = 12,
    super.key,
  });

  /// Five functional controls in the approved Figma display order.
  final List<FooterLegalItemData> items;

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
      for (final item in items)
        FooterLegalLink(
          semanticKey: item.semanticKey,
          label: item.label,
          onSelected: item.onSelected,
        ),
    ],
  );
}
