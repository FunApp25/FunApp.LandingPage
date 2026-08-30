import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';

/// Active visual sizes in the Figma landing-page CTA family.
enum LandingCtaSize {
  /// Compact header treatment from `Btn - size xs`.
  compact,

  /// Prominent hero treatment from `Btn - size s`.
  prominent,
}

/// Active color treatments in the Figma landing-page CTA family.
enum LandingCtaAppearance {
  /// Orange CTA used by the header and hero.
  brandOrange,

  /// Blue CTA used by the Founding Friends card.
  brandBlue,

  /// Yellow CTA used by the venue card.
  brandYellow,
}

/// Presents a landing-page CTA with optional approved interaction.
final class LandingCtaButton extends StatelessWidget {
  /// Creates a visual landing-page CTA.
  const LandingCtaButton({
    required this.label,
    required this.size,
    this.appearance = LandingCtaAppearance.brandOrange,
    this.arrowKey,
    this.onPressed,
    super.key,
  });

  /// Localized visible label.
  final String label;

  /// Active visual treatment.
  final LandingCtaSize size;

  /// Active visual color treatment.
  final LandingCtaAppearance appearance;

  /// Optional key for distinguishing prominent CTA arrow instances in tests.
  final Key? arrowKey;

  /// Approved activation callback, or null while behavior remains deferred.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isProminent = size == LandingCtaSize.prominent;
      final backgroundColor = switch (appearance) {
        LandingCtaAppearance.brandOrange => AppColors.warmOrange,
        LandingCtaAppearance.brandBlue => AppColors.blueMain,
        LandingCtaAppearance.brandYellow => AppColors.yellowAccent,
      };
      final foregroundColor = switch (appearance) {
        LandingCtaAppearance.brandOrange => AppColors.textPrimary,
        LandingCtaAppearance.brandBlue => AppColors.lightForeground,
        LandingCtaAppearance.brandYellow => AppColors.textPrimary,
      };
      final useConstrainedProminentLayout =
          isProminent &&
          constraints.hasBoundedWidth &&
          constraints.maxWidth < 480;
      final horizontalPadding = switch (size) {
        LandingCtaSize.compact => 20.0,
        LandingCtaSize.prominent when useConstrainedProminentLayout => 20.0,
        LandingCtaSize.prominent => 40.0,
      };

      final labelWidget = Text(
        label,
        textAlign: TextAlign.center,
        style: switch (size) {
          LandingCtaSize.compact => AppTextStyles.landingHeaderCta,
          LandingCtaSize.prominent => AppTextStyles.landingHeroCta,
        }.copyWith(color: foregroundColor),
      );

      final content = switch (size) {
        LandingCtaSize.compact => labelWidget,
        LandingCtaSize.prominent => Row(
          mainAxisSize: useConstrainedProminentLayout
              ? MainAxisSize.max
              : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (useConstrainedProminentLayout)
              Expanded(child: labelWidget)
            else
              labelWidget,
            const SizedBox(width: 8),
            SvgPicture.asset(
              AppAssets.arrowUpRight,
              key: arrowKey ?? const Key('landingCtaArrow'),
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                foregroundColor,
                BlendMode.srcIn,
              ),
              excludeFromSemantics: true,
            ),
          ],
        ),
      };

      final visual = DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppSizes.pillRadius),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isProminent ? 12 : 8,
          ),
          child: content,
        ),
      );

      final callback = onPressed;
      if (callback == null) {
        return visual;
      }

      return Semantics(
        label: label,
        button: true,
        onTap: callback,
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: callback,
            excludeFromSemantics: true,
            mouseCursor: SystemMouseCursors.click,
            focusColor: AppColors.energeticPlum.withValues(alpha: 0.1),
            hoverColor: AppColors.energeticPlum.withValues(alpha: 0.06),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppSizes.pillRadius),
            ),
            child: visual,
          ),
        ),
      );
    },
  );
}
