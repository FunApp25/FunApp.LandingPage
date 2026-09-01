import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Centered introduction above the venue promotional card.
final class VenueIntroduction extends StatelessWidget {
  /// Creates the venue introduction.
  const VenueIntroduction({required this.headingSize, super.key});

  /// Responsive introduction heading font size.
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
