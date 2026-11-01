import 'dart:async';
import 'dart:convert';

import 'package:fun_app_landing_page/core/config/founding_friend_payment_config.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/data_sources/founding_friend_payment_data_source_exception.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/data_sources/founding_friend_payment_data_source_interface.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';
import 'package:http/http.dart' as http;

/// Exact first-party Checkout creation endpoint.
const foundingFriendCheckoutCreationEndpointPath =
    '/api/founding-friend-payments/checkout-sessions';

/// Exact first-party Checkout verification endpoint.
const foundingFriendCheckoutVerificationEndpointPath =
    '/api/founding-friend-payments/checkout-sessions/verify';

/// Allows two sequential 10-second Stripe calls plus transport overhead.
const defaultFoundingFriendCheckoutCreationTimeout = Duration(seconds: 25);

/// Allows one 10-second Stripe lookup plus transport overhead.
const defaultFoundingFriendCheckoutVerificationTimeout = Duration(seconds: 15);

/// First-party Worker payment transport with strict response validation.
final class WorkerFoundingFriendPaymentDataSource
    implements FoundingFriendPaymentDataSourceInterface {
  /// Creates a Worker-backed data source.
  factory WorkerFoundingFriendPaymentDataSource({
    required http.Client client,
    required FoundingFriendPaymentConfig config,
    Duration creationTimeout = defaultFoundingFriendCheckoutCreationTimeout,
    Duration verificationTimeout =
        defaultFoundingFriendCheckoutVerificationTimeout,
  }) => WorkerFoundingFriendPaymentDataSource._(
    client,
    config,
    creationTimeout,
    verificationTimeout,
  );

  const WorkerFoundingFriendPaymentDataSource._(
    this._client,
    this._config,
    this.creationTimeout,
    this.verificationTimeout,
  );

  final http.Client _client;
  final FoundingFriendPaymentConfig _config;

  /// Abort deadline for creation, including response-body consumption.
  final Duration creationTimeout;

  /// Independent verification deadline, including response-body consumption.
  final Duration verificationTimeout;

  @override
  Future<FoundingFriendCheckout> createCheckout({
    required String email,
    required String attemptId,
  }) async {
    final body = await _post(
      foundingFriendCheckoutCreationEndpointPath,
      {'email': email, 'attemptId': attemptId},
      expectedStatus: 201,
      timeout: creationTimeout,
    );
    if (!_hasOnlyKeys(body, {'checkoutUrl', 'sessionId', 'requestId'})) {
      throw const FoundingFriendPaymentUnexpectedException();
    }
    final checkoutUrlValue = body['checkoutUrl'];
    final sessionId = body['sessionId'];
    final checkoutUrl = checkoutUrlValue is String
        ? Uri.tryParse(checkoutUrlValue)
        : null;
    if (checkoutUrl == null ||
        sessionId is! String ||
        !_isValidSessionId(sessionId) ||
        !_isAllowedCheckoutUrl(checkoutUrl)) {
      throw const FoundingFriendPaymentUnexpectedException();
    }
    return FoundingFriendCheckout(
      checkoutUrl: checkoutUrl,
      sessionId: sessionId,
    );
  }

  @override
  Future<FoundingFriendPaymentVerification> verifyCheckout(
    String sessionId,
  ) async {
    if (!_isValidSessionId(sessionId)) {
      throw const FoundingFriendPaymentRejectedException();
    }
    final body = await _post(
      foundingFriendCheckoutVerificationEndpointPath,
      {'sessionId': sessionId},
      expectedStatus: 200,
      timeout: verificationTimeout,
    );
    if (!_hasOnlyKeys(body, {
      'status',
      'purchaseReference',
      'requestId',
      'canResumeCheckout',
    })) {
      throw const FoundingFriendPaymentUnexpectedException();
    }
    final status = switch (body['status']) {
      'confirmed' => FoundingFriendPaymentStatus.confirmed,
      'pending' => FoundingFriendPaymentStatus.pending,
      'expired' => FoundingFriendPaymentStatus.expired,
      'refunded' => FoundingFriendPaymentStatus.refunded,
      'disputed' => FoundingFriendPaymentStatus.disputed,
      'invalid' => FoundingFriendPaymentStatus.invalid,
      _ => null,
    };
    final reference = body['purchaseReference'];
    final canResumeCheckout = body['canResumeCheckout'] ?? false;
    final referenceIsValid =
        reference is String && RegExp(r'^FF-[A-F0-9]{16}$').hasMatch(reference);
    if (status == null ||
        canResumeCheckout is! bool ||
        (canResumeCheckout && status != FoundingFriendPaymentStatus.pending) ||
        (status == FoundingFriendPaymentStatus.confirmed &&
            !referenceIsValid) ||
        (status != FoundingFriendPaymentStatus.confirmed &&
            reference != null)) {
      throw const FoundingFriendPaymentUnexpectedException();
    }
    return FoundingFriendPaymentVerification(
      status: status,
      purchaseReference: referenceIsValid ? reference : null,
      canResumeCheckout: canResumeCheckout,
    );
  }

  Future<Map<String, Object?>> _post(
    String path,
    Map<String, String> payload, {
    required int expectedStatus,
    required Duration timeout,
  }) async {
    final abortCompleter = Completer<void>();
    final timer = Timer(timeout, abortCompleter.complete);
    final stopwatch = Stopwatch()..start();
    final request =
        http.AbortableRequest(
            'POST',
            _config.endpoint(path),
            abortTrigger: abortCompleter.future,
          )
          ..headers.addAll({
            'Content-Type': 'application/json',
            if (path == foundingFriendCheckoutVerificationEndpointPath)
              'Accept': 'application/json; checkout-recovery=1',
          })
          ..body = jsonEncode(payload);
    late http.StreamedResponse response;
    try {
      response = await _client.send(request);
      final remaining = timeout - stopwatch.elapsed;
      if (remaining <= Duration.zero) {
        if (!abortCompleter.isCompleted) {
          abortCompleter.complete();
        }
        throw TimeoutException('Payment Worker response deadline exceeded.');
      }
      final responseBody = await response.stream.bytesToString().timeout(
        remaining,
        onTimeout: () {
          if (!abortCompleter.isCompleted) {
            abortCompleter.complete();
          }
          throw TimeoutException(
            'Payment Worker response deadline exceeded.',
          );
        },
      );
      if (response.statusCode == expectedStatus) {
        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        } on FormatException {
          throw const FoundingFriendPaymentUnexpectedException();
        }
        throw const FoundingFriendPaymentUnexpectedException();
      } else if (response.statusCode == 400 ||
          response.statusCode == 422 ||
          response.statusCode == 502) {
        throw const FoundingFriendPaymentRejectedException();
      } else if (response.statusCode == 429 || response.statusCode == 503) {
        throw const FoundingFriendPaymentServiceUnavailableException();
      } else {
        throw const FoundingFriendPaymentUnexpectedException();
      }
    } on http.RequestAbortedException {
      throw const FoundingFriendPaymentServiceUnavailableException();
    } on http.ClientException {
      throw const FoundingFriendPaymentServiceUnavailableException();
    } on TimeoutException {
      throw const FoundingFriendPaymentServiceUnavailableException();
    } finally {
      timer.cancel();
    }
  }

  bool _isAllowedCheckoutUrl(Uri uri) {
    final isStripe = uri.scheme == 'https' && uri.host == 'checkout.stripe.com';
    final isLocalMock =
        _config.allowLocalMockCheckoutUrls &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.origin == _config.localCheckoutOrigin?.origin;
    return uri.hasAuthority &&
        uri.userInfo.isEmpty &&
        (isStripe || isLocalMock);
  }

  bool _isValidSessionId(String value) =>
      RegExp(r'^cs_(?:test|live)_[A-Za-z0-9]{16,240}$').hasMatch(value) ||
      (_config.allowLocalMockCheckoutUrls &&
          RegExp(r'^cs_mock_[a-z_]+_[0-9a-f]{32}$').hasMatch(value));

  bool _hasOnlyKeys(Map<String, Object?> body, Set<String> allowed) =>
      body.keys.every(allowed.contains);
}
