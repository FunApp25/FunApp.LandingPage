import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/landing_page.dart';

class FunAppLandingPageApp extends StatelessWidget {
  const FunAppLandingPageApp({super.key});

  static const title = 'Fun App Landing Page';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: AppTheme.light,
      home: const LandingPage(),
    );
  }
}
