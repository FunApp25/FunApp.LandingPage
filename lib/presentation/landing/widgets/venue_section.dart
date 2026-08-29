import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_section_placeholder.dart';

/// Structural boundary for the future venue content.
final class VenueSection extends StatelessWidget {
  /// Creates the venue-section skeleton.
  const VenueSection({super.key});

  @override
  Widget build(BuildContext context) => const LandingSectionPlaceholder(
    desktopMinHeight: 808,
    backgroundColor: AppColors.lightForeground,
  );
}
