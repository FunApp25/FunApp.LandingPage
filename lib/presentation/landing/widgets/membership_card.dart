import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Visual variants in the current static membership pricing design.
enum MembershipCardVariant {
  /// White Free Membership card.
  free,

  /// Yellow Here & Now Membership card.
  hereNow,

  /// Dark Lifetime Membership card.
  lifetime,
}

/// One localized benefit in a presentation-only membership card.
typedef MembershipBenefit = ({String label, bool emphasized});

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

  _MembershipCardDesign get _design => switch (variant) {
    MembershipCardVariant.free => _MembershipCardDesign.free,
    MembershipCardVariant.hereNow => _MembershipCardDesign.hereNow,
    MembershipCardVariant.lifetime => _MembershipCardDesign.lifetime,
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
                    _MembershipCardDetails(
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
                    _MembershipCardAction(
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

enum _MembershipCardDesign {
  free(
    backgroundColor: AppColors.lightForeground,
    foregroundColor: AppColors.textPrimary,
    eyebrowColor: AppColors.warmOrange,
    eyebrowAsset: AppAssets.membershipFreeEyebrow,
    checkBackgroundColor: AppColors.energeticPlum,
    checkAsset: AppAssets.membershipCheckWhite,
    ctaBackgroundColor: AppColors.warmOrange,
    ctaForegroundColor: AppColors.lightForeground,
    ctaArrowAsset: AppAssets.arrowUpRight,
  ),
  hereNow(
    backgroundColor: AppColors.yellowAccent,
    foregroundColor: AppColors.textPrimary,
    eyebrowColor: AppColors.blueMain,
    eyebrowAsset: AppAssets.membershipHereNowEyebrow,
    checkBackgroundColor: AppColors.lightForeground,
    checkAsset: AppAssets.membershipCheckBlue,
    ctaBackgroundColor: AppColors.blueMain,
    ctaForegroundColor: AppColors.lightForeground,
    ctaArrowAsset: AppAssets.arrowUpRight,
  ),
  lifetime(
    backgroundColor: AppColors.warmCharcoalAccent,
    foregroundColor: AppColors.lightForeground,
    eyebrowColor: AppColors.yellowAccent,
    eyebrowAsset: AppAssets.membershipLifetimeEyebrow,
    checkBackgroundColor: AppColors.blueMain,
    checkAsset: AppAssets.membershipCheckWhite,
    ctaBackgroundColor: AppColors.yellowAccent,
    ctaForegroundColor: AppColors.textPrimary,
    ctaArrowAsset: AppAssets.membershipArrowCharcoal,
  );

  const _MembershipCardDesign({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.eyebrowColor,
    required this.eyebrowAsset,
    required this.checkBackgroundColor,
    required this.checkAsset,
    required this.ctaBackgroundColor,
    required this.ctaForegroundColor,
    required this.ctaArrowAsset,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color eyebrowColor;
  final String eyebrowAsset;
  final Color checkBackgroundColor;
  final String checkAsset;
  final Color ctaBackgroundColor;
  final Color ctaForegroundColor;
  final String ctaArrowAsset;
}

final class _MembershipCardDetails extends StatelessWidget {
  const _MembershipCardDetails({
    required this.semanticId,
    required this.design,
    required this.tierName,
    required this.price,
    required this.billingPeriod,
    required this.priceSemanticLabel,
    required this.description,
    required this.benefits,
  });

  final String semanticId;
  final _MembershipCardDesign design;
  final String tierName;
  final String price;
  final String billingPeriod;
  final String priceSemanticLabel;
  final String description;
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
            _MembershipBenefitRow(
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

final class _MembershipBenefitRow extends StatelessWidget {
  const _MembershipBenefitRow({
    required this.semanticId,
    required this.index,
    required this.design,
    required this.benefit,
  });

  final String semanticId;
  final int index;
  final _MembershipCardDesign design;
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

final class _MembershipCardAction extends StatelessWidget {
  const _MembershipCardAction({
    required this.semanticId,
    required this.design,
    required this.label,
    required this.footnote,
  });

  final String semanticId;
  final _MembershipCardDesign design;
  final String label;
  final String footnote;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DecoratedBox(
        key: Key('membershipCta-$semanticId'),
        decoration: BoxDecoration(
          color: design.ctaBackgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppSizes.pillRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  key: Key('membershipCtaLabel-$semanticId'),
                  textAlign: TextAlign.center,
                  style: LandingTextStyles.heroCta.copyWith(
                    color: design.ctaForegroundColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                design.ctaArrowAsset,
                key: Key('membershipCtaArrow-$semanticId'),
                width: 16,
                height: 16,
                excludeFromSemantics: true,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        footnote,
        key: Key('membershipFootnote-$semanticId'),
        textAlign: TextAlign.center,
        style: LandingTextStyles.membershipFootnote.copyWith(
          color: design.foregroundColor.withValues(alpha: 0.6),
        ),
      ),
    ],
  );
}
