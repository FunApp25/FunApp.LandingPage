import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_benefit_card.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_card_content.dart';

/// Places one Founding Member benefit card in its responsive grid.
final class FoundingMemberCardItem extends StatelessWidget {
  /// Creates a Founding Member card item.
  const FoundingMemberCardItem({
    required this.card,
    required this.usesCoordinatedHeight,
    super.key,
  });

  /// Localized benefit-card presentation data.
  final FoundingMemberCardContent card;

  /// Whether the card participates in an equal-height row.
  final bool usesCoordinatedHeight;

  @override
  Widget build(BuildContext context) => FoundingMemberBenefitCard(
    semanticId: card.semanticId,
    iconAsset: card.iconAsset,
    title: card.title,
    body: card.body,
    usesCoordinatedHeight: usesCoordinatedHeight,
  );
}
