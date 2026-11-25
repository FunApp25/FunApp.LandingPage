import 'dart:convert';

import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:web/web.dart' as web;

const _storageKey = 'funapp.foundingFriend.pendingPayment.v1';

/// Clears pending payment state from the current browser tab.
void clearPendingPayment() {
  try {
    web.window.sessionStorage.removeItem(_storageKey);
  } on Object {
    // Storage can be unavailable under restrictive browser privacy settings.
  }
}

/// Reads pending payment state from the current browser tab.
PendingFoundingFriendPayment? readPendingPayment() {
  try {
    final value = web.window.sessionStorage.getItem(_storageKey);
    if (value == null) {
      return null;
    }
    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) {
      final email = decoded['email'];
      final attemptId = decoded['attemptId'];
      final sessionId = decoded['sessionId'];
      final createdAt = decoded['createdAt'];
      final checkoutUrl = decoded['checkoutUrl'];
      if (email is String &&
          email.trim().isNotEmpty &&
          attemptId is String &&
          _attemptId.hasMatch(attemptId) &&
          (sessionId == null ||
              (sessionId is String && _sessionId.hasMatch(sessionId)))) {
        return PendingFoundingFriendPayment(
          email: email,
          attemptId: attemptId,
          sessionId: sessionId as String?,
          createdAt: createdAt is int ? createdAt : null,
          checkoutUrl: sessionId != null && checkoutUrl is String
              ? _restorableCheckoutUrl(checkoutUrl)
              : null,
        );
      }
    }
  } on Object {
    throw const FormatException('Pending payment storage is unavailable.');
  }
  throw const FormatException('Pending payment storage is invalid.');
}

final _attemptId = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);
final _sessionId = RegExp(
  r'^cs_(?:(?:test|live)_[A-Za-z0-9]{16,240}|mock_[a-z_]+_[0-9a-f]{32})$',
);

Uri? _restorableCheckoutUrl(String value) {
  final url = Uri.tryParse(value);
  if (url == null || !url.hasAuthority || url.userInfo.isNotEmpty) {
    return null;
  }
  final isStripe = url.scheme == 'https' && url.host == 'checkout.stripe.com';
  final loopback = const {'localhost', '127.0.0.1', '::1'}.contains(url.host);
  return isStripe || (loopback && url.origin == Uri.base.origin) ? url : null;
}

/// Saves pending payment state only for the current browser tab.
void savePendingPayment(PendingFoundingFriendPayment payment) {
  try {
    web.window.sessionStorage.setItem(
      _storageKey,
      jsonEncode({
        'email': payment.email,
        'attemptId': payment.attemptId,
        if (payment.sessionId != null) 'sessionId': payment.sessionId,
        if (payment.createdAt != null) 'createdAt': payment.createdAt,
        if (payment.checkoutUrl != null)
          'checkoutUrl': payment.checkoutUrl.toString(),
      }),
    );
  } on Object {
    // The Checkout BLoC reads back the snapshot before continuing.
  }
}
