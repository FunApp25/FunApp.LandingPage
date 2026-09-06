import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_stat_card.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_mobile_carousel.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_scroll_reveal.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';

/// Mobile Research carousel and its coordinated one-time reveal.
final class ResearchMobileCarousel extends StatelessWidget {
  /// Creates the mobile carousel from localized statistic card data.
  const ResearchMobileCarousel({required this.cards, super.key});

  static const _pageGutter = 16.0;
  static const _cardGap = 8.0;
  static const _figmaCardHeight = 404.0;
  static const _figmaViewportWidth = 390.0;
  static const _supportedMinimumWidth = 320.0;
  static const _revealDuration = Duration(milliseconds: 520);
  static const _triggerViewportFraction = 0.7;
  static const _initialDistance = 10.0;
  static const _initialOpacity = 0.1;

  /// Localized statistic card data in display order.
  final List<({String value, String description})> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final sectionWidth = constraints.maxWidth;
      final viewportWidth = sectionWidth - _pageGutter;
      final cardWidth = sectionWidth - (_pageGutter * 2);
      final pageExtent = cardWidth + _cardGap;
      final viewportFraction = pageExtent / viewportWidth;
      // Figma proves 404px at 390px. The narrower supported width adds the
      // lost horizontal space back vertically so long localized descriptions
      // retain the approved type role without clipping.
      final narrowHeightAdjustment = (_figmaViewportWidth - sectionWidth).clamp(
        0,
        _figmaViewportWidth - _supportedMinimumWidth,
      );
      final cardHeight = _figmaCardHeight + narrowHeightAdjustment;

      return LandingScrollReveal(
        key: const Key('researchStatsReveal'),
        duration: _revealDuration,
        triggerViewportFraction: _triggerViewportFraction,
        transitionBuilder: (context, progress, child) {
          final curvedProgress = LandingMotion.standardCurve.transform(
            progress,
          );

          return Transform.translate(
            key: const Key('researchMobileCarouselRevealTransform'),
            offset: Offset(0, _initialDistance * (1 - curvedProgress)),
            child: Opacity(
              key: const Key('researchMobileCarouselRevealOpacity'),
              opacity:
                  _initialOpacity + ((1 - _initialOpacity) * curvedProgress),
              alwaysIncludeSemantics: true,
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: _pageGutter),
          child: SizedBox(
            key: const Key('researchMobileCarouselBounds'),
            width: viewportWidth,
            child: LandingMobileCarousel(
              itemCount: cards.length,
              viewportFraction: viewportFraction,
              pageHeight: cardHeight,
              itemGap: _cardGap,
              previousSemanticLabel:
                  context.l10n.landingResearchCarouselPrevious,
              nextSemanticLabel: context.l10n.landingResearchCarouselNext,
              pageSemanticLabelBuilder: (currentPage, pageCount) => context.l10n
                  .landingResearchCarouselPosition(currentPage, pageCount),
              itemBuilder: (context, index) => ResearchStatCard(
                value: cards[index].value,
                description: cards[index].description,
                usesDesktopMinimumHeight: true,
              ),
            ),
          ),
        ),
      );
    },
  );
}
