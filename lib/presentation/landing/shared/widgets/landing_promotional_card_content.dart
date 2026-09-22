import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_cta_button.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_design.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Localized copy and optional CTA action within a promotional card.
final class LandingPromotionalCardContent extends StatelessWidget {
  /// Creates the promotional-card content.
  const LandingPromotionalCardContent({
    required this.card,
    required this.design,
    required this.headingSize,
    required this.ctaSpacing,
    this.headingLineHeight,
    this.headingToBodySpacing = 20,
    this.bodyStyle,
    this.prominentCtaUsesFlexibleLayout = false,
    super.key,
  });

  /// Public promotional-card content and variant.
  final LandingPromotionalCard card;

  /// Resolved visual tokens for the card.
  final LandingPromotionalCardDesign design;

  /// Responsive heading font size.
  final double headingSize;

  /// Spacing before the CTA.
  final double ctaSpacing;

  /// Optional responsive heading line height.
  final double? headingLineHeight;

  /// Spacing between the heading and first body paragraph.
  final double headingToBodySpacing;

  /// Optional responsive body treatment.
  final TextStyle? bodyStyle;

  /// Whether the full-width prominent CTA must use a flexible label row.
  final bool prominentCtaUsesFlexibleLayout;

  @override
  Widget build(BuildContext context) {
    final headingStyle = headingLineHeight == null
        ? LandingTextStyles.sectionHeading
        : LandingTextStyles.sectionHeading.copyWith(
            height: headingLineHeight! / headingSize,
          );

    return Column(
      key: Key('${design.semanticId}ContentBounds'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          key: Key('${design.semanticId}HeadingSemantics'),
          sortKey: const OrdinalSortKey(1),
          label: card.heading,
          header: true,
          excludeSemantics: true,
          child: Text(
            card.heading,
            key: Key('${design.semanticId}HeadingText'),
            textAlign: TextAlign.center,
            style: headingStyle.copyWith(
              fontSize: headingSize,
              letterSpacing: headingSize * -0.01,
              color: design.foregroundColor,
            ),
          ),
        ),
        SizedBox(height: headingToBodySpacing),
        for (var index = 0; index < card.bodyParagraphs.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          Text(
            card.bodyParagraphs[index],
            key: Key('${design.semanticId}Body$index'),
            textAlign: TextAlign.center,
            style: (bodyStyle ?? LandingTextStyles.statBody).copyWith(
              color: design.foregroundColor,
            ),
          ),
        ],
        SizedBox(height: ctaSpacing),
        SizedBox(
          width: double.infinity,
          child: LandingCtaButton(
            key: Key('${design.semanticId}Cta'),
            label: card.ctaLabel,
            size: LandingCtaSize.prominent,
            appearance: design.ctaAppearance,
            arrowKey: Key('${design.semanticId}CtaArrow'),
            prominentContentExpands: prominentCtaUsesFlexibleLayout,
            onPressed: card.onCtaPressed,
          ),
        ),
      ],
    );
  }
}
