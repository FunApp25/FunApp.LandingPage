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
      if (email is String && attemptId is String) {
        return PendingFoundingFriendPayment(
          email: email,
          attemptId: attemptId,
        );
      }
    }
  } on Object {
    clearPendingPayment();
  }
  return null;
}

/// Saves pending payment state only for the current browser tab.
void savePendingPayment(PendingFoundingFriendPayment payment) {
  try {
    web.window.sessionStorage.setItem(
      _storageKey,
      jsonEncode({'email': payment.email, 'attemptId': payment.attemptId}),
    );
  } on Object {
    // The active checkout can continue without browser retry correlation.
  }
}
