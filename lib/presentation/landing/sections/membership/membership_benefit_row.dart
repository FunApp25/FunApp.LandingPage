import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_design.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_models.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// One benefit row in a static membership card.
final class MembershipBenefitRow extends StatelessWidget {
  /// Creates a membership benefit row.
  const MembershipBenefitRow({
    required this.semanticId,
    required this.index,
    required this.design,
    required this.benefit,
    super.key,
  });

  /// Stable membership card identifier.
  final String semanticId;

  /// Benefit position within the card.
  final int index;

  /// Visual tokens for this membership tier.
  final MembershipCardDesign design;

  /// Localized benefit presentation data.
  final MembershipBenefit benefit;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: design.checkBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: SvgPicture.asset(
            design.checkAsset,
            key: Key('membershipCheck-$semanticId-$index'),
            width: 12,
            height: 12,
            excludeFromSemantics: true,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          benefit.label,
          key: Key('membershipBenefit-$semanticId-$index'),
          style:
              (benefit.emphasized
                      ? LandingTextStyles.membershipCardBenefitEmphasis
                      : LandingTextStyles.membershipCardBody)
                  .copyWith(color: design.foregroundColor),
        ),
      ),
    ],
  );
}
