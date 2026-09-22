import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_benefit_card.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_mobile_carousel.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Mobile carousel of the three Founding Member benefits.
final class FoundingMemberMobileCarousel extends StatelessWidget {
  /// Creates the mobile carousel from localized benefit-card data.
  const FoundingMemberMobileCarousel({required this.cards, super.key});

  static const _pageGutter = 16.0;
  static const _cardGap = 8.0;
  static const _figmaCardHeight = 360.0;
  static const _cardPadding = 32.0;
  static const _iconExtent = 60.0;
  static const _textGap = 8.0;
  static const _minimumContentSeparation = 12.0;

  /// Localized Founding Member cards in display order.
  final List<FoundingMemberCardContent> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final sectionWidth = constraints.maxWidth;
      final viewportWidth = sectionWidth - _pageGutter;
      final cardWidth = sectionWidth - (_pageGutter * 2);
      final pageExtent = cardWidth + _cardGap;
      final cardHeight = _cardHeightFor(context, cardWidth);

      return Padding(
        padding: const EdgeInsetsDirectional.only(start: _pageGutter),
        child: SizedBox(
          key: const Key('foundingMemberMobileCarouselBounds'),
          width: viewportWidth,
          child: LandingMobileCarousel(
            itemCount: cards.length,
            viewportFraction: pageExtent / viewportWidth,
            pageHeight: cardHeight,
            itemGap: _cardGap,
            previousSemanticLabel:
                context.l10n.landingFoundingMemberCarouselPrevious,
            nextSemanticLabel: context.l10n.landingFoundingMemberCarouselNext,
            pageSemanticLabelBuilder: (currentPage, pageCount) => context.l10n
                .landingFoundingMemberCarouselPosition(currentPage, pageCount),
            itemBuilder: (context, index) {
              final card = cards[index];

              return FoundingMemberBenefitCard(
                semanticId: card.semanticId,
                iconAsset: card.iconAsset,
                title: card.title,
                body: card.body,
                usesCoordinatedHeight: true,
              );
            },
          ),
        ),
      );
    },
  );

  double _cardHeightFor(BuildContext context, double cardWidth) {
    final textWidth = cardWidth - (_cardPadding * 2);
    var tallestTextGroup = 0.0;

    for (final card in cards) {
      final titleHeight = _textHeight(
        context,
        card.title,
        LandingTextStyles.foundingMemberCardTitle,
        textWidth,
      );
      final bodyHeight = _textHeight(
        context,
        card.body,
        LandingTextStyles.compactSectionBody,
        textWidth,
      );
      final textGroupHeight = titleHeight + _textGap + bodyHeight;
      if (textGroupHeight > tallestTextGroup) {
        tallestTextGroup = textGroupHeight;
      }
    }

    final requiredHeight =
        (_cardPadding * 2) +
        _iconExtent +
        _minimumContentSeparation +
        tallestTextGroup;
    return requiredHeight.clamp(_figmaCardHeight, double.infinity);
  }

  double _textHeight(
    BuildContext context,
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);

    return painter.height;
  }
}
