import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/hero/hero_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/hero/hero_image.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Dedicated landing Hero composition below the mobile UX breakpoint.
final class MobileHero extends StatelessWidget {
  /// Creates the mobile Hero composition.
  const MobileHero({required this.availableWidth, super.key});

  /// Width available inside the clipped Hero card.
  final double availableWidth;

  static const _figmaCardWidth = 358.0;
  static const _figmaArtworkWidth = 432.0;
  static const _figmaArtworkHeight = 439.0;
  static const _figmaArtworkTop = -115.0;
  // Figma node 2269:1504 uses a CROP image fill whose horizontal scale is
  // 1.1586254835. The exported local PNG retains the transparent source-canvas
  // inset on its right edge, so applying the same uniform crop scale keeps
  // faces undistorted while letting the card own the visible clipping.
  static const _figmaImageCropScale = 1.1586254835128784;
  static const _artworkToContentClearance = 48.0;
  static const _contentBottomInset = 48.0;

  @override
  Widget build(BuildContext context) {
    final geometryScale = availableWidth / _figmaCardWidth;
    final artworkWidth = _figmaArtworkWidth * geometryScale;
    final artworkHeight = _figmaArtworkHeight * geometryScale;
    final artworkTop = _figmaArtworkTop * geometryScale;
    final paintedArtworkWidth = artworkWidth * _figmaImageCropScale;
    final paintedArtworkHeight = artworkHeight * _figmaImageCropScale;
    final contentTop = artworkTop + artworkHeight + _artworkToContentClearance;

    return Stack(
      key: const Key('heroMobileLayout'),
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            contentTop,
            16,
            _contentBottomInset,
          ),
          child: HeroContent(
            headlineSize: 36,
            headlineLineHeight: 46,
            headlineToSupportingSpacing: 14,
            textAlign: TextAlign.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            supportingStyle: LandingTextStyles.heroSupporting.copyWith(
              fontSize: 16,
              height: 24 / 16,
              letterSpacing: 0.32,
            ),
          ),
        ),
        Positioned(
          key: const Key('heroArtworkFrame'),
          top: artworkTop,
          left: (availableWidth - artworkWidth) / 2,
          width: artworkWidth,
          height: artworkHeight,
          child: OverflowBox(
            alignment: Alignment.bottomCenter,
            minWidth: paintedArtworkWidth,
            maxWidth: paintedArtworkWidth,
            minHeight: paintedArtworkHeight,
            maxHeight: paintedArtworkHeight,
            child: const SizedBox.expand(
              key: Key('heroArtworkPaintBounds'),
              child: HeroImage(assetPath: AppAssets.heroPeopleMobile),
            ),
          ),
        ),
      ],
    );
  }
}
