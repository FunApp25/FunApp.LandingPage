import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/verify_web_resources.dart';

void main() {
  late Directory artifact;

  setUp(() {
    artifact = Directory.systemTemp.createTempSync('web-resources-');
    for (final path in [
      'canvaskit/canvaskit.js',
      'canvaskit/canvaskit.wasm',
      'canvaskit/chromium/canvaskit.js',
      'canvaskit/chromium/canvaskit.wasm',
      'assets/assets/fonts/roboto/Roboto-Regular.ttf',
      'assets/assets/fonts/roboto/LICENSE.txt',
      'assets/assets/fonts/manrope/OFL.txt',
      'assets/assets/fonts/instrument_serif/OFL.txt',
    ]) {
      final file = File('${artifact.path}/$path');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('fixture');
    }
    File('${artifact.path}/assets/FontManifest.json').writeAsStringSync(
      jsonEncode([
        {
          'family': 'Roboto',
          'fonts': [
            {'asset': 'assets/fonts/roboto/Roboto-Regular.ttf'},
          ],
        },
      ]),
    );
  });

  tearDown(() => artifact.deleteSync(recursive: true));

  test('accepts packaged renderer variants and declared Roboto', () {
    expect(() => verifyWebResources(artifact.path), returnsNormally);
  });

  test('rejects a missing renderer variant', () {
    File('${artifact.path}/canvaskit/chromium/canvaskit.wasm').deleteSync();
    expect(() => verifyWebResources(artifact.path), throwsStateError);
  });

  test('rejects a missing default font or license', () {
    for (final path in ['Roboto-Regular.ttf', 'LICENSE.txt']) {
      final file = File('${artifact.path}/assets/assets/fonts/roboto/$path')
        ..writeAsBytesSync([]);
      expect(() => verifyWebResources(artifact.path), throwsStateError);
      file.writeAsStringSync('fixture');
    }
  });

  test('rejects an undeclared or remote default font', () {
    final manifest = File('${artifact.path}/assets/FontManifest.json')
      ..writeAsStringSync('[]');
    expect(() => verifyWebResources(artifact.path), throwsStateError);
    manifest.writeAsStringSync(
      '[{"family":"Roboto","fonts":[{"asset":"https://example.org/font"}]}]',
    );
    expect(() => verifyWebResources(artifact.path), throwsStateError);
  });
}
