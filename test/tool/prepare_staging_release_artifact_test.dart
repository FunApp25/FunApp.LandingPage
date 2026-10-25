import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/prepare_staging_release_artifact.dart' as staging;

const _draftLegalAssetPaths = <String>[
  'assets/assets/legal/cookie_banner.md',
  'assets/assets/legal/refund_cancellation_policy.md',
  'assets/assets/legal/terms_of_use.md',
];

void main() {
  late Directory artifactRoot;

  setUp(() {
    exitCode = 0;
    artifactRoot = Directory.systemTemp.createTempSync(
      'funapp-staging-artifact-',
    );
    for (final relativePath in _draftLegalAssetPaths) {
      final file = File('${artifactRoot.path}/$relativePath');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('review only');
    }
    File('${artifactRoot.path}/CNAME').writeAsStringSync('funapp.world\n');
    File('${artifactRoot.path}/index.html').writeAsStringSync('''
<meta name="robots" content="index, follow">
<link rel="canonical" href="https://funapp.world/">
''');
  });

  tearDown(() {
    exitCode = 0;
    artifactRoot.deleteSync(recursive: true);
  });

  test('prepares a Workers Static Assets staging artifact', () {
    staging.main(<String>[artifactRoot.path]);

    expect(exitCode, 0);
    expect(File('${artifactRoot.path}/CNAME').existsSync(), false);
    for (final relativePath in _draftLegalAssetPaths) {
      expect(File('${artifactRoot.path}/$relativePath').existsSync(), false);
    }
    expect(
      File('${artifactRoot.path}/index.html').readAsStringSync(),
      allOf(
        contains('noindex, nofollow, noarchive'),
        contains('https://staging.funapp.world/'),
        isNot(contains('https://funapp.world/')),
      ),
    );
    expect(
      File('${artifactRoot.path}/robots.txt').readAsStringSync(),
      'User-agent: *\nDisallow: /\n',
    );
    expect(
      File('${artifactRoot.path}/_headers').readAsStringSync(),
      '/*\n  X-Robots-Tag: noindex, nofollow, noarchive\n',
    );
  });
}
