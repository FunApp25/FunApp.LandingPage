import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_section_placeholder.dart';

/// Structural boundary for the future welcome statement.
final class WelcomeStatementSection extends StatelessWidget {
  /// Creates the welcome-statement skeleton.
  const WelcomeStatementSection({super.key});

  @override
  Widget build(BuildContext context) => const LandingSectionPlaceholder(
    desktopMinHeight: 480,
    backgroundColor: AppColors.beigeAccent,
  );
}
