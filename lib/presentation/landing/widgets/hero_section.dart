import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_cta_button.dart';

/// Landing-page hero from Figma wrapper node `2190:1569`.
final class HeroSection extends StatelessWidget {
  /// Creates the landing-page hero.
  const HeroSection({super.key});

  // The desktop composition needs room for the 600px copy block and the
  // visible portion of the 706px artwork. Below this content constraint, the
  // sections stack in source order because Figma has no narrow variant.
  static const _twoColumnCompositionWidth = 1100.0;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.lightForeground,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = AppSizes.pageGutterFor(availableWidth);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: pageGutter),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: LayoutBuilder(
                builder: (context, heroConstraints) {
                  final usesDesktopComposition =
                      heroConstraints.maxWidth >= _twoColumnCompositionWidth;

                  return ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppSizes.cardRadius),
                    ),
                    child: ColoredBox(
                      color: AppColors.beigeAccent,
                      child: usesDesktopComposition
                          ? const _DesktopHero()
                          : _StackedHero(
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
    child: const Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(80, 106, 0, 106),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 600,
              child: _HeroContent(headlineSize: 60),
            ),
          ),
        ),
        Positioned(
          top: -113,
          right: -99,
          width: 706,
          height: 717,
          child: _HeroImage(fit: BoxFit.fill),
        ),
      ],
    ),
  );
}

final class _StackedHero extends StatelessWidget {
  const _StackedHero({required this.availableWidth});

  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    final sectionPadding = availableWidth < 480 ? 24.0 : 48.0;
    final contentWidth = availableWidth - (sectionPadding * 2);
    final headlineSize = (contentWidth * 0.12).clamp(36.0, 52.0);

    return Padding(
      key: const Key('heroStackedLayout'),
      padding: EdgeInsets.symmetric(
        horizontal: sectionPadding,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroContent(headlineSize: headlineSize),
          const SizedBox(height: 48),
          const AspectRatio(
            aspectRatio: 706 / 717,
            child: _HeroImage(fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

final class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.headlineSize});

  final double headlineSize;

  @override
  Widget build(BuildContext context) {
    final headlineLeading = context.l10n.landingHeroHeadlineLeading;
    final headlineEmphasis = context.l10n.landingHeroHeadlineEmphasis;
    final headlineLabel = '$headlineLeading $headlineEmphasis';
    final headlineLetterSpacing = headlineSize * -0.03;
    final headlineStyle = AppTextStyles.landingHeroHeadline.copyWith(
      fontSize: headlineSize,
      letterSpacing: headlineLetterSpacing,
    );
    final emphasisStyle = AppTextStyles.landingHeroHeadlineEmphasis.copyWith(
      fontSize: headlineSize,
      letterSpacing: headlineLetterSpacing,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              AppAssets.heroEyebrowGlyph,
              key: const Key('heroEyebrowGlyph'),
              width: 18,
              height: 12,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.landingHeroEyebrow,
                style: AppTextStyles.landingHeroEyebrow,
              ),
            ),
          ],
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
          style: AppTextStyles.landingHeroSupporting,
        ),
        const SizedBox(height: 40),
        LandingCtaButton(
          key: const Key('landingHeroWaitlistCta'),
          label: context.l10n.landingHeroJoinWaitlist,
          size: LandingCtaSize.prominent,
        ),
      ],
    );
  }
}

final class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.fit});

  final BoxFit fit;

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
      fit: fit,
    ),
  );
}
