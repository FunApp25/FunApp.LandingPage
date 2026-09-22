import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_card_grid.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_heading.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_mobile_carousel.dart';

/// UK research statistics from desktop and mobile Figma compositions.
final class ResearchStatsSection extends StatelessWidget {
  /// Creates the research-statistics section.
  const ResearchStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        value: context.l10n.landingStatsFirstValue,
        description: context.l10n.landingStatsFirstDescription,
      ),
      (
        value: context.l10n.landingStatsSecondValue,
        description: context.l10n.landingStatsSecondDescription,
      ),
      (
        value: context.l10n.landingStatsThirdValue,
        description: context.l10n.landingStatsThirdDescription,
      ),
      (
        value: context.l10n.landingStatsFourthValue,
        description: context.l10n.landingStatsFourthDescription,
      ),
    ];
    final usesMobileCarousel = MediaQuery.sizeOf(context).width < 600;

    if (usesMobileCarousel) {
      return ColoredBox(
        color: AppColors.beigeAccent,
        child: Padding(
          key: const Key('researchStatsMobileLayout'),
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ResearchHeading(
                  headingSize: 32,
                  usesMobileFigmaTypography: true,
                ),
              ),
              const SizedBox(
                key: Key('researchStatsMobileIntroGap'),
                height: 40,
              ),
              ResearchMobileCarousel(cards: cards),
            ],
          ),
        ),
      );
    } else {
      return ColoredBox(
        color: AppColors.beigeAccent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : AppSizes.desktopPageWidth;
            final pageGutter = AppSizes.pageGutterFor(availableWidth);
            final verticalPadding = AppSizes.sectionVerticalPaddingFor(
              availableWidth,
            );

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pageGutter,
                vertical: verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.maxContentWidth,
                  ),
                  child: Column(
                    children: [
                      ResearchHeading(
                        headingSize: AppSizes.sectionHeadingSizeFor(
                          availableWidth,
                        ),
                      ),
                      SizedBox(
                        height: switch (availableWidth) {
                          >= 1200 => 80,
                          _ => 64,
                        },
                      ),
                      ResearchCardGrid(cards: cards),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
