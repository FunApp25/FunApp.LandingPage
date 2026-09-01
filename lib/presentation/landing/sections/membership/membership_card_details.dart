import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_benefit_row.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_design.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_models.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Tier, price, description, and benefits within a membership card.
final class MembershipCardDetails extends StatelessWidget {
  /// Creates the membership card details.
  const MembershipCardDetails({
    required this.semanticId,
    required this.design,
    required this.tierName,
    required this.price,
    required this.billingPeriod,
    required this.priceSemanticLabel,
    required this.description,
    required this.benefits,
    super.key,
  });

  /// Stable test identifier that is not shown to users.
  final String semanticId;

  /// Visual tokens for this membership tier.
  final MembershipCardDesign design;

  /// Localized membership tier eyebrow.
  final String tierName;

  /// Localized visual price.
  final String price;

  /// Localized visual billing period.
  final String billingPeriod;

  /// Localized coherent spoken price and billing period.
  final String priceSemanticLabel;

  /// Localized membership description.
  final String description;

  /// Localized tier benefits in display order.
  final List<MembershipBenefit> benefits;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        key: Key('membershipTierSemantics-$semanticId'),
        label: tierName,
        header: true,
        excludeSemantics: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              design.eyebrowAsset,
              key: Key('membershipEyebrow-$semanticId'),
              width: 12,
              height: 12,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                tierName,
                key: Key('membershipTierName-$semanticId'),
                textAlign: TextAlign.center,
                style: LandingTextStyles.membershipCardEyebrow.copyWith(
                  color: design.eyebrowColor,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Semantics(
        key: Key('membershipPriceSemantics-$semanticId'),
        label: priceSemanticLabel,
        excludeSemantics: true,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                key: Key('membershipPrice-$semanticId'),
                style: LandingTextStyles.membershipPrice.copyWith(
                  color: design.foregroundColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                billingPeriod,
                key: Key('membershipBillingPeriod-$semanticId'),
                style: LandingTextStyles.membershipPriceUnit.copyWith(
                  color: design.foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      Text(
        description,
        key: Key('membershipDescription-$semanticId'),
        textAlign: TextAlign.center,
        style: LandingTextStyles.membershipCardBody.copyWith(
          color: design.foregroundColor,
        ),
      ),
      const SizedBox(height: 40),
      Column(
        key: Key('membershipBenefits-$semanticId'),
        children: [
          for (var index = 0; index < benefits.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            MembershipBenefitRow(
              semanticId: semanticId,
              index: index,
              design: design,
              benefit: benefits[index],
            ),
          ],
        ],
      ),
    ],
  );
}
