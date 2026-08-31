import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_cta_button.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_promotional_card.dart';

/// Venue introduction and promotional card from Figma node `2190:1627`.
final class VenueSection extends StatelessWidget {
  /// Creates the venue section.
  const VenueSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.lightForeground,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = AppSizes.pageGutterFor(availableWidth);
        final bottomPadding = AppSizes.sectionVerticalPaddingFor(
          availableWidth,
        );

        return Padding(
          padding: EdgeInsets.only(
            left: pageGutter,
            right: pageGutter,
            bottom: bottomPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Column(
                children: [
                  _VenueIntroduction(
                    headingSize: AppSizes.sectionHeadingSizeFor(
                      availableWidth,
                    ),
                  ),
                  SizedBox(
                    height: switch (availableWidth) {
                      >= 1200 => 80,
                      >= 600 => 64,
                      _ => 40,
                    },
                  ),
                  LandingPromotionalCard(
                    semanticId: 'venueCard',
                    heading: context.l10n.landingVenueCardHeading,
                    bodyParagraphs: [
                      context.l10n.landingVenueCardSupporting,
                    ],
                    ctaLabel: context.l10n.landingVenueCta,
                    ctaAppearance: LandingCtaAppearance.brandYellow,
                    backgroundColor: AppColors.warmCharcoalAccent,
                    foregroundColor: AppColors.lightForeground,
                    imageAsset: AppAssets.venueGroup,
                    imageSemanticLabel:
                        context.l10n.landingVenueImageDescription,
                    imageSide: PromotionalImageSide.leading,
                    desktopHeight: 444,
                    desktopContentWidth: 426,
                    desktopLeadingInset: 0,
                    desktopGap: 128,
                    desktopImageSlotWidth: 666,
                    desktopTrailingInset: 140,
                    desktopImageAlignment: Alignment.centerRight,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

final class _VenueIntroduction extends StatelessWidget {
  const _VenueIntroduction({required this.headingSize});

  final double headingSize;

  @override
  Widget build(BuildContext context) {
    final headingLeading = context.l10n.landingVenueHeadingLeading;
    final headingEmphasis = context.l10n.landingVenueHeadingEmphasis;
    final headingTrailing = context.l10n.landingVenueHeadingTrailing;
    final semanticLabel = '$headingLeading$headingEmphasis$headingTrailing';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 628),
      child: Column(
        children: [
          Semantics(
            key: const Key('venueIntroductionHeadingSemantics'),
            label: semanticLabel,
            header: true,
            excludeSemantics: true,
            child: Text.rich(
              key: const Key('venueIntroductionHeadingText'),
              TextSpan(
                text: headingLeading,
                style: AppTextStyles.landingSectionHeading.copyWith(
                  fontSize: headingSize,
                  letterSpacing: headingSize * -0.01,
                ),
                children: [
                  TextSpan(
                    text: headingEmphasis,
                    style: AppTextStyles.landingSectionHeadingEmphasis.copyWith(
                      fontSize: headingSize,
                      letterSpacing: headingSize * -0.01,
                    ),
                  ),
                  TextSpan(text: headingTrailing),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.landingVenueIntroductionFirst,
            key: const Key('venueIntroductionBody0'),
            textAlign: TextAlign.center,
            style: AppTextStyles.landingStatsAttribution,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.landingVenueIntroductionSecond,
            key: const Key('venueIntroductionBody1'),
            textAlign: TextAlign.center,
            style: AppTextStyles.landingStatsAttribution,
          ),
        ],
      ),
    );
  }
}
