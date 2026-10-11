import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_design.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// CTA at the base of a membership card.
final class MembershipCardAction extends StatelessWidget {
  /// Creates the membership card action presentation.
  const MembershipCardAction({
    required this.semanticId,
    required this.design,
    required this.label,
    this.onPressed,
    super.key,
  });

  /// Stable membership card identifier.
  final String semanticId;

  /// Visual tokens for this membership tier.
  final MembershipCardDesign design;

  /// Localized CTA label.
  final String label;

  /// Approved action, or null to preserve the established no-op behavior.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    onTap: onPressed ?? _handleDeferredPress,
    excludeSemantics: true,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('membershipCta-$semanticId'),
        onTap: onPressed ?? _handleDeferredPress,
        excludeFromSemantics: true,
        mouseCursor: SystemMouseCursors.click,
        focusColor: AppColors.energeticPlum.withValues(alpha: 0.1),
        hoverColor: AppColors.energeticPlum.withValues(alpha: 0.06),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSizes.pillRadius),
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: design.ctaBackgroundColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppSizes.pillRadius),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Center(
              child: Text(
                label,
                key: Key('membershipCtaLabel-$semanticId'),
                textAlign: TextAlign.center,
                style: LandingTextStyles.heroCta.copyWith(
                  color: design.ctaForegroundColor,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  static void _handleDeferredPress() {}
}
