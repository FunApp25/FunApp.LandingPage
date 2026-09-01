import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Heading and supporting copy for the Founding Member section.
final class FoundingMemberIntroduction extends StatelessWidget {
  /// Creates the Founding Member introduction.
  const FoundingMemberIntroduction({required this.headingSize, super.key});

  /// Responsive heading font size.
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
