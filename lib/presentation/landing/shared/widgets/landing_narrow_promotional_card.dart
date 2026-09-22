import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_artwork.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_design.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

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
    final usesMobileFidelity = MediaQuery.sizeOf(context).width < 600;
    final horizontalPadding = usesMobileFidelity ? 16.0 : 48.0;
    final artworkSize = usesMobileFidelity
        ? const Size(382, 233)
        : Size(
            (availableWidth - 32).clamp(0.0, 360.0),
            (availableWidth - 32).clamp(0.0, 360.0) /
                design.intrinsicArtworkSize.aspectRatio,
          );
    final verticalPadding = usesMobileFidelity ? 80.0 : 56.0;
    final contentToArtworkGap = usesMobileFidelity ? 80.0 : 32.0;

    return Padding(
      key: Key('${design.semanticId}NarrowLayout'),
      padding: usesMobileFidelity
          ? EdgeInsets.symmetric(vertical: verticalPadding)
          : EdgeInsets.only(top: verticalPadding),
      child: Column(
        children: [
          Padding(
            key: Key('${design.semanticId}NarrowContentPadding'),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: LandingPromotionalCardContent(
              card: card,
              design: design,
              headingSize: usesMobileFidelity
                  ? 32
                  : AppSizes.sectionHeadingSizeFor(availableWidth),
              headingLineHeight: usesMobileFidelity ? 40 : null,
              headingToBodySpacing: usesMobileFidelity ? 16 : 20,
              bodyStyle: usesMobileFidelity
                  ? LandingTextStyles.membershipCardBody
                  : null,
              ctaSpacing: usesMobileFidelity ? 24 : 32,
              prominentCtaUsesFlexibleLayout:
                  usesMobileFidelity || availableWidth < 640,
            ),
          ),
          SizedBox(height: contentToArtworkGap),
          if (usesMobileFidelity)
            SizedBox(
              height: artworkSize.height,
              child: OverflowBox(
                minWidth: artworkSize.width,
                maxWidth: artworkSize.width,
                child: LandingPromotionalCardArtwork(
                  card: card,
                  design: design,
                  viewportSize: artworkSize,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            )
          else
            Align(
              alignment: design.responsiveArtworkAlignment,
              child: LandingPromotionalCardArtwork(
                card: card,
                design: design,
                viewportSize: artworkSize,
                fit: BoxFit.contain,
                alignment: design.responsiveArtworkAlignment,
              ),
            ),
        ],
      ),
    );
  }
}
