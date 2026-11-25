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
    this.expand = false,
    this.backgroundColor = AppColors.warmOrange,
    this.foregroundColor = AppColors.lightForeground,
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

  /// Fills the parent's allocated space and allows the label to wrap.
  final bool expand;

  /// Fill used when the action is enabled.
  final Color backgroundColor;

  /// Color of the label and decorative arrow.
  final Color foregroundColor;

  /// Fill used when [onPressed] is null.
  final Color disabledBackgroundColor;

  @override
  Widget build(BuildContext context) => expand
      ? _button(labelCanWrap: true)
      : LayoutBuilder(
          builder: (context, constraints) {
            final expands = MediaQuery.sizeOf(context).width < 600;
            final labelPainter = TextPainter(
              text: TextSpan(text: label, style: LandingTextStyles.heroCta),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
              maxLines: 1,
            )..layout();
            // Allow for rounding between TextPainter and RenderParagraph.
            final contentWidth = labelPainter.width + 80 + 8 + 16 + 4;
            labelPainter.dispose();
            final targetWidth = expands
                ? constraints.maxWidth
                : contentWidth.clamp(144.0, constraints.maxWidth);
            final labelCanWrap = expands || contentWidth > constraints.maxWidth;
            return Align(
              child: SizedBox(
                width: targetWidth,
                child: _button(labelCanWrap: labelCanWrap),
              ),
            );
          },
        );

  Widget _button({required bool labelCanWrap}) {
    final labelText = Text(
      label,
      textAlign: TextAlign.center,
      style: LandingTextStyles.heroCta.copyWith(color: foregroundColor),
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
          colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
          excludeFromSemantics: true,
        ),
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: FilledButton(
        key: buttonKey,
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(144, 48)),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: expand ? 20 : 40,
              vertical: 12,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return disabledBackgroundColor;
            } else {
              return backgroundColor;
            }
          }),
          foregroundColor: WidgetStatePropertyAll(foregroundColor),
          side: expand
              ? WidgetStateProperty.resolveWith<BorderSide?>((states) {
                  if (states.contains(WidgetState.focused)) {
                    return BorderSide(color: foregroundColor, width: 2);
                  }
                  return null;
                })
              : null,
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
    );
  }
}
