@TestOn('browser')
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_payment_status_bloc.dart';
import 'package:fun_app_landing_page/core/config/founding_friend_payment_config.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/data_sources/worker_founding_friend_payment_data_source.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/founding_friend_payment_repository.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/session_pending_founding_friend_payment_store.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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

  for (final storedSession in [
    pending.sessionId,
    '${pending.sessionId}Other',
    null,
  ]) {
    test(
      'paid verification respects browser storage ownership: $storedSession',
      () async {
        store.save(
          PendingFoundingFriendPayment(
            email: pending.email,
            attemptId: pending.attemptId,
            sessionId: storedSession,
          ),
        );
        final before = web.window.sessionStorage.getItem(key);
        final client = MockClient(
          (_) async => http.Response(
            jsonEncode({
              'status': 'confirmed',
              'purchaseReference': 'FF-1234567890ABCDEF',
            }),
            200,
          ),
        );
        addTearDown(client.close);
        final bloc = FoundingFriendPaymentStatusBloc(
          repository: FoundingFriendPaymentRepository(
            WorkerFoundingFriendPaymentDataSource(
              client: client,
              config: FoundingFriendPaymentConfig.production(),
            ),
          ),
          pendingStore: store,
        );
        addTearDown(bloc.close);
        final confirmed = bloc.stream.firstWhere(
          (state) => state.phase == FoundingFriendPaymentStatusPhase.confirmed,
        );
        bloc.add(
          FoundingFriendPaymentVerificationRequested(pending.sessionId!),
        );
        await confirmed;
        expect(
          web.window.sessionStorage.getItem(key),
          storedSession == pending.sessionId ? isNull : before,
        );
      },
    );
  }

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
