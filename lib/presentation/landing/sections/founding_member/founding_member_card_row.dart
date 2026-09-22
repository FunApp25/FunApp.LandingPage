import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_card_item.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_layout.dart';

/// Equal-height row of Founding Member benefit cards.
final class FoundingMemberCardRow extends StatelessWidget {
  /// Creates a Founding Member benefit-card row.
  const FoundingMemberCardRow({required this.cards, super.key});

  /// Benefit cards in this row.
  final List<FoundingMemberCardContent> cards;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          if (index > 0) const SizedBox(width: foundingMemberCardGap),
          Expanded(
            child: FoundingMemberCardItem(
              card: cards[index],
              usesCoordinatedHeight: true,
            ),
          ),
        ],
      ],
    ),
  );
}
