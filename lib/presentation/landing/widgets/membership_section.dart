import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/membership_card.dart';

/// Membership introduction and tiers from Figma node `2190:1606`.
final class MembershipSection extends StatelessWidget {
  /// Creates the membership section.
  const MembershipSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
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
              child: LayoutBuilder(
                builder: (context, contentConstraints) {
                  final cards = _membershipCards(context);
                  final useWideComposition =
                      contentConstraints.maxWidth >=
                      _minimumWideCompositionWidth;

                  if (useWideComposition) {
                    return Row(
                      key: const Key('membershipDesktopLayout'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: _introWidth,
                          child: _MembershipIntroduction(headingSize: 44),
                        ),
                        const SizedBox(width: _compositionGap),
                        Expanded(child: _MembershipCardGrid(cards: cards)),
                      ],
                    );
                  }

                  return Column(
                    key: const Key('membershipStackedIntroLayout'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MembershipIntroduction(
                        headingSize: AppSizes.sectionHeadingSizeFor(
                          availableWidth,
                        ),
                      ),
                      SizedBox(height: availableWidth < 600 ? 32 : 48),
                      _MembershipCardGrid(cards: cards),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    ),
  );

  static const _introWidth = 443.0;
  static const _compositionGap = 16.0;
  static const _minimumCardWidth = 320.0;
  static const _cardGap = 16.0;
  static const double _minimumWideCompositionWidth =
      _introWidth + _compositionGap + (_minimumCardWidth * 2) + _cardGap;

  static List<_MembershipCardContent> _membershipCards(
    BuildContext context,
  ) => [
    (
      semanticId: 'free',
      tierName: context.l10n.landingMembershipFreeTier,
      price: context.l10n.landingMembershipFreePrice,
      priceSemanticLabel: context.l10n.landingMembershipFreePriceSemantics,
      description: context.l10n.landingMembershipFreeDescription,
    ),
    (
      semanticId: 'hereNow',
      tierName: context.l10n.landingMembershipHereNowTier,
      price: context.l10n.landingMembershipHereNowPrice,
      priceSemanticLabel: context.l10n.landingMembershipHereNowPriceSemantics,
      description: context.l10n.landingMembershipHereNowDescription,
    ),
  ];
}

typedef _MembershipCardContent = ({
  String semanticId,
  String tierName,
  String price,
  String priceSemanticLabel,
  String description,
});

final class _MembershipIntroduction extends StatelessWidget {
  const _MembershipIntroduction({required this.headingSize});

  final double headingSize;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        key: const Key('membershipHeadingSemantics'),
        label: context.l10n.landingMembershipHeading,
        header: true,
        excludeSemantics: true,
        child: Text(
          context.l10n.landingMembershipHeading,
          key: const Key('membershipHeadingText'),
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
        style: LandingTextStyles.statsAttribution,
      ),
    ],
  );
}

final class _MembershipCardGrid extends StatelessWidget {
  const _MembershipCardGrid({required this.cards});

  final List<_MembershipCardContent> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final useTwoColumns =
          constraints.maxWidth >=
          (MembershipSection._minimumCardWidth * 2) +
              MembershipSection._cardGap;
      final columns = useTwoColumns ? 2 : 1;
      final cardWidth = useTwoColumns
          ? (constraints.maxWidth - MembershipSection._cardGap) / 2
          : constraints.maxWidth;

      return Wrap(
        key: Key('membershipCardsColumns$columns'),
        spacing: MembershipSection._cardGap,
        runSpacing: MembershipSection._cardGap,
        children: [
          for (final card in cards)
            SizedBox(
              width: cardWidth,
              child: MembershipCard(
                semanticId: card.semanticId,
                tierName: card.tierName,
                price: card.price,
                billingPeriod: context.l10n.landingMembershipBillingPeriod,
                priceSemanticLabel: card.priceSemanticLabel,
                description: card.description,
                offerHint: context.l10n.landingMembershipOfferHint,
                offerLabel: context.l10n.landingMembershipFoundingFriendLink,
                usesDesktopMinimumHeight: useTwoColumns,
              ),
            ),
        ],
      );
    },
  );
}
