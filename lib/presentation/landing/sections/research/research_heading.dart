import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Heading and attribution for the research section.
final class ResearchHeading extends StatelessWidget {
  /// Creates the research heading.
  const ResearchHeading({required this.headingSize, super.key});

  /// Responsive heading font size.
  final double headingSize;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
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
            style: LandingTextStyles.sectionHeading.copyWith(
              fontSize: headingSize,
              letterSpacing: headingSize * -0.01,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text.rich(
          key: const Key('researchStatsAttribution'),
          TextSpan(
            style: LandingTextStyles.statsAttribution,
            children: [
              TextSpan(text: '${context.l10n.landingStatsAttributionIntro} '),
              TextSpan(
                text: context.l10n.landingStatsBelongingForum,
                style: LandingTextStyles.statsAttributionSource,
              ),
              TextSpan(
                text: ' · ',
                style: LandingTextStyles.statsAttributionSeparator,
              ),
              TextSpan(
                text: context.l10n.landingStatsMarmaladeTrust,
                style: LandingTextStyles.statsAttributionSource,
              ),
              TextSpan(
                text: ' · ',
                style: LandingTextStyles.statsAttributionSeparator,
              ),
              TextSpan(
                text: context.l10n.landingStatsBacpYouGov,
                style: LandingTextStyles.statsAttributionSource,
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
