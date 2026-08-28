import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/landing_page.dart';

/// Root widget for the Fun App landing-page application.
final class FunAppLandingPageApp extends StatelessWidget {
  /// Creates the root landing-page application widget.
  const FunAppLandingPageApp({super.key});

  /// Browser/application title used by the current Flutter shell.
  static const title = 'Fun App Landing Page';

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    theme: appTheme,
    home: const LandingPage(),
  );
}
