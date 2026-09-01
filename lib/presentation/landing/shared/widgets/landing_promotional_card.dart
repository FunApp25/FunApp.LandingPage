import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_intermediate_promotional_card.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_narrow_promotional_card.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_design.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_wide_promotional_card.dart';

/// The two distinct promotional-card treatments in the landing design.
enum LandingPromotionalCardVariant {
  /// Yellow Founding Friends card with artwork on the trailing side.
  foundingFriends,

  /// Charcoal venue card with artwork on the leading side.
  venue,
}

/// Shared responsive presentation for the two Figma promotional cards.
///
/// Callers provide localized content and choose a design variant. Card
/// geometry remains owned here so wide, intermediate, and narrow behavior
/// stays coordinated without exposing Figma positioning values publicly.
final class LandingPromotionalCard extends StatelessWidget {
  /// Creates a responsive promotional card.
  const LandingPromotionalCard({
    required this.variant,
    required this.heading,
    required this.bodyParagraphs,
    required this.ctaLabel,
    required this.imageSemanticLabel,
    super.key,
  });

  /// Established visual treatment for this card.
  final LandingPromotionalCardVariant variant;

  /// Localized card heading.
  final String heading;

  /// Localized body paragraphs in reading order.
  final List<String> bodyParagraphs;

  /// Localized visual-only CTA label.
  final String ctaLabel;

  /// Localized concise image description.
  final String imageSemanticLabel;

  static const _wideCompositionWidth = 1280.0;
  static const _intermediateCompositionWidth = 780.0;

  LandingPromotionalCardDesign get _design => switch (variant) {
    LandingPromotionalCardVariant.foundingFriends =>
      LandingPromotionalCardDesign.foundingFriends,
    LandingPromotionalCardVariant.venue => LandingPromotionalCardDesign.venue,
  };

  @override
  Widget build(BuildContext context) {
    final design = _design;

    return ClipRRect(
      key: Key('${design.semanticId}CardClip'),
      borderRadius: const BorderRadius.all(
        Radius.circular(AppSizes.cardRadius),
      ),
      child: ColoredBox(
        color: design.backgroundColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= _wideCompositionWidth) {
              return LandingWidePromotionalCard(card: this, design: design);
            } else if (constraints.maxWidth >= _intermediateCompositionWidth) {
              return LandingIntermediatePromotionalCard(
                card: this,
                design: design,
                availableWidth: constraints.maxWidth,
              );
            } else {
              return LandingNarrowPromotionalCard(
                card: this,
                design: design,
                availableWidth: constraints.maxWidth,
              );
            }
          },
        ),
      ),
    );
  }
}
