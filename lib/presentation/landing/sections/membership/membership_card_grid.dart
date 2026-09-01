import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_item.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_row.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_layout.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_reveal_progress.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_scroll_reveal.dart';

/// Responsive membership card grid and coordinated reveal.
final class MembershipCardGrid extends StatelessWidget {
  /// Creates the membership card grid.
  const MembershipCardGrid({required this.cards, super.key});

  static const _cardDurationMilliseconds = 420;
  static const _wideStaggerMilliseconds = 45;
  static const _narrowStaggerMilliseconds = 20;

  /// Membership cards in display order.
  final List<MembershipCardContent> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const threeColumnWidth =
          (membershipMinimumCardWidth * 3) + (membershipCardGap * 2);
      const twoColumnWidth =
          (membershipMinimumCardWidth * 2) + membershipCardGap;
      final int columns;
      if (constraints.maxWidth >= threeColumnWidth) {
        columns = 3;
      } else if (constraints.maxWidth >= twoColumnWidth) {
        columns = 2;
      } else {
        columns = 1;
      }
      final isNarrow = columns == 1;
      final staggerMilliseconds = isNarrow
          ? _narrowStaggerMilliseconds
          : _wideStaggerMilliseconds;
      final sequenceDurationMilliseconds =
          _cardDurationMilliseconds +
          (staggerMilliseconds * (cards.length - 1));

      return LandingScrollReveal(
        key: const Key('membershipCardsReveal'),
        duration: Duration(milliseconds: sequenceDurationMilliseconds),
        transitionBuilder: (context, progress, child) =>
            MembershipRevealProgress(
              progress: progress,
              cardDurationMilliseconds: _cardDurationMilliseconds,
              staggerMilliseconds: staggerMilliseconds,
              sequenceDurationMilliseconds: sequenceDurationMilliseconds,
              initialDistance: isNarrow ? 10 : 16,
              child: child,
            ),
        child: Column(
          key: Key('membershipCardsColumns$columns'),
          children: switch (columns) {
            3 => [
              MembershipCardRow(cards: cards),
            ],
            2 => [
              MembershipCardRow(cards: cards.take(2).toList()),
              const SizedBox(height: membershipCardGap),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: membershipCardGap / 4,
                  ),
                  child: MembershipCardItem(
                    index: 2,
                    card: cards[2],
                    usesCoordinatedHeight: false,
                  ),
                ),
              ),
            ],
            _ => [
              for (var index = 0; index < cards.length; index++) ...[
                if (index > 0) const SizedBox(height: membershipCardGap),
                MembershipCardItem(
                  index: index,
                  card: cards[index],
                  usesCoordinatedHeight: false,
                ),
              ],
            ],
          },
        ),
      );
    },
  );
}
