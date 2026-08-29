import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_section_placeholder.dart';

/// Structural boundary for the future membership section.
final class MembershipSection extends StatelessWidget {
  /// Creates the membership skeleton.
  const MembershipSection({super.key});

  @override
  Widget build(BuildContext context) => const LandingSectionPlaceholder(
    desktopMinHeight: 720,
    backgroundColor: AppColors.beigeAccent,
  );
}
