import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/section_eyebrow.dart';

/// Landing-page hero from Figma wrapper node `2190:1569`.
final class HeroSection extends StatelessWidget {
  /// Creates the landing-page hero.
  const HeroSection({super.key});

  // The exact Figma composition needs enough width for its intentionally
  // overlapping copy and clipped artwork regions. Below this constraint the
  // artwork stays top-right while copy clears it vertically.
  static const _wideCompositionWidth = 1280.0;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.lightForeground,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = AppSizes.pageGutterFor(availableWidth);
        final topSpacing = switch (availableWidth) {
          >= 1200 => 24.0,
          >= 600 => 20.0,
          _ => 16.0,
        };

        return Padding(
          padding: EdgeInsets.only(
            left: pageGutter,
            top: topSpacing,
            right: pageGutter,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: LayoutBuilder(
                builder: (context, heroConstraints) {
                  final usesDesktopComposition =
                      heroConstraints.maxWidth >= _wideCompositionWidth;

                  return ClipRRect(
                    key: const Key('heroCard'),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppSizes.cardRadius),
                    ),
                    child: ColoredBox(
                      color: AppColors.beigeAccent,
                      child: usesDesktopComposition
                          ? const _DesktopHero()
                          : _ResponsiveHero(
                              availableWidth: heroConstraints.maxWidth,
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    ),
  );
}

final class _DesktopHero extends StatelessWidget {
  const _DesktopHero();

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    key: const Key('heroDesktopLayout'),
    constraints: const BoxConstraints(minHeight: 644),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(80, 106, 0, 106),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 600,
              child: _HeroContent(
                headlineSize: 60,
                supportingStyle: LandingTextStyles.heroSupporting,
              ),
            ),
          ),
        ),
        const Positioned(
          top: -113,
          right: -99,
          width: 706,
          height: 717,
          child: _HeroImage(),
        ),
      ],
    ),
  );
}

final class _ResponsiveHero extends StatelessWidget {
  const _ResponsiveHero({required this.availableWidth});

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
              child: _HeroContent(
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
          child: const _HeroImage(),
        ),
      ],
    );
  }
}

final class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.headlineSize,
    required this.supportingStyle,
  });

  final double headlineSize;
  final TextStyle supportingStyle;

  @override
  Widget build(BuildContext context) {
    final headlineLeading = context.l10n.landingHeroHeadlineLeading;
    final headlineEmphasis = context.l10n.landingHeroHeadlineEmphasis;
    final headlineLabel = '$headlineLeading $headlineEmphasis';
    final headlineLetterSpacing = headlineSize * -0.03;
    final headlineStyle = LandingTextStyles.heroHeadline.copyWith(
      fontSize: headlineSize,
      letterSpacing: headlineLetterSpacing,
    );
    final emphasisStyle = LandingTextStyles.heroHeadlineEmphasis.copyWith(
      fontSize: headlineSize,
      letterSpacing: headlineLetterSpacing,
    );

    return Column(
      key: const Key('heroContentBounds'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionEyebrow(
          label: context.l10n.landingHeroEyebrow,
          glyphAsset: AppAssets.heroEyebrowGlyph,
          foregroundColor: AppColors.blueMain,
          glyphSize: const Size(18, 12),
          glyphKey: const Key('heroEyebrowGlyph'),
        ),
        const SizedBox(height: 14),
        Semantics(
          key: const Key('heroHeadlineSemantics'),
          label: headlineLabel,
          header: true,
          excludeSemantics: true,
          child: Text.rich(
            key: const Key('heroHeadlineText'),
            TextSpan(
              text: '$headlineLeading ',
              style: headlineStyle,
              children: [
                TextSpan(
                  text: headlineEmphasis,
                  style: emphasisStyle,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.landingHeroSupporting,
          style: supportingStyle,
        ),
      ],
    );
  }
}

final class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) => Semantics(
    key: const Key('heroImageSemantics'),
    label: context.l10n.landingHeroImageDescription,
    image: true,
    excludeSemantics: true,
    child: Image.asset(
      AppAssets.heroPeople,
      key: const Key('heroPeopleImage'),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
    ),
  );
}
