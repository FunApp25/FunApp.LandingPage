import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card_design.dart';

/// Semantic artwork viewport within a promotional card.
final class LandingPromotionalCardArtwork extends StatelessWidget {
  /// Creates the promotional-card artwork viewport.
  const LandingPromotionalCardArtwork({
    required this.card,
    required this.design,
    required this.viewportSize,
    required this.fit,
    required this.alignment,
    super.key,
  });

  /// Public promotional-card content and variant.
  final LandingPromotionalCard card;

  /// Resolved visual tokens for the card.
  final LandingPromotionalCardDesign design;

  /// Responsive artwork viewport size.
  final Size viewportSize;

  /// Artwork fit within the viewport.
  final BoxFit fit;

  /// Artwork alignment within the viewport.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Semantics(
    key: Key('${design.semanticId}ImageSemantics'),
    sortKey: const OrdinalSortKey(2),
    label: card.imageSemanticLabel,
    image: true,
    excludeSemantics: true,
    child: SizedBox.fromSize(
      key: Key('${design.semanticId}ArtworkViewport'),
      size: viewportSize,
      child: ClipRect(
        child: FittedBox(
          key: Key('${design.semanticId}ArtworkFit'),
          fit: fit,
          alignment: alignment,
          child: SizedBox.fromSize(
            key: Key('${design.semanticId}IntrinsicArtworkBounds'),
            size: design.intrinsicArtworkSize,
            child: Image.asset(
              design.imageAsset,
              key: Key('${design.semanticId}Image'),
              width: design.intrinsicArtworkSize.width,
              height: design.intrinsicArtworkSize.height,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    ),
  );
}
