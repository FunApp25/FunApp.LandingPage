import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/prepare_intermediate_release_artifact.dart' as production;

const _obsoleteLegalAssetPaths = <String>[
  'assets/assets/legal/privacy_notice.md',
  'assets/assets/legal/cookie_banner.md',
  'assets/assets/legal/refund_cancellation_policy.md',
  'assets/assets/legal/terms_of_use.md',
];
const _stagingHeaders = '/*\n  X-Robots-Tag: noindex, nofollow, noarchive\n';

void main() {
  late Directory artifactRoot;

  setUp(() {
    exitCode = 0;
    artifactRoot = Directory.systemTemp.createTempSync(
      'funapp-production-artifact-',
    );
  });

  tearDown(() {
    exitCode = 0;
    artifactRoot.deleteSync(recursive: true);
  });

  test('removes exact staging metadata from a subsequent production build', () {
    File('${artifactRoot.path}/robots.txt').writeAsStringSync(
      'User-agent: *\nDisallow: /\n',
    );
    File('${artifactRoot.path}/_headers').writeAsStringSync(_stagingHeaders);

    production.main(<String>[artifactRoot.path]);

    expect(exitCode, 0);
    expect(
      File('${artifactRoot.path}/robots.txt').readAsStringSync(),
      'User-agent: *\nAllow: /\n',
    );
    expect(File('${artifactRoot.path}/_headers').existsSync(), isFalse);
    for (final relativePath in _obsoleteLegalAssetPaths) {
      expect(File('${artifactRoot.path}/$relativePath').existsSync(), isFalse);
    }
  });

  test('refuses to delete an unrecognized headers file', () {
    final headers = File('${artifactRoot.path}/_headers')
      ..writeAsStringSync('/*\n  Content-Security-Policy: default-src self\n');

    production.main(<String>[artifactRoot.path]);

    expect(exitCode, 1);
    expect(headers.existsSync(), isTrue);
  });
  for (final relativePath in [
    ..._obsoleteLegalAssetPaths,
    'assets/assets/legal/unexpected.md',
  ]) {
    test('rejects $relativePath without deleting it', () {
      final file = File('${artifactRoot.path}/$relativePath');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('inactive reference');

      production.main(<String>[artifactRoot.path]);

      expect(exitCode, 1);
      expect(file.readAsStringSync(), 'inactive reference');
    });
  }
}
