import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';

/// One presentation-only membership tier from Figma node `2190:1610`.
final class MembershipCard extends StatelessWidget {
  /// Creates a static membership card.
  const MembershipCard({
    required this.semanticId,
    required this.tierName,
    required this.price,
    required this.billingPeriod,
    required this.priceSemanticLabel,
    required this.description,
    required this.offerHint,
    required this.offerLabel,
    super.key,
  });

  /// Stable test identifier that is not shown to users.
  final String semanticId;

  /// Localized membership tier name.
  final String tierName;

  /// Localized visual price.
  final String price;

  /// Localized visual billing period.
  final String billingPeriod;

  /// Localized coherent spoken price and billing period.
  final String priceSemanticLabel;

  /// Localized membership description.
  final String description;

  /// Localized note directing visual attention to the offer below.
  final String offerHint;

  /// Localized, intentionally unwired visual link label.
  final String offerLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    key: Key('membershipCardSemantics-$semanticId'),
    container: true,
    explicitChildNodes: true,
    child: ConstrainedBox(
      // The English desktop component is 464px tall. Localized and narrow
      // cards may grow naturally instead of clipping to the Figma frame.
      constraints: const BoxConstraints(minHeight: 464),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.warmCharcoalAccent,
          borderRadius: BorderRadius.all(
            Radius.circular(AppSizes.cardRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                key: Key('membershipTierSemantics-$semanticId'),
                label: tierName,
                header: true,
                excludeSemantics: true,
                child: Text(
                  tierName,
                  key: Key('membershipTierName-$semanticId'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.landingMembershipCardTitle,
                ),
              ),
              const SizedBox(height: 24),
              _MembershipCardContent(
                semanticId: semanticId,
                price: price,
                billingPeriod: billingPeriod,
                priceSemanticLabel: priceSemanticLabel,
                description: description,
                offerHint: offerHint,
              ),
              const SizedBox(height: 24),
              _MembershipOfferLink(
                semanticId: semanticId,
                label: offerLabel,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

final class _MembershipCardContent extends StatelessWidget {
  const _MembershipCardContent({
    required this.semanticId,
    required this.price,
    required this.billingPeriod,
    required this.priceSemanticLabel,
    required this.description,
    required this.offerHint,
  });

  final String semanticId;
  final String price;
  final String billingPeriod;
  final String priceSemanticLabel;
  final String description;
  final String offerHint;

  @override
  Widget build(BuildContext context) => Column(
    children: [
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
                style: AppTextStyles.landingMembershipPrice,
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  billingPeriod,
                  key: Key('membershipBillingPeriod-$semanticId'),
                  style: AppTextStyles.landingMembershipPriceUnit,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 34),
      DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.blueMain,
          borderRadius: BorderRadius.all(
            Radius.circular(AppSizes.pillRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(
            AppAssets.membershipCheck,
            key: Key('membershipCheck-$semanticId'),
            width: 16,
            height: 16,
            excludeFromSemantics: true,
          ),
        ),
      ),
      const SizedBox(height: 14),
      Text(
        description,
        key: Key('membershipDescription-$semanticId'),
        textAlign: TextAlign.center,
        style: AppTextStyles.landingMembershipCardBody,
      ),
      const SizedBox(height: 34),
      Text(
        offerHint,
        key: Key('membershipOfferHint-$semanticId'),
        textAlign: TextAlign.center,
        style: AppTextStyles.landingMembershipCardBody,
      ),
    ],
  );
}

/// Visual link treatment without gesture, link, or button semantics.
final class _MembershipOfferLink extends StatelessWidget {
  const _MembershipOfferLink({
    required this.semanticId,
    required this.label,
  });

  final String semanticId;
  final String label;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 8,
    runSpacing: 4,
    children: [
      Text(
        label,
        key: Key('membershipOfferLabel-$semanticId'),
        textAlign: TextAlign.center,
        style: AppTextStyles.landingMembershipCardLink,
      ),
      SvgPicture.asset(
        AppAssets.membershipArrowUpRight,
        key: Key('membershipOfferArrow-$semanticId'),
        width: 20,
        height: 20,
        excludeFromSemantics: true,
      ),
    ],
  );
}
