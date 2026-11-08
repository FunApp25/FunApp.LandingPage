import 'dart:io';

const _legalAssetDirectory = 'assets/assets/legal';
const _productionRobots = 'User-agent: *\nAllow: /\n';
const _stagingHeaders = '/*\n  X-Robots-Tag: noindex, nofollow, noarchive\n';

/// Rejects local legal content and restores production artifact metadata.
void main(List<String> arguments) {
  final artifactRoot = Directory(
    arguments.isEmpty ? 'build/web' : arguments.single,
  );

  if (artifactRoot.existsSync()) {
    if (FileSystemEntity.typeSync(
          '${artifactRoot.path}/$_legalAssetDirectory',
          followLinks: false,
        ) !=
        FileSystemEntityType.notFound) {
      stderr.writeln('Refusing to publish bundled local legal content.');
      exitCode = 1;
    }
    File('${artifactRoot.path}/robots.txt')
        .writeAsStringSync(_productionRobots);
    final headers = File('${artifactRoot.path}/_headers');
    if (headers.existsSync()) {
      if (headers.readAsStringSync() == _stagingHeaders) {
        headers.deleteSync();
      } else {
        stderr.writeln(
          'Refusing to remove an unrecognized production headers file: '
          '${headers.path}',
        );
        exitCode = 1;
      }
    }
  } else {
    stderr.writeln('Missing Flutter Web artifact: ${artifactRoot.path}');
    exitCode = 1;
  }
}
