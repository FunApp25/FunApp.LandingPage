import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_promotional_card.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_scroll_reveal.dart';

/// Venue introduction and promotional card from Figma node `2190:1627`.
final class VenueSection extends StatelessWidget {
  /// Creates the venue section.
  const VenueSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.lightForeground,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = AppSizes.pageGutterFor(availableWidth);
        final bottomPadding = AppSizes.sectionVerticalPaddingFor(
          availableWidth,
        );
        final contentWidth = (availableWidth - (pageGutter * 2)).clamp(
          0.0,
          AppSizes.maxContentWidth,
        );
        final initialDistance = contentWidth < 780 ? 12.0 : 20.0;

        return Padding(
          padding: EdgeInsets.only(
            left: pageGutter,
            right: pageGutter,
            bottom: bottomPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Column(
                children: [
                  _VenueIntroduction(
                    headingSize: AppSizes.statementHeadingSizeFor(
                      availableWidth,
                    ),
                  ),
                  SizedBox(
                    height: switch (availableWidth) {
                      >= 1200 => 80,
                      >= 600 => 64,
                      _ => 40,
                    },
                  ),
                  LandingScrollReveal(
                    key: const Key('venueCardReveal'),
                    duration: LandingMotion.revealDuration,
                    transitionBuilder: (context, progress, child) {
                      final easedProgress = LandingMotion.standardCurve
                          .transform(progress);

                      return Transform.translate(
                        key: const Key('venueCardRevealTransform'),
                        offset: Offset(
                          -initialDistance * (1 - easedProgress),
                          0,
                        ),
                        child: Opacity(
                          key: const Key('venueCardRevealOpacity'),
                          opacity: 0.2 + (0.8 * easedProgress),
                          alwaysIncludeSemantics: true,
                          child: child,
                        ),
                      );
                    },
                    child: LandingPromotionalCard(
                      variant: LandingPromotionalCardVariant.venue,
                      heading: context.l10n.landingVenueCardHeading,
                      bodyParagraphs: [
                        context.l10n.landingVenueCardSupporting,
                      ],
                      ctaLabel: context.l10n.landingVenueCta,
                      imageSemanticLabel:
                          context.l10n.landingVenueImageDescription,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

final class _VenueIntroduction extends StatelessWidget {
  const _VenueIntroduction({required this.headingSize});

  final double headingSize;

  @override
  Widget build(BuildContext context) {
    final headingLeading = context.l10n.landingVenueHeadingLeading;
    final headingEmphasis = context.l10n.landingVenueHeadingEmphasis;
    final headingTrailing = context.l10n.landingVenueHeadingTrailing;
    final semanticLabel = '$headingLeading$headingEmphasis$headingTrailing';

    return ConstrainedBox(
      key: const Key('venueIntroductionBounds'),
      constraints: const BoxConstraints(maxWidth: 522),
      child: Column(
        children: [
          Semantics(
            key: const Key('venueIntroductionHeadingSemantics'),
            label: semanticLabel,
            header: true,
            excludeSemantics: true,
            child: Text.rich(
              key: const Key('venueIntroductionHeadingText'),
              TextSpan(
                text: headingLeading,
                style: LandingTextStyles.foundingOfferStatement.copyWith(
                  fontSize: headingSize,
                  letterSpacing: headingSize * -0.01,
                ),
                children: [
                  TextSpan(
                    text: headingEmphasis,
                    style: LandingTextStyles.foundingOfferStatementEmphasis
                        .copyWith(
                          fontSize: headingSize,
                          letterSpacing: headingSize * -0.01,
                          color: AppColors.warmOrange,
                        ),
                  ),
                  TextSpan(text: headingTrailing),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.landingVenueIntroductionFirst,
            key: const Key('venueIntroductionBody0'),
            textAlign: TextAlign.center,
            style: LandingTextStyles.compactSectionBody,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.landingVenueIntroductionSecond,
            key: const Key('venueIntroductionBody1'),
            textAlign: TextAlign.center,
            style: LandingTextStyles.compactSectionBody,
          ),
        ],
      ),
    );
  }
}
