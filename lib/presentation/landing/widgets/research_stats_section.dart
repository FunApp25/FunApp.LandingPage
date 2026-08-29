import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_section_placeholder.dart';

/// Structural boundary for the future research statistics section.
final class ResearchStatsSection extends StatelessWidget {
  /// Creates the research-statistics skeleton.
  const ResearchStatsSection({super.key});

  @override
  Widget build(BuildContext context) => const LandingSectionPlaceholder(
    desktopMinHeight: 858,
    backgroundColor: AppColors.beigeAccent,
  );
}
