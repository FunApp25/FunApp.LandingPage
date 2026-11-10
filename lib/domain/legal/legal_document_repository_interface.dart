import 'package:fun_app_landing_page/domain/legal/entities/legal_document.dart';

/// Read-only publication boundary; each load resolves the manifest afresh.
abstract interface class LegalDocumentRepositoryInterface {
  /// Loads one selected English publication or throws [LegalDocumentException].
  Future<LegalDocument> load(LegalDocumentId id);
}

/// Failure categories without transport details or response bodies.
enum LegalDocumentFailure {
  /// Delivery failed or exceeded its deadline.
  unavailable,

  /// The publication is unsupported or inconsistent.
  invalid,

  /// The requested publication is absent.
  missing,
}

/// Safe failure at the legal publication boundary.
final class LegalDocumentException implements Exception {
  /// Creates a publication failure without exposing response data.
  const LegalDocumentException(this.failure);

  /// Category useful to callers and deterministic tests.
  final LegalDocumentFailure failure;
}
