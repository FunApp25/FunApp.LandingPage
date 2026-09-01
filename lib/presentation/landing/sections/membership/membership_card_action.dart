import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_design.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Visual-only CTA and footnote at the base of a membership card.
final class MembershipCardAction extends StatelessWidget {
  /// Creates the membership card action presentation.
  const MembershipCardAction({
    required this.semanticId,
    required this.design,
    required this.label,
    required this.footnote,
    super.key,
  });

  /// Stable membership card identifier.
  final String semanticId;

  /// Visual tokens for this membership tier.
  final MembershipCardDesign design;

  /// Localized visual-only CTA label.
  final String label;

  /// Localized note beneath the visual CTA.
  final String footnote;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DecoratedBox(
        key: Key('membershipCta-$semanticId'),
        decoration: BoxDecoration(
          color: design.ctaBackgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppSizes.pillRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  key: Key('membershipCtaLabel-$semanticId'),
                  textAlign: TextAlign.center,
                  style: LandingTextStyles.heroCta.copyWith(
                    color: design.ctaForegroundColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                design.ctaArrowAsset,
                key: Key('membershipCtaArrow-$semanticId'),
                width: 16,
                height: 16,
                excludeFromSemantics: true,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        footnote,
        key: Key('membershipFootnote-$semanticId'),
        textAlign: TextAlign.center,
        style: LandingTextStyles.membershipFootnote.copyWith(
          color: design.foregroundColor.withValues(alpha: 0.6),
        ),
      ),
    ],
  );
}
