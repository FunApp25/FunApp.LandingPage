import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_section_placeholder.dart';

/// Structural boundary for the future hero section.
final class HeroSection extends StatelessWidget {
  /// Creates the hero section skeleton.
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) => const LandingSectionPlaceholder(
    desktopMinHeight: 644,
    backgroundColor: AppColors.lightForeground,
    padding: EdgeInsets.symmetric(
      horizontal: AppSizes.desktopPageGutter,
    ),
    maxContentWidth: AppSizes.maxContentWidth,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.beigeAccent,
        borderRadius: BorderRadius.all(
          Radius.circular(AppSizes.cardRadius),
        ),
      ),
    ),
  );
}
