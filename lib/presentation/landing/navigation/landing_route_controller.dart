import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_section_target.dart';

/// Opens landing-page sections from public routed pages.
final class LandingRouteController {
  /// Pushes a landing entry for [target], preserving sequential browser
  /// history instead of collapsing several Flutter routes with `popUntil`.
  void openLandingSection(
    BuildContext context,
    LandingSectionTarget target,
  ) {
    Navigator.of(context).pushNamed('/', arguments: target);
  }
}
