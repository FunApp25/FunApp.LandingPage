import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_section_target.dart';

/// Coordinates an anchor request when a routed page returns to the existing
/// landing-page route.
final class LandingRouteController extends ChangeNotifier {
  LandingSectionTarget? _pendingTarget;

  /// Requests that the active landing page reveal [target].
  void request(LandingSectionTarget target) {
    _pendingTarget = target;
    notifyListeners();
  }

  /// Returns to an existing landing route when possible, or opens one when a
  /// direct URL did not initialize a landing route beneath the current page.
  void openLandingSection(
    BuildContext context,
    LandingSectionTarget target,
  ) {
    final navigator = Navigator.of(context);
    var foundLandingRoute = false;
    navigator.popUntil((route) {
      if (route.settings.name == '/') {
        foundLandingRoute = true;
        return true;
      } else {
        return route.isFirst;
      }
    });

    if (foundLandingRoute) {
      request(target);
    } else {
      navigator.pushNamed('/', arguments: target);
    }
  }

  /// Returns and clears the latest unhandled anchor request.
  LandingSectionTarget? takePendingTarget() {
    final target = _pendingTarget;
    _pendingTarget = null;
    return target;
  }
}
