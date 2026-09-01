import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_artwork.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_design.dart';

/// Narrow shared promotional-card composition.
final class LandingNarrowPromotionalCard extends StatelessWidget {
  /// Creates the narrow promotional-card composition.
  const LandingNarrowPromotionalCard({
    required this.card,
    required this.design,
    required this.availableWidth,
    super.key,
  });

  /// Public promotional-card content and variant.
  final LandingPromotionalCard card;

  /// Resolved visual tokens for the card.
  final LandingPromotionalCardDesign design;

  /// Width available to the card.
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = availableWidth < 600 ? 24.0 : 48.0;
    final artworkWidth = (availableWidth - 32).clamp(0.0, 360.0);
    final artworkHeight =
        artworkWidth / design.intrinsicArtworkSize.aspectRatio;

    return Padding(
      key: Key('${design.semanticId}NarrowLayout'),
      padding: EdgeInsets.only(top: availableWidth < 600 ? 48 : 56),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: LandingPromotionalCardContent(
              card: card,
              design: design,
              headingSize: AppSizes.sectionHeadingSizeFor(availableWidth),
              ctaSpacing: 32,
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: design.responsiveArtworkAlignment,
            child: LandingPromotionalCardArtwork(
              card: card,
              design: design,
              viewportSize: Size(artworkWidth, artworkHeight),
              fit: BoxFit.contain,
              alignment: design.responsiveArtworkAlignment,
            ),
          ),
        ],
      ),
    );
  }
}
