import 'package:fun_app_landing_page/core/bootstrap/bootstrap_app.dart';
import 'package:fun_app_landing_page/core/config/app_environment.dart';

Future<void> main() => bootstrapApp(
  environment: AppEnvironment.production,
);
