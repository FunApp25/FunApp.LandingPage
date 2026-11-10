import 'dart:convert';
import 'dart:io';

import 'package:fun_app_landing_page/data/legal/legal_document_repository.dart';
import 'package:fun_app_landing_page/domain/legal/entities/legal_document.dart';
import 'package:fun_app_landing_page/domain/legal/legal_document_repository_interface.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Public responses captured on 10 November 2026, for tests only.
Map<String, dynamic> legalFixture(String name) =>
    jsonDecode(File('test/fixtures/legal/$name.json').readAsStringSync())
        as Map<String, dynamic>;

/// Uses the real decoder with credential-free, deterministic fixture transport.
LegalDocumentRepository fixtureLegalRepository() => LegalDocumentRepository(
  client: MockClient(
    (request) async => http.Response(
      jsonEncode(
        legalFixture(
          request.url.path == '/manifest.json'
              ? 'manifest'
              : request.url.pathSegments[1],
        ),
      ),
      200,
      headers: {'content-type': 'application/json'},
    ),
  ),
);

/// Deterministic page boundary with observable route/retry loads.
final class TestLegalRepository implements LegalDocumentRepositoryInterface {
  TestLegalRepository(this.result);
  final Future<LegalDocument> Function(LegalDocumentId) result;
  int calls = 0;

  @override
  Future<LegalDocument> load(LegalDocumentId id) {
    calls++;
    return result(id);
  }
}
