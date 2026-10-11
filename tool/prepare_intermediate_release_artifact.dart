import 'dart:io';

const _draftLegalAssetPaths = <String>[
  'assets/assets/legal/cookie_banner.md',
  'assets/assets/legal/refund_cancellation_policy.md',
  'assets/assets/legal/terms_of_use.md',
];

/// Removes review-only legal documents from a compiled production artifact.
void main(List<String> arguments) {
  final artifactRoot = Directory(
    arguments.isEmpty ? 'build/web' : arguments.single,
  );

  if (artifactRoot.existsSync()) {
    for (final relativePath in _draftLegalAssetPaths) {
      final file = File('${artifactRoot.path}/$relativePath');
      if (file.existsSync()) {
        file.deleteSync();
      } else {
        stderr.writeln('Missing expected draft legal asset: ${file.path}');
        exitCode = 1;
      }
    }
  } else {
    stderr.writeln('Missing Flutter Web artifact: ${artifactRoot.path}');
    exitCode = 1;
  }
}
