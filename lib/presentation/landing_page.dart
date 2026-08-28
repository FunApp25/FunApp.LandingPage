import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';

/// Temporary branded surface for the Flutter landing-page scaffold.
final class LandingPage extends StatelessWidget {
  /// Creates the temporary landing page.
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingMedium),
          child: FunAppLogo(
            width: AppSizes.brandWordmarkWidth,
            semanticLabel: context.l10n.brandName,
            excludeFromSemantics: false,
          ),
        ),
      ),
    ),
  );
}
