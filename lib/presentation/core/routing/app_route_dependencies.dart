import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/core/config/release_configuration.dart';
import 'package:fun_app_landing_page/presentation/venue/pages/venue_page.dart';

/// App-level test and development seams consumed by routed pages.
final class AppRouteDependencies extends InheritedWidget {
  /// Creates the dependency scope installed above the router outlet.
  const AppRouteDependencies({
    required super.child,
    required this.releaseConfiguration,
    this.onPrivacyNoticeLaunch,
    this.createVenueLeadFormBloc,
    super.key,
  });

  /// Build-time release features available to routed presentation.
  final ReleaseConfiguration releaseConfiguration;

  /// Optional browser-launch override for presentation tests.
  final ValueChanged<Uri>? onPrivacyNoticeLaunch;

  /// Optional Venue form BLoC factory override for presentation tests.
  final VenueLeadFormBlocFactory? createVenueLeadFormBloc;

  /// Returns the nearest route dependency scope, when installed.
  static AppRouteDependencies? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppRouteDependencies>();

  @override
  bool updateShouldNotify(AppRouteDependencies oldWidget) =>
      releaseConfiguration != oldWidget.releaseConfiguration ||
      onPrivacyNoticeLaunch != oldWidget.onPrivacyNoticeLaunch ||
      createVenueLeadFormBloc != oldWidget.createVenueLeadFormBloc;
}
