import 'dart:ui';

import 'package:flutter/material.dart';
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
  static const _largestMobileCardWidth = 567.0;
  static const _figmaArtworkWidth = 432.0;
  static const _figmaArtworkHeight = 439.0;
  static const _figmaArtworkTop = -115.0;
  static const _figmaArtworkOverscan = 37.0;
  static const _largestViewportOverscan = 16.0;
  static const _artworkToContentClearance = 48.0;
  static const _contentBottomInset = 48.0;

  @override
  Widget build(BuildContext context) {
    final widerViewportProgress =
        ((availableWidth - _figmaCardWidth) /
                (_largestMobileCardWidth - _figmaCardWidth))
            .clamp(0.0, 1.0);
    final artworkOverscan = lerpDouble(
      _figmaArtworkOverscan,
      _largestViewportOverscan,
      widerViewportProgress,
    )!;
    final artworkWidth = availableWidth + (artworkOverscan * 2);
    final artworkHeight =
        artworkWidth * (_figmaArtworkHeight / _figmaArtworkWidth);
    final artworkTop = _figmaArtworkTop * (artworkWidth / _figmaArtworkWidth);
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
          child: const HeroImage(),
        ),
      ],
    );
  }
}
