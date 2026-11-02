import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/bootstrap/bootstrap_app.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  testWidgets(
    'bundled Google Fonts disable runtime fetching and expose required assets',
    (tester) async {
      configureBundledGoogleFonts();

      expect(GoogleFonts.config.allowRuntimeFetching, isFalse);

      for (final assetPath in <String>[
        'assets/fonts/manrope/Manrope-Regular.ttf',
        'assets/fonts/manrope/Manrope-Medium.ttf',
        'assets/fonts/manrope/Manrope-SemiBold.ttf',
        'assets/fonts/manrope/Manrope-Bold.ttf',
        'assets/fonts/manrope/OFL.txt',
        'assets/fonts/instrument_serif/InstrumentSerif-Regular.ttf',
        'assets/fonts/instrument_serif/InstrumentSerif-Italic.ttf',
        'assets/fonts/instrument_serif/OFL.txt',
        'assets/fonts/roboto/Roboto-Regular.ttf',
        'assets/fonts/roboto/LICENSE.txt',
      ]) {
        final asset = await rootBundle.load(assetPath);
        expect(asset.lengthInBytes, greaterThan(0), reason: assetPath);
      }

      final manifest = jsonDecode(
        await rootBundle.loadString('FontManifest.json'),
      ) as List<dynamic>;
      expect(
        manifest.cast<Map<String, dynamic>>().singleWhere(
          (family) => family['family'] == 'Roboto',
        ),
        equals({
          'family': 'Roboto',
          'fonts': [
            {'asset': 'assets/fonts/roboto/Roboto-Regular.ttf'},
          ],
        }),
      );
      final license = await rootBundle.loadString(
        'assets/fonts/roboto/LICENSE.txt',
      );
      expect(license, contains('Copyright 2011 Google Inc.'));
      expect(license, contains('Version 2.0, January 2004'));
      expect(license, contains('END OF TERMS AND CONDITIONS'));
    },
  );
}
