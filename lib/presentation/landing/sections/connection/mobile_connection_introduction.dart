import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/connection/connection_body.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/connection/connection_title.dart';

/// Dedicated centered Connection introduction below the mobile breakpoint.
final class MobileConnectionIntroduction extends StatelessWidget {
  /// Creates the mobile Connection introduction.
  const MobileConnectionIntroduction({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    key: Key('connectionMobileLayout'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ConnectionTitle(
        headingSize: 32,
        headingLineHeight: 42,
        centered: true,
      ),
      SizedBox(height: 12),
      ConnectionBody(textAlign: TextAlign.center),
    ],
  );
}
