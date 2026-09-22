import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_card_item.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_card_row.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_layout.dart';

/// Responsive grid of Founding Member benefit cards.
final class FoundingMemberCardGrid extends StatelessWidget {
  /// Creates the Founding Member benefit-card grid.
  const FoundingMemberCardGrid({required this.cards, super.key});

  /// Benefit cards in display order.
  final List<FoundingMemberCardContent> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const threeColumnWidth =
          (foundingMemberMinimumCardWidth * 3) + (foundingMemberCardGap * 2);
      const twoColumnWidth =
          (foundingMemberMinimumCardWidth * 2) + foundingMemberCardGap;
      final int columns;
      if (constraints.maxWidth >= threeColumnWidth) {
        columns = 3;
      } else if (constraints.maxWidth >= twoColumnWidth) {
        columns = 2;
      } else {
        columns = 1;
      }

      return Column(
        key: Key('foundingMemberCardsColumns$columns'),
        children: switch (columns) {
          3 => [
            FoundingMemberCardRow(cards: cards),
          ],
          2 => [
            FoundingMemberCardRow(cards: cards.take(2).toList()),
            const SizedBox(height: foundingMemberCardGap),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: foundingMemberCardGap / 4,
                ),
                child: FoundingMemberCardItem(
                  card: cards[2],
                  usesCoordinatedHeight: false,
                ),
              ),
            ),
          ],
          _ => [
            for (var index = 0; index < cards.length; index++) ...[
              if (index > 0) const SizedBox(height: foundingMemberCardGap),
              FoundingMemberCardItem(
                card: cards[index],
                usesCoordinatedHeight: false,
              ),
            ],
          ],
        },
      );
    },
  );
}
