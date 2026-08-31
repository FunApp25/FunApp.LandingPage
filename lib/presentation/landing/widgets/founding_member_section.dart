import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/founding_member_benefit_card.dart';

/// Founding Member explanation from Figma node `2243:2446`.
final class FoundingMemberSection extends StatelessWidget {
  /// Creates the Founding Member explanation section.
  const FoundingMemberSection({super.key});

  static const _introWidth = 328.0;
  static const _cardGap = 16.0;
  static const _minimumCardWidth = 328.0;
  static const _wideCompositionWidth = 1360.0;

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: const Key('foundingMemberBackground'),
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
                  final cards = _benefitCards(context);
                  if (contentConstraints.maxWidth >= _wideCompositionWidth) {
                    return Row(
                      key: const Key('foundingMemberWideLayout'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: _introWidth,
                          child: _FoundingMemberIntroduction(headingSize: 44),
                        ),
                        const SizedBox(width: _cardGap),
                        Expanded(
                          child: _FoundingMemberCardGrid(
                            cards: cards,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      key: const Key('foundingMemberStackedIntroLayout'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: _introWidth,
                            child: _FoundingMemberIntroduction(
                              headingSize: AppSizes.sectionHeadingSizeFor(
                                availableWidth,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: availableWidth < 600 ? 32 : 48),
                        _FoundingMemberCardGrid(
                          cards: cards,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    ),
  );

  static List<_FoundingMemberCardContent> _benefitCards(
    BuildContext context,
  ) => [
    (
      semanticId: 'recognised',
      iconAsset: AppAssets.foundingMemberUsers,
      title: context.l10n.landingFoundingMemberRecognisedTitle,
      body: context.l10n.landingFoundingMemberRecognisedBody,
    ),
    (
      semanticId: 'access',
      iconAsset: AppAssets.foundingMemberRocket,
      title: context.l10n.landingFoundingMemberAccessTitle,
      body: context.l10n.landingFoundingMemberAccessBody,
    ),
    (
      semanticId: 'voice',
      iconAsset: AppAssets.foundingMemberChat,
      title: context.l10n.landingFoundingMemberVoiceTitle,
      body: context.l10n.landingFoundingMemberVoiceBody,
    ),
  ];
}

typedef _FoundingMemberCardContent = ({
  String semanticId,
  String iconAsset,
  String title,
  String body,
});

final class _FoundingMemberIntroduction extends StatelessWidget {
  const _FoundingMemberIntroduction({required this.headingSize});

  final double headingSize;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        key: const Key('foundingMemberHeadingSemantics'),
        label: context.l10n.landingFoundingMemberHeading,
        header: true,
        excludeSemantics: true,
        child: Text(
          context.l10n.landingFoundingMemberHeading,
          key: const Key('foundingMemberHeadingText'),
          style: LandingTextStyles.sectionHeading.copyWith(
            fontSize: headingSize,
            letterSpacing: headingSize * -0.01,
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        context.l10n.landingFoundingMemberBody,
        key: const Key('foundingMemberBodyText'),
        style: LandingTextStyles.statsAttribution,
      ),
    ],
  );
}

final class _FoundingMemberCardGrid extends StatelessWidget {
  const _FoundingMemberCardGrid({
    required this.cards,
  });

  final List<_FoundingMemberCardContent> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const threeColumnWidth =
          (FoundingMemberSection._minimumCardWidth * 3) +
          (FoundingMemberSection._cardGap * 2);
      const twoColumnWidth =
          (FoundingMemberSection._minimumCardWidth * 2) +
          FoundingMemberSection._cardGap;
      final int columns;
      if (constraints.maxWidth >= threeColumnWidth) {
        columns = 3;
      } else if (constraints.maxWidth >= twoColumnWidth) {
        columns = 2;
      } else {
        columns = 1;
      }

      return Column(
        key: Key('foundingMemberCardsColumns$columns'),
        children: switch (columns) {
          3 => [
            _FoundingMemberCardRow(cards: cards),
          ],
          2 => [
            _FoundingMemberCardRow(cards: cards.take(2).toList()),
            const SizedBox(height: FoundingMemberSection._cardGap),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FoundingMemberSection._cardGap / 4,
                ),
                child: _FoundingMemberCardItem(
                  card: cards[2],
                  usesCoordinatedHeight: false,
                ),
              ),
            ),
          ],
          _ => [
            for (var index = 0; index < cards.length; index++) ...[
              if (index > 0)
                const SizedBox(height: FoundingMemberSection._cardGap),
              _FoundingMemberCardItem(
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

final class _FoundingMemberCardRow extends StatelessWidget {
  const _FoundingMemberCardRow({required this.cards});

  final List<_FoundingMemberCardContent> cards;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          if (index > 0) const SizedBox(width: FoundingMemberSection._cardGap),
          Expanded(
            child: _FoundingMemberCardItem(
              card: cards[index],
              usesCoordinatedHeight: true,
            ),
          ),
        ],
      ],
    ),
  );
}

final class _FoundingMemberCardItem extends StatelessWidget {
  const _FoundingMemberCardItem({
    required this.card,
    required this.usesCoordinatedHeight,
  });

  final _FoundingMemberCardContent card;
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
