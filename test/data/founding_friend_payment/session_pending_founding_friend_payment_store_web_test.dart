@TestOn('browser')
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_checkout_bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_payment_status_bloc.dart';
import 'package:fun_app_landing_page/core/config/founding_friend_payment_config.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/data_sources/worker_founding_friend_payment_data_source.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/founding_friend_payment_repository.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/session_pending_founding_friend_payment_store.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/pending_founding_friend_payment_store_interface.dart';
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
    final checkoutUrl = Uri.https('checkout.stripe.com', '/c/pay/safe');
    final attempt = PendingFoundingFriendPayment(
      email: pending.email,
      attemptId: pending.attemptId,
      sessionId: pending.sessionId,
      createdAt: 1795521600000,
      checkoutUrl: checkoutUrl,
    );
    store.save(attempt);
    const reloaded = SessionPendingFoundingFriendPaymentStore();
    expect(reloaded.read()?.sessionId, pending.sessionId);
    expect(reloaded.read()?.attemptId, pending.attemptId);
    expect(reloaded.read()?.email, pending.email);
    expect(attempt.matches(reloaded.read()), isTrue);
    expect(jsonDecode(web.window.sessionStorage.getItem(key)!), {
      'email': pending.email,
      'attemptId': pending.attemptId,
      'sessionId': pending.sessionId,
      'createdAt': attempt.createdAt,
      'checkoutUrl': checkoutUrl.toString(),
    });
    expect(web.window.localStorage.getItem(key), isNull);
    reloaded.clear();
    expect(store.read(), isNull);
  });

  test('previous v1 storage without Session or timestamp remains readable', () {
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
    expect(store.read()?.createdAt, isNull);
  });

  test(
    'reopened tab verifies its saved open Session without creation',
    () async {
      final checkoutUrl = Uri.https('checkout.stripe.com', '/c/pay/safe');
      store.save(
        PendingFoundingFriendPayment(
          email: pending.email,
          attemptId: pending.attemptId,
          sessionId: pending.sessionId,
          checkoutUrl: checkoutUrl,
        ),
      );
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        return http.Response(
          '{"status":"pending","canResumeCheckout":true}',
          200,
        );
      });
      addTearDown(client.close);
      final bloc = FoundingFriendCheckoutBloc(
        repository: FoundingFriendPaymentRepository(
          WorkerFoundingFriendPaymentDataSource(
            client: client,
            config: FoundingFriendPaymentConfig.production(),
          ),
        ),
        pendingStore: const SessionPendingFoundingFriendPaymentStore(),
      );
      addTearDown(bloc.close);
      final detected = bloc.stream.firstWhere(
        (state) => state.phase == FoundingFriendCheckoutPhase.recoveryRequired,
      );
      bloc.add(const FoundingFriendCheckoutRecoveryOpened());
      await detected;
      expect(requests, isEmpty);
      final ready = bloc.stream.firstWhere(
        (state) => state.phase == FoundingFriendCheckoutPhase.ready,
      );
      bloc.add(const FoundingFriendCheckoutRetryRequested());
      expect((await ready).checkout?.checkoutUrl, checkoutUrl);
      expect(
        requests.single.url.path,
        foundingFriendCheckoutVerificationEndpointPath,
      );
      expect(jsonDecode(requests.single.body), {
        'sessionId': pending.sessionId,
      });
    },
  );

  test('invalid optional metadata still permits read-only verification', () {
    web.window.sessionStorage.setItem(
      key,
      jsonEncode({
        'email': pending.email,
        'attemptId': pending.attemptId,
        'sessionId': pending.sessionId,
        'createdAt': 'yesterday',
        'checkoutUrl': 'https://external.example/c/pay/safe',
      }),
    );
    expect(store.read()?.sessionId, pending.sessionId);
    expect(store.read()?.createdAt, isNull);
    expect(store.read()?.checkoutUrl, isNull);
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
      expect(store.readForRecovery(), (payment: null, unavailable: true));
      expect(web.window.sessionStorage.getItem(key), value);
    });
  }
}
