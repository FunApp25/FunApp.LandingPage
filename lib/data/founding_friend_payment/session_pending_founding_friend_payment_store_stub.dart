import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';

/// No-op outside a browser runtime.
void clearPendingPayment() {}

/// No pending browser-tab state exists outside a browser runtime.
PendingFoundingFriendPayment? readPendingPayment() => null;

/// No-op outside a browser runtime.
void savePendingPayment(PendingFoundingFriendPayment payment) {}
