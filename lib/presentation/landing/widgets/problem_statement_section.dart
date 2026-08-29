import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_section_placeholder.dart';

/// Structural boundary for the future problem statement.
final class ProblemStatementSection extends StatelessWidget {
  /// Creates the problem-statement skeleton.
  const ProblemStatementSection({super.key});

  @override
  Widget build(BuildContext context) => const LandingSectionPlaceholder(
    desktopMinHeight: 480,
    backgroundColor: AppColors.lightForeground,
  );
}
