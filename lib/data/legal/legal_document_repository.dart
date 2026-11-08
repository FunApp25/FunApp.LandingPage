import 'dart:async';
import 'dart:convert';

import 'package:fun_app_landing_page/domain/legal/entities/legal_document.dart';
import 'package:fun_app_landing_page/domain/legal/legal_document_repository_interface.dart';
import 'package:http/http.dart' as http;

/// Credential-free, bounded reader for the independently published legal site.
final class LegalDocumentRepository
    implements LegalDocumentRepositoryInterface {
  /// Uses browser HTTP caching without persistent offline state.
  factory LegalDocumentRepository({
    required http.Client client,
    Duration timeout = const Duration(seconds: 15),
  }) => LegalDocumentRepository._(client, timeout);

  const LegalDocumentRepository._(this._client, this._timeout);

  final http.Client _client;
  final Duration _timeout;
  static final _manifestUrl = Uri.https('legal.funapp.world', '/manifest.json');
  static final _version = RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$',
  );
  static const _metadata = {
    'id',
    'title',
    'version',
    'locale',
    'status',
    'publishedAt',
    'effectiveAt',
    'contentSha256',
    'jurisdiction',
    'summary',
    'supersedes',
    'changeSummary',
    'placeholder',
  };
  static const _invalid = LegalDocumentException(LegalDocumentFailure.invalid);
  static const _missing = LegalDocumentException(LegalDocumentFailure.missing);

  @override
  Future<LegalDocument> load(LegalDocumentId id) async {
    final abort = Completer<void>();
    final clock = Stopwatch()..start();
    Duration remaining() => _timeout - clock.elapsed;
    final timer = Timer(_timeout, abort.complete);
    try {
      // A deployment can remove an asset between manifest and document reads.
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          return await _load(id, abort.future, remaining);
        } on _PublicationChanged catch (failure) {
          if (attempt == 1) {
            throw failure.failure;
          }
        }
      }
      throw _invalid;
    } on TimeoutException {
      throw const LegalDocumentException(LegalDocumentFailure.unavailable);
    } on http.ClientException {
      throw const LegalDocumentException(LegalDocumentFailure.unavailable);
    } on FormatException {
      throw _invalid;
    } finally {
      timer.cancel();
      if (!abort.isCompleted) {
        abort.complete();
      }
    }
  }

  Future<LegalDocument> _load(
    LegalDocumentId id,
    Future<void> abort,
    Duration Function() remaining,
  ) async {
    final manifest = await _read(_manifestUrl, 256 * 1024, abort, remaining);
    _keys(manifest, const {'schemaVersion', 'mode', 'active', 'documents'});
    if (manifest['schemaVersion'] is! int ||
        manifest['schemaVersion'] != 1 ||
        manifest['mode'] != 'production') {
      throw _invalid;
    }
    final active = _map(manifest['active']);
    for (final locales in active.values) {
      final selections = _map(locales);
      if (selections.isEmpty) {
        throw _invalid;
      }
      selections.values.forEach(_validVersion);
    }
    final versions = active[id.value];
    if (versions == null) {
      throw _missing;
    }
    final selected = _map(versions)['en-GB'];
    if (selected == null) {
      throw _missing;
    }
    _validVersion(selected);
    final entries = manifest['documents'];
    if (entries is! List || entries.isEmpty) {
      throw _invalid;
    }
    final matches = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final value in entries) {
      final entry = _map(value);
      _validateMetadata(entry, manifestEntry: true);
      final identity = '${entry['id']}/${entry['locale']}';
      if (!seen.add(identity) ||
          _map(active[_text(entry['id'])])[entry['locale']] !=
              entry['version']) {
        throw _invalid;
      }
      if (entry['id'] == id.value && entry['locale'] == 'en-GB') {
        matches.add(entry);
      }
    }
    if (matches.isEmpty) {
      throw _missing;
    } else if (matches.length != 1 || matches.single['version'] != selected) {
      throw _invalid;
    }
    for (final selection in active.entries) {
      for (final locale in _map(selection.value).keys) {
        if (!seen.contains('${selection.key}/$locale')) {
          throw _invalid;
        }
      }
    }
    final entry = matches.single;
    final jsonUrl = _asset(entry, 'json');
    final pdfUrl = _asset(entry, 'pdf');
    final document = await _read(jsonUrl, 1024 * 1024, abort, remaining);
    _validateMetadata(document, manifestEntry: false);
    if (document['schemaVersion'] is! int || document['schemaVersion'] != 1) {
      throw _invalid;
    }
    for (final key in _metadata) {
      if (jsonEncode(document[key]) != jsonEncode(entry[key])) {
        throw const _PublicationChanged(_invalid);
      }
    }
    return LegalDocument(
      id: id,
      title: _text(document['title']),
      version: _text(document['version']),
      locale: _text(document['locale']),
      publishedAt: _text(document['publishedAt']),
      effectiveAt: _text(document['effectiveAt']),
      contentSha256: _text(document['contentSha256']),
      bodyMarkdown: _text(document['bodyMarkdown']),
      pdfUrl: pdfUrl,
    );
  }

  Future<Map<String, dynamic>> _read(
    Uri uri,
    int limit,
    Future<void> abort,
    Duration Function() remaining,
  ) async {
    final request = http.AbortableRequest('GET', uri, abortTrigger: abort)
      ..followRedirects = false;
    final response = await _client.send(request).timeout(remaining());
    final iterator = StreamIterator(response.stream);
    try {
      if (response.statusCode == 404 && uri != _manifestUrl) {
        throw const _PublicationChanged(_missing);
      } else if (response.statusCode != 200) {
        throw const LegalDocumentException(LegalDocumentFailure.unavailable);
      }
      if (response.isRedirect ||
          (response.request != null && response.request!.url != uri) ||
          response.headers['content-type']
                  ?.split(';')
                  .first
                  .trim()
                  .toLowerCase() !=
              'application/json' ||
          (response.contentLength != null && response.contentLength! > limit)) {
        throw _invalid;
      }
      final bytes = <int>[];
      while (await iterator.moveNext().timeout(remaining())) {
        if (bytes.length + iterator.current.length > limit) {
          throw _invalid;
        }
        bytes.addAll(iterator.current);
      }
      return _map(jsonDecode(utf8.decode(bytes)));
    } finally {
      await iterator.cancel();
    }
  }

  static Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    } else {
      throw _invalid;
    }
  }

  static String _text(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value;
    } else {
      throw _invalid;
    }
  }

  static void _keys(Map<String, dynamic> value, Set<String> allowed) {
    if (value.keys.any((key) => !allowed.contains(key))) {
      throw _invalid;
    }
  }

  static void _validVersion(Object? value) {
    if (!_version.hasMatch(_text(value))) {
      throw _invalid;
    }
  }

  static void _validateMetadata(
    Map<String, dynamic> value, {
    required bool manifestEntry,
  }) {
    _keys(value, {
      ..._metadata,
      if (manifestEntry) ...{
        'state',
        'jsonPath',
        'pdfPath',
      } else ...{
        'schemaVersion',
        'bodyMarkdown',
      },
    });
    if (!RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$')
            .hasMatch(_text(value['id'])) ||
        value['locale'] != 'en-GB' ||
        value['status'] != 'published' ||
        (manifestEntry && value['state'] != 'active') ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(_text(value['contentSha256']))) {
      throw _invalid;
    }
    _text(value['title']);
    _validVersion(value['version']);
    _timestamp(value['publishedAt']);
    _timestamp(value['effectiveAt']);
    for (final key in const ['summary', 'changeSummary']) {
      if (value.containsKey(key)) {
        _text(value[key]);
      }
    }
    if (value.containsKey('supersedes')) {
      _validVersion(value['supersedes']);
    }
    if (value.containsKey('placeholder') && value['placeholder'] != false) {
      throw _invalid;
    }
    if (value.containsKey('jurisdiction')) {
      final jurisdictions = value['jurisdiction'];
      if (jurisdictions is! List ||
          jurisdictions.isEmpty ||
          jurisdictions.toSet().length != jurisdictions.length) {
        throw _invalid;
      }
      jurisdictions.forEach(_text);
    }
    if (manifestEntry) {
      _asset(value, 'json');
      _asset(value, 'pdf');
    } else {
      _text(value['bodyMarkdown']);
    }
  }

  static Uri _asset(Map<String, dynamic> entry, String extension) {
    final reference = _text(entry['${extension}Path']);
    // Check the supplied path against its identity before resolving it.
    if (reference !=
        'documents/${entry['id']}/${entry['version']}/${entry['locale']}.$extension') {
      throw _invalid;
    }
    final uri = _manifestUrl.resolve(reference);
    if (uri.scheme != 'https' ||
        uri.origin != _manifestUrl.origin ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty ||
        reference.contains('%') ||
        reference.contains('..')) {
      throw _invalid;
    }
    return uri;
  }

  static void _timestamp(Object? value) {
    final text = _text(value);
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d+)?(Z|[+-]\d{2}:\d{2})$',
    ).firstMatch(text);
    if (match == null) {
      throw _invalid;
    }
    final parts = [for (var i = 1; i <= 6; i++) int.parse(match.group(i)!)];
    final date = DateTime.utc(parts[0], parts[1], parts[2]);
    final offset = match.group(7)!;
    if (parts[0] < 1 ||
        date.year != parts[0] ||
        date.month != parts[1] ||
        date.day != parts[2] ||
        parts[3] > 23 ||
        parts[4] > 59 ||
        parts[5] > 59 ||
        (offset != 'Z' &&
            (int.parse(offset.substring(1, 3)) > 23 ||
                int.parse(offset.substring(4, 6)) > 59))) {
      throw _invalid;
    }
    DateTime.parse(text);
  }
}

final class _PublicationChanged implements Exception {
  const _PublicationChanged(this.failure);
  final LegalDocumentException failure;
}
