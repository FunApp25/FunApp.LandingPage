import 'package:flutter/widgets.dart';
import 'package:fun_app_landing_page/core/config/app_environment.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';

/// Configures dependencies and starts the Fun App landing-page application.
Future<void> bootstrapApp({
  required AppEnvironment environment,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies(environment);
  runApp(const FunAppLandingPageApp());
}
