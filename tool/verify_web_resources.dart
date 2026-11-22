import 'dart:convert';
import 'dart:io';

/// Checks packaged resources without depending on generated JavaScript syntax.
void main(List<String> arguments) {
  verifyWebResources(arguments.isEmpty ? 'build/web' : arguments.single);
}

/// Throws when a release artifact is missing required public resources.
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

  final emailLogo = File('$artifactRoot/email/fun-app-logo.png');
  const pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];
  if (!emailLogo.existsSync() ||
      emailLogo.lengthSync() <= pngSignature.length) {
    throw StateError('Missing web resource: email/fun-app-logo.png');
  }
  final logo = emailLogo.openSync();
  try {
    final signature = logo.readSync(pngSignature.length);
    for (var i = 0; i < pngSignature.length; i++) {
      if (signature[i] != pngSignature[i]) {
        throw StateError('The public email logo must be a PNG.');
      }
    }
  } finally {
    logo.closeSync();
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
