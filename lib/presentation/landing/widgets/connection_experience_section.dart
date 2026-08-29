import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_section_placeholder.dart';

/// Structural boundary for the future connection-experience section.
final class ConnectionExperienceSection extends StatelessWidget {
  /// Creates the connection-experience skeleton.
  const ConnectionExperienceSection({super.key});

  @override
  Widget build(BuildContext context) => const LandingSectionPlaceholder(
    desktopMinHeight: 1130,
    backgroundColor: AppColors.lightForeground,
  );
}
