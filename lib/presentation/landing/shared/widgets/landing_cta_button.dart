import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

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
    this.compactHorizontalPadding = 20,
    this.compactVisualHeight,
    this.compactVisualAlignment = Alignment.center,
    this.compactExpandWidth = false,
    this.prominentContentExpands = false,
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

  /// Horizontal inset for the compact treatment.
  ///
  /// The default preserves every established header composition. Mobile
  /// callers may reduce it when localized text has less available width.
  final double compactHorizontalPadding;

  /// Optional compact visual height for a mobile Figma control.
  ///
  /// When set, the visual surface keeps this height while its interactive
  /// wrapper retains the shared minimum target size.
  final double? compactVisualHeight;

  /// Alignment of an optional compact visual surface inside its target.
  final AlignmentGeometry compactVisualAlignment;

  /// Whether an optional compact visual surface should fill its width.
  final bool compactExpandWidth;

  /// Whether a full-width prominent CTA must keep its label flexible.
  final bool prominentContentExpands;

  /// Approved activation callback, or null while behavior remains deferred.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isProminent = size == LandingCtaSize.prominent;
      final compactHeight =
          compactVisualHeight ?? AppSizes.mobileControlTargetSize;
      final usesCompactTarget = !isProminent && compactVisualHeight != null;
      final backgroundColor = switch (appearance) {
        LandingCtaAppearance.brandOrange => AppColors.warmOrange,
        LandingCtaAppearance.brandBlue => AppColors.blueMain,
        LandingCtaAppearance.brandYellow => AppColors.yellowAccent,
      };
      final foregroundColor = switch (appearance) {
        LandingCtaAppearance.brandOrange => AppColors.lightForeground,
        LandingCtaAppearance.brandBlue => AppColors.lightForeground,
        LandingCtaAppearance.brandYellow => AppColors.textPrimary,
      };
      final useConstrainedProminentLayout =
          isProminent &&
          (prominentContentExpands ||
              (constraints.hasBoundedWidth && constraints.maxWidth < 480));
      final horizontalPadding = switch (size) {
        LandingCtaSize.compact => compactHorizontalPadding,
        LandingCtaSize.prominent when useConstrainedProminentLayout => 20.0,
        LandingCtaSize.prominent => 40.0,
      };

      final labelStyle = switch (size) {
        LandingCtaSize.compact => LandingTextStyles.headerCta,
        LandingCtaSize.prominent => LandingTextStyles.heroCta,
      }.copyWith(color: foregroundColor);
      final labelWidget = Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        style: labelStyle,
      );
      final compactLabel = () {
        if (!constraints.hasBoundedWidth || isProminent) {
          return labelWidget;
        }

        final textPainter = TextPainter(
          text: TextSpan(text: label, style: labelStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final desiredWidth = textPainter.width + (horizontalPadding * 2);
        if (desiredWidth <= constraints.maxWidth) {
          return UnconstrainedBox(
            constrainedAxis: Axis.vertical,
            child: labelWidget,
          );
        }

        return SizedBox(
          width: math.max(0, constraints.maxWidth - (horizontalPadding * 2)),
          child: FittedBox(fit: BoxFit.scaleDown, child: labelWidget),
        );
      }();

      final content = switch (size) {
        LandingCtaSize.compact => compactLabel,
        LandingCtaSize.prominent => Row(
          mainAxisSize: useConstrainedProminentLayout
              ? MainAxisSize.max
              : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (useConstrainedProminentLayout)
              Expanded(child: labelWidget)
            else if (constraints.hasBoundedWidth)
              Flexible(child: labelWidget)
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

      final visual = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: isProminent
              ? AppSizes.mobileControlTargetSize
              : compactHeight,
          maxHeight: isProminent ? double.infinity : compactHeight,
        ),
        child: DecoratedBox(
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
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: content,
            ),
          ),
        ),
      );

      final compactVisual = compactExpandWidth
          ? SizedBox(width: double.infinity, child: visual)
          : visual;
      final renderedVisual = usesCompactTarget
          ? Align(
              alignment: compactVisualAlignment,
              widthFactor: compactExpandWidth ? null : 1,
              heightFactor: AppSizes.mobileControlTargetSize / compactHeight,
              child: compactVisual,
            )
          : compactVisual;

      final callback = onPressed;
      if (callback != null) {
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
              child: renderedVisual,
            ),
          ),
        );
      } else {
        return renderedVisual;
      }
    },
  );
}
