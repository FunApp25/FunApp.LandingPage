import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_cta_button.dart';

/// Side of a promotional card that owns its artwork.
enum LandingPromotionalArtworkSide {
  /// Artwork anchors to the leading edge.
  leading,

  /// Artwork anchors to the trailing edge.
  trailing,
}

/// Internal visual tokens for the shared promotional-card variants.
enum LandingPromotionalCardDesign {
  /// Founding Friends promotional-card tokens.
  foundingFriends(
    semanticId: 'foundingFriends',
    backgroundColor: AppColors.yellowAccent,
    foregroundColor: AppColors.textPrimary,
    ctaAppearance: LandingCtaAppearance.brandBlue,
    imageAsset: AppAssets.foundingFriendsGroup,
    artworkSide: LandingPromotionalArtworkSide.trailing,
    intrinsicArtworkSize: Size(673, 410),
    wideHeight: 534,
    wideContentWidth: 494,
    wideContentInset: 128,
    wideArtworkTop: 62,
  ),

  /// Venue promotional-card tokens.
  venue(
    semanticId: 'venueCard',
    backgroundColor: AppColors.warmCharcoalAccent,
    foregroundColor: AppColors.lightForeground,
    ctaAppearance: LandingCtaAppearance.brandYellow,
    imageAsset: AppAssets.venueGroup,
    artworkSide: LandingPromotionalArtworkSide.leading,
    intrinsicArtworkSize: Size(673, 410),
    wideHeight: 444,
    wideContentWidth: 426,
    wideContentInset: 140,
    wideArtworkTop: 17,
  );

  const LandingPromotionalCardDesign({
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

  /// Stable key prefix for this design.
  final String semanticId;

  /// Card background color.
  final Color backgroundColor;

  /// Card foreground color.
  final Color foregroundColor;

  /// Visual CTA treatment.
  final LandingCtaAppearance ctaAppearance;

  /// Committed artwork asset.
  final String imageAsset;

  /// Side where the artwork is anchored.
  final LandingPromotionalArtworkSide artworkSide;

  /// Intrinsic committed artwork size.
  final Size intrinsicArtworkSize;

  /// Minimum height of the wide composition.
  final double wideHeight;

  /// Copy width in the wide composition.
  final double wideContentWidth;

  /// Copy inset in the wide composition.
  final double wideContentInset;

  /// Artwork top offset in the wide composition.
  final double wideArtworkTop;

  /// Artwork viewport size in the wide composition.
  static const wideArtworkViewportSize = Size(673, 410);

  /// Resolves the copy's left offset in the wide composition.
  double wideContentLeftFor(double availableWidth) => switch (artworkSide) {
    LandingPromotionalArtworkSide.trailing => wideContentInset,
    LandingPromotionalArtworkSide.leading =>
      availableWidth - wideContentInset - wideContentWidth,
  };

  /// Resolves the artwork's left offset in the wide composition.
  double wideArtworkLeftFor(double availableWidth) => switch (artworkSide) {
    // At the 1360px Figma width this resolves to x=716 and retains the
    // intended 29px clipping beyond the card's trailing edge.
    LandingPromotionalArtworkSide.trailing => availableWidth - 644,
    LandingPromotionalArtworkSide.leading => -7,
  };

  /// Artwork alignment for responsive compositions.
  Alignment get responsiveArtworkAlignment => switch (artworkSide) {
    LandingPromotionalArtworkSide.trailing => Alignment.centerRight,
    LandingPromotionalArtworkSide.leading => Alignment.centerLeft,
  };
}
