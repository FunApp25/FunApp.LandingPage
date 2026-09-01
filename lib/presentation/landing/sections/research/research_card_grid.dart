import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_reveal_progress.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_stat_card.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_stat_reveal.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_scroll_reveal.dart';

/// Constraint-driven grid and group reveal for research statistic cards.
final class ResearchCardGrid extends StatelessWidget {
  /// Creates the research card grid.
  const ResearchCardGrid({required this.cards, super.key});

  static const _cardGap = 16.0;
  static const _cardDurationMilliseconds = 520;
  static const _wideStaggerMilliseconds = 50;
  static const _narrowStaggerMilliseconds = 20;
  static const _triggerViewportFraction = 0.7;

  /// Localized statistic card data in display order.
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
        triggerViewportFraction: _triggerViewportFraction,
        transitionBuilder: (context, progress, child) => ResearchRevealProgress(
          progress: progress,
          child: child,
        ),
        child: Wrap(
          key: Key('researchStatsColumns$columnCount'),
          spacing: _cardGap,
          runSpacing: _cardGap,
          children: [
            for (var index = 0; index < cards.length; index++)
              ResearchStatReveal(
                index: index,
                cardDurationMilliseconds: _cardDurationMilliseconds,
                staggerMilliseconds: staggerMilliseconds,
                sequenceDurationMilliseconds: sequenceDurationMilliseconds,
                initialDistance: isNarrow ? 10 : 16,
                initialOpacity: isNarrow ? 0.1 : 0.08,
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
