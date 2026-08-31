import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_cta_button.dart';

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

  _PromotionalCardDesign get _design => switch (variant) {
    LandingPromotionalCardVariant.foundingFriends =>
      _PromotionalCardDesign.foundingFriends,
    LandingPromotionalCardVariant.venue => _PromotionalCardDesign.venue,
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
              return _WidePromotionalCard(card: this, design: design);
            }
            if (constraints.maxWidth >= _intermediateCompositionWidth) {
              return _IntermediatePromotionalCard(
                card: this,
                design: design,
                availableWidth: constraints.maxWidth,
              );
            }
            return _NarrowPromotionalCard(
              card: this,
              design: design,
              availableWidth: constraints.maxWidth,
            );
          },
        ),
      ),
    );
  }
}

enum _PromotionalArtworkSide { leading, trailing }

enum _PromotionalCardDesign {
  foundingFriends(
    semanticId: 'foundingFriends',
    backgroundColor: AppColors.yellowAccent,
    foregroundColor: AppColors.textPrimary,
    ctaAppearance: LandingCtaAppearance.brandBlue,
    imageAsset: AppAssets.foundingFriendsGroup,
    artworkSide: _PromotionalArtworkSide.trailing,
    intrinsicArtworkSize: Size(644, 410),
    wideHeight: 586,
    wideContentWidth: 494,
    wideContentInset: 128,
    wideArtworkTop: 88,
  ),

  venue(
    semanticId: 'venueCard',
    backgroundColor: AppColors.warmCharcoalAccent,
    foregroundColor: AppColors.lightForeground,
    ctaAppearance: LandingCtaAppearance.brandYellow,
    imageAsset: AppAssets.venueGroup,
    artworkSide: _PromotionalArtworkSide.leading,
    intrinsicArtworkSize: Size(666, 410),
    wideHeight: 444,
    wideContentWidth: 426,
    wideContentInset: 140,
    wideArtworkTop: 17,
  );

  const _PromotionalCardDesign({
    required this.semanticId,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.ctaAppearance,
    required this.imageAsset,
    required this.artworkSide,
    required this.intrinsicArtworkSize,
    required this.wideHeight,
    required this.wideContentWidth,
    required this.wideContentInset,
    required this.wideArtworkTop,
  });

  final String semanticId;
  final Color backgroundColor;
  final Color foregroundColor;
  final LandingCtaAppearance ctaAppearance;
  final String imageAsset;
  final _PromotionalArtworkSide artworkSide;
  final Size intrinsicArtworkSize;
  final double wideHeight;
  final double wideContentWidth;
  final double wideContentInset;
  final double wideArtworkTop;

  static const wideArtworkViewportSize = Size(673, 410);

  double wideContentLeftFor(double availableWidth) => switch (artworkSide) {
    _PromotionalArtworkSide.trailing => wideContentInset,
    _PromotionalArtworkSide.leading =>
      availableWidth - wideContentInset - wideContentWidth,
  };

  double wideArtworkLeftFor(double availableWidth) => switch (artworkSide) {
    // At the 1360px Figma width this resolves to x=716 and retains the
    // intended 29px clipping beyond the card's trailing edge.
    _PromotionalArtworkSide.trailing => availableWidth - 644,
    _PromotionalArtworkSide.leading => -7,
  };
}

final class _WidePromotionalCard extends StatelessWidget {
  const _WidePromotionalCard({required this.card, required this.design});

  final LandingPromotionalCard card;
  final _PromotionalCardDesign design;

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
                child: _PromotionalCardContent(
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
              width: _PromotionalCardDesign.wideArtworkViewportSize.width,
              height: _PromotionalCardDesign.wideArtworkViewportSize.height,
              child: _PromotionalCardArtwork(
                card: card,
                design: design,
                viewportSize: _PromotionalCardDesign.wideArtworkViewportSize,
                fit: BoxFit.contain,
                alignment:
                    design.artworkSide == _PromotionalArtworkSide.trailing
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

final class _IntermediatePromotionalCard extends StatelessWidget {
  const _IntermediatePromotionalCard({
    required this.card,
    required this.design,
    required this.availableWidth,
  });

  final LandingPromotionalCard card;
  final _PromotionalCardDesign design;
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
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
        textDirection: design.artworkSide == _PromotionalArtworkSide.leading
            ? TextDirection.rtl
            : TextDirection.ltr,
        children: [
          Expanded(
            child: _PromotionalCardContent(
              card: card,
              design: design,
              headingSize: AppSizes.sectionHeadingSizeFor(availableWidth),
              ctaSpacing: 32,
            ),
          ),
          SizedBox(width: gap),
          _PromotionalCardArtwork(
            card: card,
            design: design,
            viewportSize: Size(artworkWidth, artworkHeight),
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }
}

final class _NarrowPromotionalCard extends StatelessWidget {
  const _NarrowPromotionalCard({
    required this.card,
    required this.design,
    required this.availableWidth,
  });

  final LandingPromotionalCard card;
  final _PromotionalCardDesign design;
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
            child: _PromotionalCardContent(
              card: card,
              design: design,
              headingSize: AppSizes.sectionHeadingSizeFor(availableWidth),
              ctaSpacing: 32,
            ),
          ),
          const SizedBox(height: 32),
          _PromotionalCardArtwork(
            card: card,
            design: design,
            viewportSize: Size(artworkWidth, artworkHeight),
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }
}

final class _PromotionalCardContent extends StatelessWidget {
  const _PromotionalCardContent({
    required this.card,
    required this.design,
    required this.headingSize,
    required this.ctaSpacing,
  });

  final LandingPromotionalCard card;
  final _PromotionalCardDesign design;
  final double headingSize;
  final double ctaSpacing;

  @override
  Widget build(BuildContext context) => Column(
    key: Key('${design.semanticId}ContentBounds'),
    mainAxisSize: MainAxisSize.min,
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
          style: AppTextStyles.landingSectionHeading.copyWith(
            fontSize: headingSize,
            letterSpacing: headingSize * -0.01,
            color: design.foregroundColor,
          ),
        ),
      ),
      const SizedBox(height: 20),
      for (var index = 0; index < card.bodyParagraphs.length; index++) ...[
        if (index > 0) const SizedBox(height: 12),
        Text(
          card.bodyParagraphs[index],
          key: Key('${design.semanticId}Body$index'),
          textAlign: TextAlign.center,
          style: AppTextStyles.landingStatBody.copyWith(
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
        ),
      ),
    ],
  );
}

final class _PromotionalCardArtwork extends StatelessWidget {
  const _PromotionalCardArtwork({
    required this.card,
    required this.design,
    required this.viewportSize,
    required this.fit,
    required this.alignment,
  });

  final LandingPromotionalCard card;
  final _PromotionalCardDesign design;
  final Size viewportSize;
  final BoxFit fit;
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
