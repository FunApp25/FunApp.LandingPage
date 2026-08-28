import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';

/// Temporary branded surface for the Flutter landing-page scaffold.
final class LandingPage extends StatelessWidget {
  /// Creates the temporary landing page.
  const LandingPage({super.key});

  /// Accessible name for the meaningful Fun App wordmark.
  static const brandSemanticLabel = 'Fun App';

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.spacingMedium),
          child: FunAppLogo(
            width: AppSizes.brandWordmarkWidth,
            semanticLabel: brandSemanticLabel,
            excludeFromSemantics: false,
          ),
        ),
      ),
    ),
  );
}
