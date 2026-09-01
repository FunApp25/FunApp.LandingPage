import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_grid.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_models.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_introduction.dart';

/// Membership introduction and pricing cards from Figma node `2243:2233`.
final class MembershipSection extends StatelessWidget {
  /// Creates the membership section.
  const MembershipSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: const Key('membershipBackground'),
    color: AppColors.beigeAccent,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = AppSizes.pageGutterFor(availableWidth);
        final verticalPadding = AppSizes.sectionVerticalPaddingFor(
          availableWidth,
        );
        final contentGap = switch (availableWidth) {
          >= 1200 => 80.0,
          >= 600 => 64.0,
          _ => 48.0,
        };

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: pageGutter,
            vertical: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Column(
                children: [
                  MembershipIntroduction(
                    headingSize: AppSizes.sectionHeadingSizeFor(
                      availableWidth,
                    ),
                  ),
                  SizedBox(height: contentGap),
                  MembershipCardGrid(cards: _membershipCards(context)),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  static List<MembershipCardContent> _membershipCards(
    BuildContext context,
  ) => [
    (
      semanticId: 'free',
      variant: MembershipCardVariant.free,
      tierName: context.l10n.landingMembershipFreeTier,
      price: context.l10n.landingMembershipFreePrice,
      billingPeriod: context.l10n.landingMembershipBillingPeriod,
      priceSemanticLabel: context.l10n.landingMembershipFreePriceSemantics,
      description: context.l10n.landingMembershipFreeDescription,
      benefits: [
        (
          label: context.l10n.landingMembershipFreeBenefitBeta,
          emphasized: false,
        ),
        (
          label: context.l10n.landingMembershipFreeBenefitCommunity,
          emphasized: false,
        ),
        (
          label: context.l10n.landingMembershipFreeBenefitFeedback,
          emphasized: false,
        ),
        (
          label: context.l10n.landingMembershipFreeBenefitProgress,
          emphasized: false,
        ),
      ],
      ctaLabel: context.l10n.landingMembershipFreeCta,
      footnote: context.l10n.landingMembershipCancelFootnote,
      badgeLabel: null,
    ),
    (
      semanticId: 'hereNow',
      variant: MembershipCardVariant.hereNow,
      tierName: context.l10n.landingMembershipHereNowTier,
      price: context.l10n.landingMembershipHereNowPrice,
      billingPeriod: context.l10n.landingMembershipBillingPeriod,
      priceSemanticLabel: context.l10n.landingMembershipHereNowPriceSemantics,
      description: context.l10n.landingMembershipHereNowDescription,
      benefits: [
        (
          label: context.l10n.landingMembershipHereNowBenefitFree,
          emphasized: true,
        ),
        (
          label: context.l10n.landingMembershipHereNowBenefitAccess,
          emphasized: false,
        ),
        (
          label: context.l10n.landingMembershipHereNowBenefitBadge,
          emphasized: false,
        ),
        (
          label: context.l10n.landingMembershipHereNowBenefitSupport,
          emphasized: false,
        ),
        (
          label: context.l10n.landingMembershipHereNowBenefitReleases,
          emphasized: false,
        ),
      ],
      ctaLabel: context.l10n.landingMembershipHereNowCta,
      footnote: context.l10n.landingMembershipCancelFootnote,
      badgeLabel: null,
    ),
    (
      semanticId: 'lifetime',
      variant: MembershipCardVariant.lifetime,
      tierName: context.l10n.landingMembershipLifetimeTier,
      price: context.l10n.landingMembershipLifetimePrice,
      billingPeriod: context.l10n.landingMembershipOneTimePeriod,
      priceSemanticLabel: context.l10n.landingMembershipLifetimePriceSemantics,
      description: context.l10n.landingMembershipLifetimeDescription,
      benefits: [
        (
          label: context.l10n.landingMembershipLifetimeBenefitPerks,
          emphasized: true,
        ),
        (
          label: context.l10n.landingMembershipLifetimeBenefitFees,
          emphasized: false,
        ),
        (
          label: context.l10n.landingMembershipLifetimeBenefitPrices,
          emphasized: false,
        ),
        (
          label: context.l10n.landingMembershipLifetimeBenefitTesting,
          emphasized: false,
        ),
        (
          label: context.l10n.landingMembershipLifetimeBenefitAvailability,
          emphasized: false,
        ),
      ],
      ctaLabel: context.l10n.landingMembershipLifetimeCta,
      footnote: context.l10n.landingMembershipLifetimeFootnote,
      badgeLabel: context.l10n.landingMembershipLifetimeBadge,
    ),
  ];
}
