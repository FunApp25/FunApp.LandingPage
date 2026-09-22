import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/hero/hero_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/hero/hero_image.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Constraint-driven landing hero composition below the wide breakpoint.
final class ResponsiveHero extends StatelessWidget {
  /// Creates the responsive landing hero composition.
  const ResponsiveHero({required this.availableWidth, super.key});

  /// Width available to the hero card.
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    final isNarrow = availableWidth < 600;
    final horizontalPadding = isNarrow ? 24.0 : 48.0;
    final headlineSize = switch (availableWidth) {
      >= 600 => 46.0,
      >= 340 => 38.0,
      _ => 34.0,
    };
    final artworkWidth = switch (availableWidth) {
      >= 1000 => 560.0,
      >= 800 => 520.0,
      >= 600 => 440.0,
      _ => (availableWidth * 1.08).clamp(0.0, 340.0),
    };
    final artworkHeight = artworkWidth * (717 / 706);
    final artworkTop = switch (availableWidth) {
      >= 1000 => -136.0,
      >= 800 => -112.0,
      >= 600 => -102.0,
      _ => -68.0,
    };
    // The source PNG includes transparent canvas after the visible artwork.
    // A small overscan beyond that transparent region lets the Hero card own
    // the visible trailing clip instead of leaving the composition inset.
    final artworkRight = artworkWidth * -0.17;
    // Keep the established copy position and Hero height independent of the
    // visual artwork offset. Moving the image upward then creates real beige
    // clearance instead of pulling the copy upward with it.
    final contentTop =
        artworkHeight -
        switch (availableWidth) {
          >= 1000 => 120.0,
          >= 800 => 104.0,
          >= 600 => 92.0,
          _ => 52.0,
        };
    final supportingStyle = isNarrow
        ? LandingTextStyles.heroSupporting.copyWith(
            fontSize: 18,
            height: 26 / 18,
          )
        : LandingTextStyles.heroSupporting;

    return Stack(
      key: const Key('heroResponsiveLayout'),
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            contentTop,
            horizontalPadding,
            isNarrow ? 32 : 40,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: HeroContent(
                headlineSize: headlineSize,
                supportingStyle: supportingStyle,
              ),
            ),
          ),
        ),
        Positioned(
          key: const Key('heroArtworkFrame'),
          top: artworkTop,
          right: artworkRight,
          width: artworkWidth,
          height: artworkHeight,
          child: const HeroImage(),
        ),
      ],
    );
  }
}
