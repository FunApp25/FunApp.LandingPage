import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Heading for the research section.
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 628),
      child: Semantics(
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
    );
  }
}
