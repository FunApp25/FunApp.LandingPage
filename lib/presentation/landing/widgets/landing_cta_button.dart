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

/// Presents a landing-page CTA without claiming unresolved interaction.
///
/// Figma defines these CTA visuals but does not define their destinations.
/// This widget therefore intentionally has no gesture, link, or button
/// semantics. A real interactive boundary can wrap this presentation once a
/// destination and behavior are approved.
final class LandingCtaButton extends StatelessWidget {
  /// Creates a visual landing-page CTA.
  const LandingCtaButton({
    required this.label,
    required this.size,
    super.key,
  });

  /// Localized visible label.
  final String label;

  /// Active visual treatment.
  final LandingCtaSize size;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isProminent = size == LandingCtaSize.prominent;
      final useConstrainedProminentLayout =
          isProminent &&
          constraints.hasBoundedWidth &&
          constraints.maxWidth < 320;
      final horizontalPadding = switch (size) {
        LandingCtaSize.compact => 20.0,
        LandingCtaSize.prominent when useConstrainedProminentLayout => 20.0,
        LandingCtaSize.prominent => 40.0,
      };

      final labelWidget = Text(
        label,
        style: switch (size) {
          LandingCtaSize.compact => AppTextStyles.landingHeaderCta,
          LandingCtaSize.prominent => AppTextStyles.landingHeroCta,
        },
      );

      final content = switch (size) {
        LandingCtaSize.compact => labelWidget,
        LandingCtaSize.prominent => Row(
          mainAxisSize: useConstrainedProminentLayout
              ? MainAxisSize.max
              : MainAxisSize.min,
          children: [
            if (useConstrainedProminentLayout)
              Expanded(child: labelWidget)
            else
              labelWidget,
            const SizedBox(width: 8),
            SvgPicture.asset(
              AppAssets.arrowUpRight,
              key: const Key('landingCtaArrow'),
              width: 16,
              height: 16,
              excludeFromSemantics: true,
            ),
          ],
        ),
      };

      return DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.warmOrange,
          borderRadius: BorderRadius.all(
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
    },
  );
}
