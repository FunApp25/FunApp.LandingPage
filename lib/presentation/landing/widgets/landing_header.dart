import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_section_placeholder.dart';

/// Structural boundary for the future landing-page header.
final class LandingHeader extends StatelessWidget {
  /// Creates the landing header skeleton.
  const LandingHeader({super.key});

  @override
  Widget build(BuildContext context) => LandingSectionPlaceholder(
    desktopMinHeight: 70,
    backgroundColor: AppColors.lightForeground,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.desktopPageGutter,
    ),
    maxContentWidth: AppSizes.maxContentWidth,
    child: Align(
      alignment: Alignment.centerLeft,
      child: FunAppLogo(
        width: AppSizes.headerWordmarkWidth,
        semanticLabel: context.l10n.brandName,
        excludeFromSemantics: false,
      ),
    ),
  );
}
