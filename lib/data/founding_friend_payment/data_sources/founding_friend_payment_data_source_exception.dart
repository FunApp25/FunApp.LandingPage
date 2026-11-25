/// Base exception for classified payment transport failures.
sealed class FoundingFriendPaymentDataSourceException implements Exception {
  const FoundingFriendPaymentDataSourceException();
}

/// The payment service is temporarily unavailable.
final class FoundingFriendPaymentServiceUnavailableException
    extends FoundingFriendPaymentDataSourceException {
  /// Creates an unavailable-service exception.
  const FoundingFriendPaymentServiceUnavailableException();
}

/// A request or provider response did not satisfy the payment contract.
final class FoundingFriendPaymentRejectedException
    extends FoundingFriendPaymentDataSourceException {
  /// Creates a rejected payment-contract exception.
  const FoundingFriendPaymentRejectedException();
}

/// An unclassified response was received from the payment service.
final class FoundingFriendPaymentUnexpectedException
    extends FoundingFriendPaymentDataSourceException {
  /// Creates an unexpected-response exception.
  const FoundingFriendPaymentUnexpectedException();
}
