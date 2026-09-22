import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_item.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_layout.dart';

/// Equal-height row of membership cards.
final class MembershipCardRow extends StatelessWidget {
  /// Creates a membership card row.
  const MembershipCardRow({required this.cards, super.key});

  /// Membership cards in this row.
  final List<MembershipCardContent> cards;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          if (index > 0) const SizedBox(width: membershipCardGap),
          Expanded(
            child: MembershipCardItem(
              index: index,
              card: cards[index],
              usesCoordinatedHeight: true,
            ),
          ),
        ],
      ],
    ),
  );
}
