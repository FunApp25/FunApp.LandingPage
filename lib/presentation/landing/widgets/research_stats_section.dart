import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/research_stat_card.dart';

/// UK research statistics from Figma node `2190:1587`.
final class ResearchStatsSection extends StatelessWidget {
  /// Creates the research-statistics section.
  const ResearchStatsSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
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
                  _ResearchHeading(
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
                  _ResearchCardGrid(
                    cards: [
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
                    ],
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

final class _ResearchHeading extends StatelessWidget {
  const _ResearchHeading({required this.headingSize});

  final double headingSize;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 628),
    child: Column(
      children: [
        Semantics(
          key: const Key('researchStatsHeadingSemantics'),
          label: context.l10n.landingStatsHeading,
          header: true,
          excludeSemantics: true,
          child: Text(
            context.l10n.landingStatsHeading,
            key: const Key('researchStatsHeadingText'),
            textAlign: TextAlign.center,
            style: LandingTextStyles.sectionHeading.copyWith(
              fontSize: headingSize,
              letterSpacing: headingSize * -0.01,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text.rich(
          key: const Key('researchStatsAttribution'),
          TextSpan(
            style: LandingTextStyles.statsAttribution,
            children: [
              TextSpan(text: '${context.l10n.landingStatsAttributionIntro} '),
              TextSpan(
                text: context.l10n.landingStatsBelongingForum,
                style: LandingTextStyles.statsAttributionSource,
              ),
              TextSpan(
                text: ' · ',
                style: LandingTextStyles.statsAttributionSeparator,
              ),
              TextSpan(
                text: context.l10n.landingStatsMarmaladeTrust,
                style: LandingTextStyles.statsAttributionSource,
              ),
              TextSpan(
                text: ' · ',
                style: LandingTextStyles.statsAttributionSeparator,
              ),
              TextSpan(
                text: context.l10n.landingStatsBacpYouGov,
                style: LandingTextStyles.statsAttributionSource,
              ),
              TextSpan(
                text: ' ${context.l10n.landingStatsAttributionThanks}',
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

final class _ResearchCardGrid extends StatelessWidget {
  const _ResearchCardGrid({required this.cards});

  static const _cardGap = 16.0;

  final List<({String value, String description})> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columnCount = switch (constraints.maxWidth) {
        >= 1100 => 4,
        >= 600 => 2,
        _ => 1,
      };
      final cardWidth =
          (constraints.maxWidth - (_cardGap * (columnCount - 1))) / columnCount;

      return Wrap(
        key: Key('researchStatsColumns$columnCount'),
        spacing: _cardGap,
        runSpacing: _cardGap,
        children: [
          for (final card in cards)
            SizedBox(
              width: cardWidth,
              child: ResearchStatCard(
                value: card.value,
                description: card.description,
                usesDesktopMinimumHeight: columnCount > 1,
              ),
            ),
        ],
      );
    },
  );
}
