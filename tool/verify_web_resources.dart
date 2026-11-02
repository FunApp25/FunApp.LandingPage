import 'dart:convert';
import 'dart:io';

/// Checks packaged resources without depending on generated JavaScript syntax.
void main(List<String> arguments) {
  verifyWebResources(arguments.isEmpty ? 'build/web' : arguments.single);
}

/// Throws when a release artifact is missing its local renderer or fonts.
void verifyWebResources(String artifactRoot) {
  for (final path in <String>[
    'canvaskit/canvaskit.js',
    'canvaskit/canvaskit.wasm',
    'canvaskit/chromium/canvaskit.js',
    'canvaskit/chromium/canvaskit.wasm',
    'assets/assets/fonts/roboto/Roboto-Regular.ttf',
    'assets/assets/fonts/roboto/LICENSE.txt',
    'assets/assets/fonts/manrope/OFL.txt',
    'assets/assets/fonts/instrument_serif/OFL.txt',
  ]) {
    final file = File('$artifactRoot/$path');
    if (!file.existsSync() || file.lengthSync() == 0) {
      throw StateError('Missing web resource: $path');
    }
  }

  final manifest = jsonDecode(
    File('$artifactRoot/assets/FontManifest.json').readAsStringSync(),
  ) as List<dynamic>;
  final roboto = manifest.cast<Map<String, dynamic>>().singleWhere(
    (family) => family['family'] == 'Roboto',
  );
  final fonts = roboto['fonts'] as List<dynamic>;
  if (fonts.length != 1 ||
      (fonts.single as Map<String, dynamic>)['asset'] !=
          'assets/fonts/roboto/Roboto-Regular.ttf') {
    throw StateError('Roboto must use the declared local font asset.');
  }
}
