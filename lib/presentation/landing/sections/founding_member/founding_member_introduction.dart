import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Heading and supporting copy for the Founding Member section.
final class FoundingMemberIntroduction extends StatelessWidget {
  /// Creates the Founding Member introduction.
  const FoundingMemberIntroduction({
    required this.headingSize,
    this.usesMobileFigmaTypography = false,
    super.key,
  });

  /// Responsive heading font size.
  final double headingSize;

  /// Whether the centered mobile Figma type and alignment apply.
  final bool usesMobileFigmaTypography;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: usesMobileFigmaTypography
        ? CrossAxisAlignment.stretch
        : CrossAxisAlignment.start,
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
            height: usesMobileFigmaTypography ? 42 / 32 : null,
            letterSpacing: headingSize * -0.01,
          ),
          textAlign: usesMobileFigmaTypography ? TextAlign.center : null,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        context.l10n.landingFoundingMemberBody,
        key: const Key('foundingMemberBodyText'),
        style: LandingTextStyles.statsAttribution,
        textAlign: usesMobileFigmaTypography ? TextAlign.center : null,
      ),
    ],
  );
}
