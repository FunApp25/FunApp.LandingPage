import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_artwork.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_design.dart';

/// Wide shared promotional-card composition.
final class LandingWidePromotionalCard extends StatelessWidget {
  /// Creates the wide promotional-card composition.
  const LandingWidePromotionalCard({
    required this.card,
    required this.design,
    super.key,
  });

  /// Public promotional-card content and variant.
  final LandingPromotionalCard card;

  /// Resolved visual tokens for the card.
  final LandingPromotionalCardDesign design;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final availableWidth = constraints.maxWidth;
      final contentLeft = design.wideContentLeftFor(availableWidth);
      final contentRight =
          availableWidth - contentLeft - design.wideContentWidth;

      return ConstrainedBox(
        key: Key('${design.semanticId}WideLayout'),
        constraints: BoxConstraints(minHeight: design.wideHeight),
        child: Stack(
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: contentLeft,
                right: contentRight,
              ),
              child: SizedBox(
                width: design.wideContentWidth,
                child: LandingPromotionalCardContent(
                  card: card,
                  design: design,
                  headingSize: 44,
                  ctaSpacing: 40,
                ),
              ),
            ),
            Positioned(
              top: design.wideArtworkTop,
              left: design.wideArtworkLeftFor(availableWidth),
              width: LandingPromotionalCardDesign.wideArtworkViewportSize.width,
              height:
                  LandingPromotionalCardDesign.wideArtworkViewportSize.height,
              child: LandingPromotionalCardArtwork(
                card: card,
                design: design,
                viewportSize:
                    LandingPromotionalCardDesign.wideArtworkViewportSize,
                fit: BoxFit.contain,
                alignment:
                    design.artworkSide == LandingPromotionalArtworkSide.trailing
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
              ),
            ),
          ],
        ),
      );
    },
  );
}
