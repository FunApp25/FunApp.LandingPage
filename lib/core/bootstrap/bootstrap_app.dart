import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fun_app_landing_page/core/config/app_environment.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:google_fonts/google_fonts.dart';

const _manropeLicenseAssetPath = 'assets/fonts/manrope/OFL.txt';
const _instrumentSerifLicenseAssetPath =
    'assets/fonts/instrument_serif/OFL.txt';

/// Configures locally bundled Google Fonts before any typography is resolved.
void configureBundledGoogleFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(_manropeLicenseAssetPath);
    yield LicenseEntryWithLineBreaks(<String>['Manrope'], license);
  });
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      _instrumentSerifLicenseAssetPath,
    );
    yield LicenseEntryWithLineBreaks(<String>['Instrument Serif'], license);
  });
}

/// Configures dependencies and starts the Fun App landing-page application.
Future<void> bootstrapApp({
  required AppEnvironment environment,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  configureBundledGoogleFonts();
  configureDependencies(environment);
  runApp(const FunAppLandingPageApp());
}
