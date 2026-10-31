/// Tab-scoped data required to safely retry Checkout after registration.
final class PendingFoundingFriendPayment {
  /// Creates a pending Checkout attempt.
  const PendingFoundingFriendPayment({
    required this.email,
    required this.attemptId,
    this.sessionId,
  });

  /// Validated registration email used only to prefill hosted Checkout.
  final String email;

  /// Random non-personal correlation identifier reused for Stripe idempotency.
  final String attemptId;

  /// Opaque Checkout identifier, absent until creation succeeds or in old data.
  final String? sessionId;
}
