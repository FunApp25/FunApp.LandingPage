import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_section_placeholder.dart';

/// Structural boundary for the future FAQ section.
final class FaqSection extends StatelessWidget {
  /// Creates the FAQ skeleton.
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) => const LandingSectionPlaceholder(
    desktopMinHeight: 1895,
    backgroundColor: AppColors.lightForeground,
  );
}
