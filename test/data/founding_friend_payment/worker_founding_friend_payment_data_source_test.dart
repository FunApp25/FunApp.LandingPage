import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/config/founding_friend_payment_config.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/data_sources/founding_friend_payment_data_source_exception.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/data_sources/worker_founding_friend_payment_data_source.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final localConfig = FoundingFriendPaymentConfig(
    baseUrl: 'http://localhost:8788',
    allowLocalMockCheckoutUrls: true,
    localCheckoutOrigin: 'http://localhost:7357',
  );

  test(
    'creates Checkout with only email and stable attempt identifier',
    () async {
      late http.Request captured;
      final source = WorkerFoundingFriendPaymentDataSource(
        client: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'checkoutUrl':
                  'http://localhost:7357/#/founding-friend/payment?session_id='
                  'cs_mock_paid_123e4567e89b42d3a456426614174000',
              'sessionId': 'cs_mock_paid_123e4567e89b42d3a456426614174000',
              'requestId': 'request-id',
            }),
            201,
          );
        }),
        config: localConfig,
      );

      final checkout = await source.createCheckout(
        email: 'founder@example.com',
        attemptId: '123e4567-e89b-42d3-a456-426614174000',
      );

      expect(captured.url.path, foundingFriendCheckoutCreationEndpointPath);
      expect(jsonDecode(captured.body), {
        'email': 'founder@example.com',
        'attemptId': '123e4567-e89b-42d3-a456-426614174000',
      });
      expect(checkout.sessionId, startsWith('cs_mock_paid_'));
    },
  );

  test('rejects an untrusted Checkout redirect URL', () async {
    final source = WorkerFoundingFriendPaymentDataSource(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'checkoutUrl': 'https://evil.example/checkout',
            'sessionId': 'cs_mock_paid_123e4567e89b42d3a456426614174000',
            'requestId': 'request-id',
          }),
          201,
        ),
      ),
      config: localConfig,
    );

    await expectLater(
      source.createCheckout(
        email: 'founder@example.com',
        attemptId: '123e4567-e89b-42d3-a456-426614174000',
      ),
      throwsA(isA<FoundingFriendPaymentUnexpectedException>()),
    );
  });

  test('parses only sanitized paid verification data', () async {
    final source = WorkerFoundingFriendPaymentDataSource(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'status': 'confirmed',
            'purchaseReference': 'FF-1234567890ABCDEF',
            'requestId': 'request-id',
          }),
          200,
        ),
      ),
      config: localConfig,
    );

    final result = await source.verifyCheckout(
      'cs_mock_paid_123e4567e89b42d3a456426614174000',
    );
    expect(result.status, FoundingFriendPaymentStatus.confirmed);
    expect(result.purchaseReference, 'FF-1234567890ABCDEF');
  });

  test('rejects purchase references on non-confirmed results', () async {
    final source = WorkerFoundingFriendPaymentDataSource(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'status': 'pending',
            'purchaseReference': 'FF-1234567890ABCDEF',
            'requestId': 'request-id',
          }),
          200,
        ),
      ),
      config: localConfig,
    );

    await expectLater(
      source.verifyCheckout(
        'cs_mock_pending_123e4567e89b42d3a456426614174000',
      ),
      throwsA(isA<FoundingFriendPaymentUnexpectedException>()),
    );
  });

  for (final capability in [null, false, true]) {
    test(
      'pending redirect capability $capability is explicit and fail-closed',
      () async {
        final source = WorkerFoundingFriendPaymentDataSource(
          client: MockClient(
            (request) async {
              expect(
                request.headers['accept'],
                'application/json; checkout-recovery=1',
              );
              return http.Response(
                jsonEncode({
                  'status': 'pending',
                  'canResumeCheckout': ?capability,
                }),
                200,
              );
            },
          ),
          config: localConfig,
        );
        final result = await source.verifyCheckout(
          'cs_test_abcdefghijklmnopqrstuvwxyz123456',
        );
        expect(result.status, FoundingFriendPaymentStatus.pending);
        expect(result.canResumeCheckout, capability == true);
      },
    );
  }

  for (final body in [
    {'status': 'pending', 'canResumeCheckout': 'true'},
    {'status': 'expired', 'canResumeCheckout': true},
    {'status': 'invalid', 'canResumeCheckout': true},
    {'status': 'refunded', 'canResumeCheckout': true},
    {'status': 'disputed', 'canResumeCheckout': true},
    {
      'status': 'confirmed',
      'purchaseReference': 'FF-1234567890ABCDEF',
      'canResumeCheckout': true,
    },
  ]) {
    test('rejects invalid redirect authorization $body', () async {
      final source = WorkerFoundingFriendPaymentDataSource(
        client: MockClient((_) async => http.Response(jsonEncode(body), 200)),
        config: localConfig,
      );
      await expectLater(
        source.verifyCheckout('cs_test_abcdefghijklmnopqrstuvwxyz123456'),
        throwsA(isA<FoundingFriendPaymentUnexpectedException>()),
      );
    });
  }

  test('verification timeout aborts the request without creation', () async {
    final client = _AbortAwareClient();
    final source = WorkerFoundingFriendPaymentDataSource(
      client: client,
      config: localConfig,
      timeout: const Duration(milliseconds: 1),
    );
    await expectLater(
      source.verifyCheckout('cs_test_abcdefghijklmnopqrstuvwxyz123456'),
      throwsA(isA<FoundingFriendPaymentServiceUnavailableException>()),
    );
    expect(client.abortObserved, isTrue);
  });

  test('maps provider-neutral failures and abortable timeouts', () async {
    final unavailable = WorkerFoundingFriendPaymentDataSource(
      client: MockClient((_) async => http.Response('{}', 503)),
      config: localConfig,
    );
    await expectLater(
      unavailable.createCheckout(
        email: 'founder@example.com',
        attemptId: '123e4567-e89b-42d3-a456-426614174000',
      ),
      throwsA(isA<FoundingFriendPaymentServiceUnavailableException>()),
    );

    final timeoutClient = _AbortAwareClient();
    final timedOut = WorkerFoundingFriendPaymentDataSource(
      client: timeoutClient,
      config: localConfig,
      timeout: const Duration(milliseconds: 1),
    );
    await expectLater(
      timedOut.createCheckout(
        email: 'founder@example.com',
        attemptId: '123e4567-e89b-42d3-a456-426614174000',
      ),
      throwsA(isA<FoundingFriendPaymentServiceUnavailableException>()),
    );
    expect(timeoutClient.abortObserved, isTrue);

    final responseBodyTimeoutClient = _ResponseBodyTimeoutClient();
    final responseBodyTimedOut = WorkerFoundingFriendPaymentDataSource(
      client: responseBodyTimeoutClient,
      config: localConfig,
      timeout: const Duration(milliseconds: 1),
    );
    await expectLater(
      responseBodyTimedOut.createCheckout(
        email: 'founder@example.com',
        attemptId: '123e4567-e89b-42d3-a456-426614174000',
      ),
      throwsA(isA<FoundingFriendPaymentServiceUnavailableException>()),
    );
    await Future<void>.delayed(Duration.zero);
    expect(responseBodyTimeoutClient.abortObserved, isTrue);
  });
}

final class _AbortAwareClient extends http.BaseClient {
  bool abortObserved = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final abortable = request as http.AbortableRequest;
    await abortable.abortTrigger;
    abortObserved = true;
    throw http.RequestAbortedException(request.url);
  }
}

final class _ResponseBodyTimeoutClient extends http.BaseClient {
  bool abortObserved = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final abortable = request as http.AbortableRequest;
    final controller = StreamController<List<int>>();
    unawaited(
      abortable.abortTrigger!.then((_) async {
        abortObserved = true;
        controller.addError(http.RequestAbortedException(request.url));
        await controller.close();
      }),
    );
    return http.StreamedResponse(controller.stream, 201);
  }
}
