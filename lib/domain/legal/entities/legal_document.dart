/// Documents explicitly supported by the public website.
enum LegalDocumentId {
  /// Privacy information.
  privacyNotice('privacy_notice'),

  /// Website terms.
  termsOfUse('terms_of_use'),

  /// Founding Friend purchase terms.
  foundingFriendPurchaseTerms('founding_member_purchase_terms'),

  /// Service user agreement.
  userAgreement('user_agreement'),

  /// Service conduct policy.
  acceptableUsePolicy('acceptable_use_policy');

  const LegalDocumentId(this.value);

  /// Stable identifier owned by the legal publisher.
  final String value;
}

/// One validated publication snapshot; selection does not imply applicability.
final class LegalDocument {
  /// Creates a document from a validated publication.
  const LegalDocument({
    required this.id,
    required this.title,
    required this.version,
    required this.locale,
    required this.publishedAt,
    required this.effectiveAt,
    required this.contentSha256,
    required this.bodyMarkdown,
    required this.pdfUrl,
  });

  /// Document identity.
  final LegalDocumentId id;

  /// Authoritative, untranslated title.
  final String title;

  /// Selected published version.
  final String version;

  /// Published language tag.
  final String locale;

  /// Publication timestamp, retaining the publisher's offset.
  final String publishedAt;

  /// Effective timestamp, retaining the publisher's offset.
  final String effectiveAt;

  /// Publisher's canonical content digest, matched to the manifest.
  final String contentSha256;

  /// Exact published Markdown.
  final String bodyMarkdown;

  /// Validated manifest-derived PDF destination.
  final Uri pdfUrl;

  /// Describes timing only; does not select an applicable legal version.
  bool isFutureEffective(DateTime now) =>
      DateTime.parse(effectiveAt).isAfter(now.toUtc());
}
