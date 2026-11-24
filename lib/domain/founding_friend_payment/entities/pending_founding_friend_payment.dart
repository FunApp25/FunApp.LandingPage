/// Tab-scoped data required to safely retry Checkout after registration.
final class PendingFoundingFriendPayment {
  /// Creates a pending Checkout attempt.
  const PendingFoundingFriendPayment({
    required this.email,
    required this.attemptId,
    this.sessionId,
    this.createdAt,
    this.checkoutUrl,
  });

  /// Validated registration email used only to prefill hosted Checkout.
  final String email;

  /// Random non-personal correlation identifier reused for Stripe idempotency.
  final String attemptId;

  /// Opaque Checkout identifier, absent until creation succeeds or in old data.
  final String? sessionId;

  /// When the original creation request was started, if recorded.
  final int? createdAt;

  /// Hosted destination returned with [sessionId] by Checkout creation.
  final Uri? checkoutUrl;

  /// Compares snapshots before writing, clearing, or continuing recovery.
  bool matches(PendingFoundingFriendPayment? other) =>
      other != null &&
      email == other.email &&
      attemptId == other.attemptId &&
      sessionId == other.sessionId &&
      createdAt == other.createdAt &&
      checkoutUrl == other.checkoutUrl;
}
