import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Heading and supporting copy for the membership section.
final class MembershipIntroduction extends StatelessWidget {
  /// Creates the membership introduction.
  const MembershipIntroduction({required this.headingSize, super.key});

  /// Responsive heading font size.
  final double headingSize;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 474),
    child: Column(
      children: [
        Semantics(
          key: const Key('membershipHeadingSemantics'),
          label: context.l10n.landingMembershipHeading,
          header: true,
          excludeSemantics: true,
          child: Text(
            context.l10n.landingMembershipHeading,
            key: const Key('membershipHeadingText'),
            textAlign: TextAlign.center,
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
          textAlign: TextAlign.center,
          style: LandingTextStyles.statsAttribution,
        ),
      ],
    ),
  );
}
