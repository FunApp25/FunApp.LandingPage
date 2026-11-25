import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/data/legal/legal_document_repository.dart';
import 'package:fun_app_landing_page/domain/legal/entities/legal_document.dart';
import 'package:fun_app_landing_page/domain/legal/legal_document_repository_interface.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../fixtures/legal/legal_test_repository.dart';

void main() {
  const id = LegalDocumentId.privacyNotice;
  late Map<String, dynamic> manifest;
  late Map<String, dynamic> document;
  late List<http.Request> requests;
  late int jsonStatus;
  late String mime;
  late List<int>? bytes;

  Map<String, dynamic> entry() => (manifest['documents'] as List)
      .cast<Map<String, dynamic>>()
      .singleWhere((entry) => entry['id'] == id.value);
  LegalDocumentRepository repository() => LegalDocumentRepository(
    client: MockClient((request) async {
      requests.add(request);
      expect(request.followRedirects, isFalse);
      expect(request.headers, isEmpty);
      final isManifest = request.url.path == '/manifest.json';
      return http.Response.bytes(
        isManifest
            ? utf8.encode(jsonEncode(manifest))
            : bytes ?? utf8.encode(jsonEncode(document)),
        isManifest ? 200 : jsonStatus,
        headers: {'content-type': isManifest ? 'application/json' : mime},
      );
    }),
  );
  Matcher failure(LegalDocumentFailure kind) => isA<LegalDocumentException>()
      .having((error) => error.failure, 'failure', kind);

  setUp(() {
    manifest = legalFixture('manifest');
    document = legalFixture(id.value);
    requests = [];
    jsonStatus = 200;
    mime = 'application/json';
    bytes = null;
  });

  for (final selected in LegalDocumentId.values) {
    test('resolves ${selected.value} through the real manifest', () async {
      final doc = await fixtureLegalRepository().load(selected);
      final source = legalFixture(selected.value);
      expect(doc.id, selected);
      expect(doc.title, source['title']);
      expect(doc.bodyMarkdown, source['bodyMarkdown']);
      expect(
        doc.pdfUrl.toString(),
        'https://legal.funapp.world/${(manifest['documents'] as List).cast<Map<String, dynamic>>().singleWhere((entry) => entry['id'] == selected.value)['pdfPath']}',
      );
    });
  }

  test(
    'timing uses the explicit offset without selecting another version',
    () async {
      final doc = await repository().load(id);
      expect(
        doc.isFutureEffective(DateTime.parse('2026-11-13T22:59:59Z')),
        isTrue,
      );
      expect(
        doc.isFutureEffective(DateTime.parse('2026-11-13T23:00:00Z')),
        isFalse,
      );
      expect(
        doc.isFutureEffective(DateTime.parse('2026-11-14T00:00:01+01:00')),
        isFalse,
      );
      expect(doc.effectiveAt, '2026-11-14T00:00:00+01:00');
    },
  );

  final invalidManifest = <String, void Function(Map<String, dynamic>)>{
    'unsupported schema': (m) => m['schemaVersion'] = 2,
    'preview mode': (m) => m['mode'] = 'preview',
    'null documents': (m) => m['documents'] = null,
    'wrong documents type': (m) => m['documents'] = <String, dynamic>{},
    'wrong active type': (m) => m['active'] = <dynamic>[],
    'dangling active selection': (m) =>
        (m['active'] as Map)['other'] = {'en-GB': '1.0.0'},
    'incorrect selection': (m) =>
        (m['active'] as Map)[id.value] = {'en-GB': '99.0.0'},
    'duplicate entry': (m) => (m['documents'] as List).add(entry()),
  };
  for (final mutation in invalidManifest.entries) {
    test('rejects ${mutation.key}', () async {
      mutation.value(manifest);
      await expectLater(
        repository().load(id),
        throwsA(failure(LegalDocumentFailure.invalid)),
      );
    });
  }
  test('missing selected document is explicit', () async {
    (manifest['active'] as Map).remove(id.value);
    await expectLater(
      repository().load(id),
      throwsA(failure(LegalDocumentFailure.missing)),
    );
  });
  test('missing manifest entry is explicit', () async {
    (manifest['documents'] as List).remove(entry());
    await expectLater(
      repository().load(id),
      throwsA(failure(LegalDocumentFailure.missing)),
    );
  });
  for (final key in [
    'id',
    'title',
    'version',
    'locale',
    'status',
    'state',
    'publishedAt',
    'effectiveAt',
    'contentSha256',
    'jsonPath',
    'pdfPath',
  ]) {
    for (final bad in [null, 42, '']) {
      test('rejects invalid manifest $key=$bad', () async {
        entry()[key] = bad;
        await expectLater(
          repository().load(id),
          throwsA(failure(LegalDocumentFailure.invalid)),
        );
      });
    }
  }
  for (final change in <String, Object>{
    'status': 'draft',
    'state': 'withdrawn',
    'placeholder': true,
    'version': '01.0.0',
    'contentSha256': 'NOT A DIGEST',
    'jurisdiction': <String>[],
    'supersedes': 'bad',
    'summary': '',
  }.entries) {
    test('rejects invalid ${change.key} value', () async {
      entry()[change.key] = change.value;
      await expectLater(
        repository().load(id),
        throwsA(failure(LegalDocumentFailure.invalid)),
      );
    });
  }
  for (final date in [
    '2026-02-30T00:00:00Z',
    '2026-13-01T00:00:00Z',
    '2026-11-14',
    '2026-11-14T00:00:00',
    '2026-11-14T24:00:00Z',
    '2026-11-14T00:60:00Z',
    '2026-11-14T00:00:00+24:00',
    '2026-11-14T00:00:00+01:60',
  ]) {
    test('rejects impossible or ambiguous timestamp $date', () async {
      entry()['effectiveAt'] = date;
      await expectLater(
        repository().load(id),
        throwsA(failure(LegalDocumentFailure.invalid)),
      );
    });
  }
  for (final path in [
    'https://evil.example/doc.json',
    'https://legal.funapp.world/documents/privacy_notice/3.0.0/en-GB.json',
    '../documents/privacy_notice/3.0.0/en-GB.json',
    'documents/privacy_notice/3.0.0/en-GB.json?x=1',
    'documents/privacy_notice/3.0.0/en-GB.json#x',
    'documents/privacy_notice%2fother/3.0.0/en-GB.json',
    'documents/privacy_notice/3.0.0/en-GB.pdf',
    'javascript:alert(1)',
    '//legal.funapp.world/doc.json',
  ]) {
    test('rejects unsafe or unexpected asset reference $path', () async {
      entry()['jsonPath'] = path;
      await expectLater(
        repository().load(id),
        throwsA(failure(LegalDocumentFailure.invalid)),
      );
      expect(requests, hasLength(1));
    });
  }
  for (final key in [
    'schemaVersion',
    'title',
    'version',
    'locale',
    'status',
    'publishedAt',
    'effectiveAt',
    'contentSha256',
    'bodyMarkdown',
  ]) {
    test('rejects missing document $key', () async {
      document.remove(key);
      await expectLater(
        repository().load(id),
        throwsA(failure(LegalDocumentFailure.invalid)),
      );
    });
  }
  test('metadata mismatch re-resolves once without stale fallback', () async {
    document['title'] = 'Different title';
    await expectLater(
      repository().load(id),
      throwsA(failure(LegalDocumentFailure.invalid)),
    );
    expect(requests, hasLength(4));
  });
  test('hash mismatch is rejected', () async {
    document['contentSha256'] = 'a' * 64;
    await expectLater(
      repository().load(id),
      throwsA(failure(LegalDocumentFailure.invalid)),
    );
  });
  test('JSON missing retries one manifest resolution then fails', () async {
    jsonStatus = 404;
    await expectLater(
      repository().load(id),
      throwsA(failure(LegalDocumentFailure.missing)),
    );
    expect(requests, hasLength(4));
  });
  test('PDF availability is not a dependency of loading legal text', () async {
    await repository().load(id);
    expect(requests, hasLength(2));
    expect(requests.every((r) => r.url.path.endsWith('.json')), isTrue);
  });
  test('wrong MIME and invalid UTF-8 are rejected', () async {
    mime = 'text/html';
    await expectLater(
      repository().load(id),
      throwsA(failure(LegalDocumentFailure.invalid)),
    );
    mime = 'application/json';
    bytes = [0xff];
    await expectLater(
      repository().load(id),
      throwsA(failure(LegalDocumentFailure.invalid)),
    );
  });
  test('oversized body is rejected without truncating clauses', () async {
    bytes = List.filled(1024 * 1024 + 1, 32);
    await expectLater(
      repository().load(id),
      throwsA(failure(LegalDocumentFailure.invalid)),
    );
  });
  test('redirect response is never followed', () async {
    jsonStatus = 302;
    await expectLater(
      repository().load(id),
      throwsA(failure(LegalDocumentFailure.unavailable)),
    );
    expect(requests, hasLength(2));
  });
  test('overall timeout includes response body reads', () async {
    final client = MockClient.streaming(
      (request, body) async => http.StreamedResponse(
        Stream<List<int>>.fromFuture(Completer<List<int>>().future),
        200,
        headers: {'content-type': 'application/json'},
      ),
    );
    await expectLater(
      LegalDocumentRepository(
        client: client,
        timeout: const Duration(milliseconds: 20),
      ).load(id),
      throwsA(failure(LegalDocumentFailure.unavailable)),
    );
  });
  test('new navigation resolves a newly selected version', () async {
    final repo = repository();
    expect((await repo.load(id)).version, legalFixture(id.value)['version']);
    entry()['version'] = '3.1.0';
    entry()['jsonPath'] = 'documents/privacy_notice/3.1.0/en-GB.json';
    entry()['pdfPath'] = 'documents/privacy_notice/3.1.0/en-GB.pdf';
    (manifest['active'] as Map)[id.value] = {'en-GB': '3.1.0'};
    document['version'] = '3.1.0';
    expect((await repo.load(id)).version, '3.1.0');
    expect(requests, hasLength(4));
  });
  test('publication race can recover on the single fresh resolution', () async {
    var count = 0;
    final repo = LegalDocumentRepository(
      client: MockClient((request) async {
        count++;
        return http.Response(
          jsonEncode(
            request.url.path == '/manifest.json' ? manifest : document,
          ),
          count == 2 ? 404 : 200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    expect((await repo.load(id)).title, document['title']);
    expect(count, 4);
  });
  test(
    'rejects unexpected final origins even from an injected transport',
    () async {
      final client = MockClient.streaming(
        (request, body) async => http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode(manifest))),
          200,
          headers: {'content-type': 'application/json'},
          request: http.Request(
            'GET',
            Uri.https('example.org', '/manifest.json'),
          ),
        ),
      );
      await expectLater(
        LegalDocumentRepository(client: client).load(id),
        throwsA(failure(LegalDocumentFailure.invalid)),
      );
    },
  );
  test('manifest size is bounded independently of document size', () async {
    manifest['excess'] = 'x' * (256 * 1024);
    await expectLater(
      repository().load(id),
      throwsA(failure(LegalDocumentFailure.invalid)),
    );
  });
  test('streaming limit applies when Content-Length is absent', () async {
    final client = MockClient.streaming(
      (request, body) async => http.StreamedResponse(
        Stream.fromIterable([
          List.filled(128 * 1024, 32),
          List.filled(128 * 1024 + 1, 32),
        ]),
        200,
        headers: {'content-type': 'application/json'},
      ),
    );
    await expectLater(
      LegalDocumentRepository(client: client).load(id),
      throwsA(failure(LegalDocumentFailure.invalid)),
    );
  });
  test('one deadline covers manifest and document together', () async {
    final client = MockClient((request) async {
      await Future<void>.delayed(const Duration(milliseconds: 35));
      return http.Response(
        jsonEncode(request.url.path == '/manifest.json' ? manifest : document),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    await expectLater(
      LegalDocumentRepository(
        client: client,
        timeout: const Duration(milliseconds: 50),
      ).load(id),
      throwsA(failure(LegalDocumentFailure.unavailable)),
    );
  });
  test('network failure cannot reuse a previous successful load', () async {
    var online = true;
    final client = MockClient((request) async {
      if (!online) throw http.ClientException('unavailable');
      return http.Response(
        jsonEncode(request.url.path == '/manifest.json' ? manifest : document),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repo = LegalDocumentRepository(client: client);
    await repo.load(id);
    online = false;
    await expectLater(
      repo.load(id),
      throwsA(failure(LegalDocumentFailure.unavailable)),
    );
  });
  for (final value in [1.0, '1']) {
    test('schema version must be an integer: $value', () async {
      manifest['schemaVersion'] = value;
      await expectLater(
        repository().load(id),
        throwsA(failure(LegalDocumentFailure.invalid)),
      );
    });
  }
}
