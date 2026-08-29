import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_section_placeholder.dart';

/// Structural boundary for the future Founding Friends content.
final class FoundingFriendsSection extends StatelessWidget {
  /// Creates the Founding Friends skeleton.
  const FoundingFriendsSection({super.key});

  @override
  Widget build(BuildContext context) => const LandingSectionPlaceholder(
    desktopMinHeight: 842,
    backgroundColor: AppColors.lightForeground,
  );
}
