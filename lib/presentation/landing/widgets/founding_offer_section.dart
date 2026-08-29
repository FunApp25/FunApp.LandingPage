import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_section_placeholder.dart';

/// Structural boundary for the future founding offer.
final class FoundingOfferSection extends StatelessWidget {
  /// Creates the founding-offer skeleton.
  const FoundingOfferSection({super.key});

  @override
  Widget build(BuildContext context) => const LandingSectionPlaceholder(
    desktopMinHeight: 292,
    backgroundColor: AppColors.beigeAccent,
  );
}
