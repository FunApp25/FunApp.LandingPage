import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_action.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_design.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_details.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_models.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// One static membership pricing card from Figma node `2243:2233`.
final class MembershipCard extends StatelessWidget {
  /// Creates a static membership pricing card.
  const MembershipCard({
    required this.semanticId,
    required this.variant,
    required this.tierName,
    required this.price,
    required this.billingPeriod,
    required this.priceSemanticLabel,
    required this.description,
    required this.benefits,
    required this.ctaLabel,
    required this.footnote,
    required this.usesCoordinatedHeight,
    this.badgeLabel,
    super.key,
  });

  /// Stable test identifier that is not shown to users.
  final String semanticId;

  /// Approved visual treatment for this tier.
  final MembershipCardVariant variant;

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

  /// Localized visual-only CTA label.
  final String ctaLabel;

  /// Localized note beneath the visual CTA.
  final String footnote;

  /// Localized optional badge above the Lifetime card.
  final String? badgeLabel;

  /// Whether the card participates in a coordinated multi-column row.
  final bool usesCoordinatedHeight;

  MembershipCardDesign get _design => switch (variant) {
    MembershipCardVariant.free => MembershipCardDesign.free,
    MembershipCardVariant.hereNow => MembershipCardDesign.hereNow,
    MembershipCardVariant.lifetime => MembershipCardDesign.lifetime,
  };

  @override
  Widget build(BuildContext context) {
    final design = _design;

    return Semantics(
      key: Key('membershipCardSemantics-$semanticId'),
      container: true,
      explicitChildNodes: true,
      child: Stack(
        key: Key('membershipCardStack-$semanticId'),
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          ConstrainedBox(
            key: Key('membershipCardBounds-$semanticId'),
            constraints: BoxConstraints(
              minHeight: usesCoordinatedHeight ? 640 : 0,
            ),
            child: DecoratedBox(
              key: Key('membershipCardSurface-$semanticId'),
              decoration: BoxDecoration(
                color: design.backgroundColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSizes.cardRadius),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 38,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MembershipCardDetails(
                      semanticId: semanticId,
                      design: design,
                      tierName: tierName,
                      price: price,
                      billingPeriod: billingPeriod,
                      priceSemanticLabel: priceSemanticLabel,
                      description: description,
                      benefits: benefits,
                    ),
                    if (!usesCoordinatedHeight) const SizedBox(height: 40),
                    MembershipCardAction(
                      semanticId: semanticId,
                      design: design,
                      label: ctaLabel,
                      footnote: footnote,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (badgeLabel case final label?)
            Positioned(
              key: Key('membershipBadge-$semanticId'),
              top: -14,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.yellowAccent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppSizes.pillRadius),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Text(
                    label,
                    style: LandingTextStyles.membershipCardEyebrow,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
