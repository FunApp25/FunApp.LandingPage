import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/membership_card.dart';

/// Membership introduction and pricing cards from Figma node `2243:2233`.
final class MembershipSection extends StatelessWidget {
  /// Creates the membership section.
  const MembershipSection({super.key});

  static const _cardGap = 16.0;
  static const _minimumCardWidth = 328.0;

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
                  _MembershipIntroduction(
                    headingSize: AppSizes.sectionHeadingSizeFor(
                      availableWidth,
                    ),
                  ),
                  SizedBox(height: contentGap),
                  _MembershipCardGrid(cards: _membershipCards(context)),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  static List<_MembershipCardContent> _membershipCards(
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

typedef _MembershipCardContent = ({
  String semanticId,
  MembershipCardVariant variant,
  String tierName,
  String price,
  String billingPeriod,
  String priceSemanticLabel,
  String description,
  List<MembershipBenefit> benefits,
  String ctaLabel,
  String footnote,
  String? badgeLabel,
});

final class _MembershipIntroduction extends StatelessWidget {
  const _MembershipIntroduction({required this.headingSize});

  final double headingSize;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 474),
    child: Column(
      children: [
        Semantics(
          key: const Key('membershipHeadingSemantics'),
          label: context.l10n.landingMembershipHeading,
          header: true,
          excludeSemantics: true,
          child: Text(
            context.l10n.landingMembershipHeading,
            key: const Key('membershipHeadingText'),
            textAlign: TextAlign.center,
            style: LandingTextStyles.sectionHeading.copyWith(
              fontSize: headingSize,
              letterSpacing: headingSize * -0.01,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.landingMembershipBody,
          key: const Key('membershipBodyText'),
          textAlign: TextAlign.center,
          style: LandingTextStyles.statsAttribution,
        ),
      ],
    ),
  );
}

final class _MembershipCardGrid extends StatelessWidget {
  const _MembershipCardGrid({required this.cards});

  final List<_MembershipCardContent> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const threeColumnWidth =
          (MembershipSection._minimumCardWidth * 3) +
          (MembershipSection._cardGap * 2);
      const twoColumnWidth =
          (MembershipSection._minimumCardWidth * 2) +
          MembershipSection._cardGap;
      final int columns;
      if (constraints.maxWidth >= threeColumnWidth) {
        columns = 3;
      } else if (constraints.maxWidth >= twoColumnWidth) {
        columns = 2;
      } else {
        columns = 1;
      }

      return Column(
        key: Key('membershipCardsColumns$columns'),
        children: switch (columns) {
          3 => [
            _MembershipCardRow(cards: cards),
          ],
          2 => [
            _MembershipCardRow(cards: cards.take(2).toList()),
            const SizedBox(height: MembershipSection._cardGap),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: MembershipSection._cardGap / 4,
                ),
                child: _MembershipCardItem(
                  card: cards[2],
                  usesCoordinatedHeight: false,
                ),
              ),
            ),
          ],
          _ => [
            for (var index = 0; index < cards.length; index++) ...[
              if (index > 0) const SizedBox(height: MembershipSection._cardGap),
              _MembershipCardItem(
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

final class _MembershipCardRow extends StatelessWidget {
  const _MembershipCardRow({required this.cards});

  final List<_MembershipCardContent> cards;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          if (index > 0) const SizedBox(width: MembershipSection._cardGap),
          Expanded(
            child: _MembershipCardItem(
              card: cards[index],
              usesCoordinatedHeight: true,
            ),
          ),
        ],
      ],
    ),
  );
}

final class _MembershipCardItem extends StatelessWidget {
  const _MembershipCardItem({
    required this.card,
    required this.usesCoordinatedHeight,
  });

  final _MembershipCardContent card;
  final bool usesCoordinatedHeight;

  @override
  Widget build(BuildContext context) => MembershipCard(
    semanticId: card.semanticId,
    variant: card.variant,
    tierName: card.tierName,
    price: card.price,
    billingPeriod: card.billingPeriod,
    priceSemanticLabel: card.priceSemanticLabel,
    description: card.description,
    benefits: card.benefits,
    ctaLabel: card.ctaLabel,
    footnote: card.footnote,
    badgeLabel: card.badgeLabel,
    usesCoordinatedHeight: usesCoordinatedHeight,
  );
}
