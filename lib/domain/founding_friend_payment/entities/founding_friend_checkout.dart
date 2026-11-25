/// A validated hosted-checkout destination returned by the payment service.
final class FoundingFriendCheckout {
  /// Creates a hosted checkout result.
  const FoundingFriendCheckout({
    required this.checkoutUrl,
    required this.sessionId,
  });

  /// Stripe-hosted or explicitly local-mock checkout destination.
  final Uri checkoutUrl;

  /// Opaque Checkout Session identifier used only for status verification.
  final String sessionId;
}
