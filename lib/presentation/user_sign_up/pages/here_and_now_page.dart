import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_route_controller.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_page.dart';

/// Dedicated Here & Now membership waitlist route.
final class HereAndNowPage extends StatelessWidget {
  /// Creates the UI-only waitlist page.
  const HereAndNowPage({
    this.onSubmit,
    this.showConfirmedSuccess = false,
    this.landingRouteController,
    super.key,
  });

  /// Canonical internal route for the Here & Now waitlist.
  static const routeName = '/here-and-now';

  /// Optional test/development submission seam; absent in production.
  final UserSignUpSubmit? onSubmit;

  /// Injected confirmed-success state for isolated tests and previews only.
  final bool showConfirmedSuccess;

  /// Coordinates navigation back to an existing landing route.
  final LandingRouteController? landingRouteController;

  @override
  Widget build(BuildContext context) => UserSignUpPage(
    experience: UserSignUpExperience.hereAndNow,
    onSubmit: onSubmit,
    showConfirmedSuccess: showConfirmedSuccess,
    landingRouteController: landingRouteController,
  );
}
