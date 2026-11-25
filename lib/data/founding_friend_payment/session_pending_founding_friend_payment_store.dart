// Descriptive conditional-import filenames keep the browser boundary explicit.
// ignore_for_file: lines_longer_than_80_chars

import 'package:fun_app_landing_page/data/founding_friend_payment/session_pending_founding_friend_payment_store_stub.dart'
    if (dart.library.js_interop) 'session_pending_founding_friend_payment_store_web.dart'
    as implementation;
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/pending_founding_friend_payment_store_interface.dart';

/// Browser-tab-scoped pending payment recovery store.
final class SessionPendingFoundingFriendPaymentStore
    implements PendingFoundingFriendPaymentStoreInterface {
  /// Creates the store.
  const SessionPendingFoundingFriendPaymentStore();

  @override
  void clear() => implementation.clearPendingPayment();

  @override
  PendingFoundingFriendPayment? read() => implementation.readPendingPayment();

  @override
  void save(PendingFoundingFriendPayment payment) =>
      implementation.savePendingPayment(payment);
}
