import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';

/// Tab-scoped recovery store for a registered but unfinished payment attempt.
abstract interface class PendingFoundingFriendPaymentStoreInterface {
  /// Saves the minimum data required for an explicit payment retry.
  void save(PendingFoundingFriendPayment payment);

  /// Reads a pending attempt. Throws [FormatException] for unreadable storage.
  PendingFoundingFriendPayment? read();

  /// Removes the pending attempt after verified payment.
  void clear();
}

/// Distinguishes a fresh tab from storage that cannot safely be recovered.
extension PendingFoundingFriendPaymentRecovery
    on PendingFoundingFriendPaymentStoreInterface {
  /// Distinguishes an absent record from unreadable storage.
  ({PendingFoundingFriendPayment? payment, bool unavailable})
  readForRecovery() {
    try {
      return (payment: read(), unavailable: false);
    } on FormatException {
      return (payment: null, unavailable: true);
    }
  }
}
