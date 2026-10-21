/// Provider-neutral states returned by read-only payment verification.
enum FoundingFriendPaymentStatus {
  /// The configured one-time purchase is paid and otherwise qualifying.
  confirmed,

  /// Checkout exists but payment is not yet available.
  pending,

  /// The Checkout Session expired before verification completed.
  expired,

  /// The payment has been refunded, including a partial refund.
  refunded,

  /// The payment is disputed.
  disputed,

  /// Provider data did not match the configured purchase contract.
  invalid,
}

/// Sanitized result of verifying one opaque Checkout Session identifier.
final class FoundingFriendPaymentVerification {
  /// Creates a payment verification result.
  const FoundingFriendPaymentVerification({
    required this.status,
    this.purchaseReference,
  });

  /// Provider-neutral payment state.
  final FoundingFriendPaymentStatus status;

  /// Server-generated reference, present only for
  /// [FoundingFriendPaymentStatus.confirmed].
  final String? purchaseReference;
}
