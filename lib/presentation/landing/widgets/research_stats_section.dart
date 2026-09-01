import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_scroll_reveal.dart';
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
  static const _cardDurationMilliseconds = 340;
  static const _wideStaggerMilliseconds = 45;
  static const _narrowStaggerMilliseconds = 20;

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
      final isNarrow = columnCount == 1;
      final staggerMilliseconds = isNarrow
          ? _narrowStaggerMilliseconds
          : _wideStaggerMilliseconds;
      final sequenceDurationMilliseconds =
          _cardDurationMilliseconds +
          (staggerMilliseconds * (cards.length - 1));

      return LandingScrollReveal(
        key: const Key('researchStatsReveal'),
        duration: Duration(milliseconds: sequenceDurationMilliseconds),
        transitionBuilder: (context, progress, child) =>
            _ResearchRevealProgress(
              progress: progress,
              child: child,
            ),
        child: Wrap(
          key: Key('researchStatsColumns$columnCount'),
          spacing: _cardGap,
          runSpacing: _cardGap,
          children: [
            for (var index = 0; index < cards.length; index++)
              _ResearchStatReveal(
                index: index,
                cardDurationMilliseconds: _cardDurationMilliseconds,
                staggerMilliseconds: staggerMilliseconds,
                sequenceDurationMilliseconds: sequenceDurationMilliseconds,
                initialDistance: isNarrow ? 8 : 12,
                child: SizedBox(
                  width: cardWidth,
                  child: ResearchStatCard(
                    value: cards[index].value,
                    description: cards[index].description,
                    usesDesktopMinimumHeight: columnCount > 1,
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

final class _ResearchRevealProgress extends InheritedWidget {
  const _ResearchRevealProgress({
    required this.progress,
    required super.child,
  });

  final double progress;

  static double of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ResearchRevealProgress>()!
      .progress;

  @override
  bool updateShouldNotify(_ResearchRevealProgress oldWidget) =>
      progress != oldWidget.progress;
}

final class _ResearchStatReveal extends StatelessWidget {
  const _ResearchStatReveal({
    required this.index,
    required this.cardDurationMilliseconds,
    required this.staggerMilliseconds,
    required this.sequenceDurationMilliseconds,
    required this.initialDistance,
    required this.child,
  });

  final int index;
  final int cardDurationMilliseconds;
  final int staggerMilliseconds;
  final int sequenceDurationMilliseconds;
  final double initialDistance;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final groupProgress = _ResearchRevealProgress.of(context);
    final elapsedMilliseconds = groupProgress * sequenceDurationMilliseconds;
    final delayMilliseconds = staggerMilliseconds * index;
    final cardProgress = LandingMotion.standardCurve.transform(
      ((elapsedMilliseconds - delayMilliseconds) / cardDurationMilliseconds)
          .clamp(0, 1),
    );

    return Transform.translate(
      key: Key('researchStatRevealTransform$index'),
      offset: Offset(0, initialDistance * (1 - cardProgress)),
      child: Opacity(
        key: Key('researchStatRevealOpacity$index'),
        opacity: 0.1 + (0.9 * cardProgress),
        alwaysIncludeSemantics: true,
        child: child,
      ),
    );
  }
}
