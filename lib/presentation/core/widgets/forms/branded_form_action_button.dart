import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Shared content-driven submit action for the public forms.
final class BrandedFormActionButton extends StatelessWidget {
  /// Creates the responsive branded action.
  const BrandedFormActionButton({
    required this.buttonKey,
    required this.arrowKey,
    required this.label,
    required this.onPressed,
    this.disabledBackgroundColor = AppColors.warmOrange,
    super.key,
  });

  /// Stable key applied to the underlying button.
  final Key buttonKey;

  /// Stable key applied to the decorative arrow.
  final Key arrowKey;

  /// Localized action label.
  final String label;

  /// Action callback, or null when the control is disabled.
  final VoidCallback? onPressed;

  /// Fill used when [onPressed] is null.
  final Color disabledBackgroundColor;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final expands = MediaQuery.sizeOf(context).width < 600;
      final labelStyle = LandingTextStyles.heroCta.copyWith(
        color: AppColors.lightForeground,
      );
      final labelPainter = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      // Keep a rounding allowance between TextPainter and RenderParagraph.
      final contentWidth = labelPainter.width + 80 + 8 + 16 + 4;
      final targetWidth = expands
          ? constraints.maxWidth
          : contentWidth.clamp(144.0, constraints.maxWidth);
      final labelCanWrap = expands || contentWidth > constraints.maxWidth;
      final labelText = Text(
        label,
        textAlign: TextAlign.center,
        style: labelStyle,
      );
      final content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: labelCanWrap ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (labelCanWrap) Flexible(child: labelText) else labelText,
          const SizedBox(width: 8),
          SvgPicture.asset(
            AppAssets.venueSendArrowUpRight,
            key: arrowKey,
            width: 16,
            height: 16,
            excludeFromSemantics: true,
          ),
        ],
      );

      return Align(
        child: SizedBox(
          width: targetWidth,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: FilledButton(
              key: buttonKey,
              onPressed: onPressed,
              style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll(Size(144, 48)),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return disabledBackgroundColor;
                  } else {
                    return AppColors.warmOrange;
                  }
                }),
                foregroundColor: const WidgetStatePropertyAll(
                  AppColors.lightForeground,
                ),
                overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.focused)) {
                    return AppColors.energeticPlum.withValues(alpha: 0.16);
                  } else if (states.contains(WidgetState.hovered)) {
                    return AppColors.lightForeground.withValues(alpha: 0.08);
                  } else {
                    return null;
                  }
                }),
                shape: const WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppSizes.pillRadius),
                    ),
                  ),
                ),
              ),
              child: content,
            ),
          ),
        ),
      );
    },
  );
}
