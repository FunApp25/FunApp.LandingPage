import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/config/founding_friend_payment_config.dart';

void main() {
  test('production uses the same-origin payment route without local mocks', () {
    final config = FoundingFriendPaymentConfig.production();

    expect(config.baseUri, Uri.parse('https://funapp.world'));
    expect(config.allowLocalMockCheckoutUrls, isFalse);
    expect(config.localCheckoutOrigin, isNull);
  });

  test('staging uses its same-origin payment route without local mocks', () {
    final config = FoundingFriendPaymentConfig.staging();

    expect(config.baseUri, Uri.parse('https://staging.funapp.world'));
    expect(config.allowLocalMockCheckoutUrls, isFalse);
    expect(config.localCheckoutOrigin, isNull);
  });

  test('local configuration requires exact loopback origins', () {
    final config = FoundingFriendPaymentConfig(
      baseUrl: 'http://localhost:8788',
      allowLocalMockCheckoutUrls: true,
      localCheckoutOrigin: 'http://localhost:7357',
    );

    expect(
      config.endpoint('/api/founding-friend-payments/checkout-sessions'),
      Uri.parse(
        'http://localhost:8788/api/founding-friend-payments/checkout-sessions',
      ),
    );
  });

  test('rejects insecure non-loopback and malformed local origins', () {
    expect(
      () => FoundingFriendPaymentConfig(
        baseUrl: 'http://payments.example.com',
        allowLocalMockCheckoutUrls: false,
      ),
      throwsArgumentError,
    );
    expect(
      () => FoundingFriendPaymentConfig(
        baseUrl: 'http://localhost:8788/path',
        allowLocalMockCheckoutUrls: true,
        localCheckoutOrigin: 'http://localhost:7357',
      ),
      throwsArgumentError,
    );
    expect(
      () => FoundingFriendPaymentConfig(
        baseUrl: 'http://localhost:8788',
        allowLocalMockCheckoutUrls: true,
        localCheckoutOrigin: 'https://funapp.world',
      ),
      throwsArgumentError,
    );
  });

  test('invalid development payment transport fails closed', () {
    const configured = String.fromEnvironment('FUN_APP_PAYMENT_TRANSPORT');
    if (configured.isEmpty) {
      expect(
        DevelopmentPaymentTransport.fromEnvironment(),
        DevelopmentPaymentTransport.deferred,
      );
    }
  });
}
