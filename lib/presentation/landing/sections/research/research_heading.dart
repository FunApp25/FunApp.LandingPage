import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Heading and attribution for the research section.
final class ResearchHeading extends StatelessWidget {
  /// Creates the research heading.
  const ResearchHeading({
    required this.headingSize,
    this.usesMobileFigmaTypography = false,
    super.key,
  });

  /// Responsive heading font size.
  final double headingSize;

  /// Whether to use the tighter line heights from the mobile composition.
  final bool usesMobileFigmaTypography;

  @override
  Widget build(BuildContext context) {
    final headingStyle = LandingTextStyles.sectionHeading.copyWith(
      fontSize: headingSize,
      height: usesMobileFigmaTypography ? 42 / 32 : null,
      letterSpacing: headingSize * -0.01,
    );
    final attributionStyle = LandingTextStyles.statsAttribution.copyWith(
      height: usesMobileFigmaTypography ? 24 / 16 : null,
    );
    final sourceStyle = LandingTextStyles.statsAttributionSource.copyWith(
      height: usesMobileFigmaTypography ? 24 / 16 : null,
    );
    final separatorStyle = LandingTextStyles.statsAttributionSeparator.copyWith(
      height: usesMobileFigmaTypography ? 24 / 16 : null,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 628),
      child: Column(
        children: [
          Semantics(
            key: const Key('researchStatsHeadingSemantics'),
            label: context.l10n.landingStatsHeading,
            header: true,
            excludeSemantics: true,
            child: Text(
              context.l10n.landingStatsHeading,
              key: const Key('researchStatsHeadingText'),
              textAlign: TextAlign.center,
              style: headingStyle,
            ),
          ),
          const SizedBox(height: 12),
          Text.rich(
            key: const Key('researchStatsAttribution'),
            TextSpan(
              style: attributionStyle,
              children: [
                TextSpan(text: '${context.l10n.landingStatsAttributionIntro} '),
                TextSpan(
                  text: context.l10n.landingStatsBelongingForum,
                  style: sourceStyle,
                ),
                TextSpan(
                  text: ' · ',
                  style: separatorStyle,
                ),
                TextSpan(
                  text: context.l10n.landingStatsMarmaladeTrust,
                  style: sourceStyle,
                ),
                TextSpan(
                  text: ' · ',
                  style: separatorStyle,
                ),
                TextSpan(
                  text: context.l10n.landingStatsBacpYouGov,
                  style: sourceStyle,
                ),
                TextSpan(
                  text: ' ${context.l10n.landingStatsAttributionThanks}',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
