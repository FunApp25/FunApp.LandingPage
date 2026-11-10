import 'dart:io';

const _legalAssetDirectory = 'assets/assets/legal';
const _productionRobotsMeta = '<meta name="robots" content="index, follow">';
const _stagingRobotsMeta =
    '<meta name="robots" content="noindex, nofollow, noarchive">';
const _productionCanonical =
    '<link rel="canonical" href="https://funapp.world/">';
const _stagingCanonical =
    '<link rel="canonical" href="https://staging.funapp.world/">';

/// Removes production-only host declarations and marks a staging build as
/// non-indexable. Cloudflare Access remains the actual access-control layer.
void main(List<String> arguments) {
  final artifactRoot = Directory(
    arguments.isEmpty ? 'build/web' : arguments.single,
  );

  if (artifactRoot.existsSync()) {
    _rejectLocalLegalAssets(artifactRoot);
    _removeProductionCustomDomain(artifactRoot);
    _prepareIndex(artifactRoot);
    _prepareRobots(artifactRoot);
    _prepareHeaders(artifactRoot);
  } else {
    stderr.writeln('Missing Flutter Web artifact: ${artifactRoot.path}');
    exitCode = 1;
  }
}

void _rejectLocalLegalAssets(Directory artifactRoot) {
  if (FileSystemEntity.typeSync(
        '${artifactRoot.path}/$_legalAssetDirectory',
        followLinks: false,
      ) !=
      FileSystemEntityType.notFound) {
    stderr.writeln('Refusing to publish bundled local legal content.');
    exitCode = 1;
  }
}

void _removeProductionCustomDomain(Directory artifactRoot) {
  final cname = File('${artifactRoot.path}/CNAME');
  if (cname.existsSync()) {
    cname.deleteSync();
  } else {
    stderr.writeln('Missing expected production CNAME: ${cname.path}');
    exitCode = 1;
  }
}

void _prepareIndex(Directory artifactRoot) {
  final index = File('${artifactRoot.path}/index.html');
  if (index.existsSync()) {
    final source = index.readAsStringSync();
    if (source.contains(_productionRobotsMeta) &&
        source.contains(_productionCanonical)) {
      index.writeAsStringSync(
        source
            .replaceFirst(_productionRobotsMeta, _stagingRobotsMeta)
            .replaceFirst(_productionCanonical, _stagingCanonical),
      );
    } else {
      stderr.writeln(
        'Staging index preparation could not find the production metadata.',
      );
      exitCode = 1;
    }
  } else {
    stderr.writeln('Missing staging index: ${index.path}');
    exitCode = 1;
  }
}

void _prepareRobots(Directory artifactRoot) {
  File('${artifactRoot.path}/robots.txt').writeAsStringSync(
    'User-agent: *\nDisallow: /\n',
  );
}

void _prepareHeaders(Directory artifactRoot) {
  File('${artifactRoot.path}/_headers').writeAsStringSync(
    '/*\n  X-Robots-Tag: noindex, nofollow, noarchive\n',
  );
}
