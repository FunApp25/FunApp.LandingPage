@TestOn('browser')
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/session_pending_founding_friend_payment_store.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:web/web.dart' as web;

void main() {
  const key = 'funapp.foundingFriend.pendingPayment.v1';
  const store = SessionPendingFoundingFriendPaymentStore();
  const pending = PendingFoundingFriendPayment(
    email: 'founder@example.com',
    attemptId: '123e4567-e89b-42d3-a456-426614174000',
    sessionId: 'cs_test_abcdefghijklmnopqrstuvwxyz123456',
  );

  setUp(store.clear);
  tearDown(store.clear);

  test('Session survives a new store instance in the same browser tab', () {
    store.save(pending);
    const reloaded = SessionPendingFoundingFriendPaymentStore();
    expect(reloaded.read()?.sessionId, pending.sessionId);
    expect(reloaded.read()?.attemptId, pending.attemptId);
    expect(reloaded.read()?.email, pending.email);
    expect(jsonDecode(web.window.sessionStorage.getItem(key)!), {
      'email': pending.email,
      'attemptId': pending.attemptId,
      'sessionId': pending.sessionId,
    });
    expect(web.window.localStorage.getItem(key), isNull);
    reloaded.clear();
    expect(store.read(), isNull);
  });

  test('previous v1 storage without Session is still recoverable', () {
    web.window.sessionStorage.setItem(
      key,
      jsonEncode({
        'email': pending.email,
        'attemptId': pending.attemptId,
      }),
    );
    expect(store.read()?.attemptId, pending.attemptId);
    expect(store.read()?.email, pending.email);
    expect(store.read()?.sessionId, isNull);
  });

  test('failed creation stores no guessed Session or extra payment data', () {
    store.save(
      PendingFoundingFriendPayment(
        email: pending.email,
        attemptId: pending.attemptId,
      ),
    );
    expect(jsonDecode(web.window.sessionStorage.getItem(key)!), {
      'email': pending.email,
      'attemptId': pending.attemptId,
    });
    expect(store.read()?.sessionId, isNull);
  });

  for (final value in [
    '{',
    '[]',
    '{"email":42,"attemptId":"attempt"}',
    '{"email":"founder@example.com","attemptId":"attempt","sessionId":42}',
  ]) {
    test('malformed stored data fails safely: $value', () {
      web.window.sessionStorage.setItem(key, value);
      expect(store.read(), isNull);
    });
  }
}
