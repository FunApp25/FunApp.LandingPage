import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_artwork.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_design.dart';

/// Intermediate shared promotional-card composition.
final class LandingIntermediatePromotionalCard extends StatelessWidget {
  /// Creates the intermediate promotional-card composition.
  const LandingIntermediatePromotionalCard({
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
    final usesRoomierInsets = availableWidth >= 1000;
    final horizontalPadding = usesRoomierInsets ? 64.0 : 40.0;
    final verticalPadding = usesRoomierInsets ? 64.0 : 48.0;
    final gap = usesRoomierInsets ? 48.0 : 32.0;
    final artworkWidth = (availableWidth * 0.43).clamp(340.0, 480.0);
    final artworkHeight =
        artworkWidth / design.intrinsicArtworkSize.aspectRatio;

    return Padding(
      key: Key('${design.semanticId}IntermediateLayout'),
      padding: EdgeInsets.only(
        left: design.artworkSide == LandingPromotionalArtworkSide.trailing
            ? horizontalPadding
            : 0,
        top: verticalPadding,
        right: design.artworkSide == LandingPromotionalArtworkSide.leading
            ? horizontalPadding
            : 0,
        bottom: verticalPadding,
      ),
      child: Row(
        textDirection:
            design.artworkSide == LandingPromotionalArtworkSide.leading
            ? TextDirection.rtl
            : TextDirection.ltr,
        children: [
          Expanded(
            child: LandingPromotionalCardContent(
              card: card,
              design: design,
              headingSize: AppSizes.sectionHeadingSizeFor(availableWidth),
              ctaSpacing: 32,
            ),
          ),
          SizedBox(width: gap),
          LandingPromotionalCardArtwork(
            card: card,
            design: design,
            viewportSize: Size(artworkWidth, artworkHeight),
            fit: BoxFit.contain,
            alignment: design.responsiveArtworkAlignment,
          ),
        ],
      ),
    );
  }
}
