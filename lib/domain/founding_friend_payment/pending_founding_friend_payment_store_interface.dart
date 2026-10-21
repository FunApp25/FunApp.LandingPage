import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';

/// Tab-scoped recovery store for a registered but unfinished payment attempt.
abstract interface class PendingFoundingFriendPaymentStoreInterface {
  /// Saves the minimum data required for an explicit payment retry.
  void save(PendingFoundingFriendPayment payment);

  /// Reads a pending attempt from the current browser tab.
  PendingFoundingFriendPayment? read();

  /// Removes the pending attempt after verified payment.
  void clear();
}
