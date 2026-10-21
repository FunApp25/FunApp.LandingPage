/// Explicit development payment transport selection.
enum DevelopmentPaymentTransport {
  /// No payment creation or verification I/O.
  deferred,

  /// First-party localhost Worker backed by deterministic mocks.
  localWorker;

  /// Reads the explicitly selected development transport.
  static DevelopmentPaymentTransport fromEnvironment() {
    const value = String.fromEnvironment('FUN_APP_PAYMENT_TRANSPORT');
    if (value.isEmpty || value == 'deferred') {
      return DevelopmentPaymentTransport.deferred;
    } else if (value == 'local_worker') {
      return DevelopmentPaymentTransport.localWorker;
    } else {
      throw ArgumentError.value(
        value,
        'FUN_APP_PAYMENT_TRANSPORT',
        'Must be deferred or local_worker.',
      );
    }
  }
}

/// Validated first-party payment Worker transport configuration.
final class FoundingFriendPaymentConfig {
  /// Creates a validated Worker configuration.
  factory FoundingFriendPaymentConfig({
    required String baseUrl,
    required bool allowLocalMockCheckoutUrls,
    String? localCheckoutOrigin,
  }) {
    final uri = Uri.tryParse(baseUrl);
    final isLoopback =
        uri?.host == 'localhost' ||
        uri?.host == '127.0.0.1' ||
        uri?.host == '::1';
    final isAllowedScheme =
        uri?.scheme == 'https' || (uri?.scheme == 'http' && isLoopback);
    final hasRootPath = (uri?.path.isEmpty ?? false) || uri?.path == '/';
    final checkoutOrigin = localCheckoutOrigin == null
        ? null
        : Uri.tryParse(localCheckoutOrigin);
    final validCheckoutOrigin =
        checkoutOrigin != null &&
        checkoutOrigin.origin == localCheckoutOrigin &&
        (checkoutOrigin.host == 'localhost' ||
            checkoutOrigin.host == '127.0.0.1' ||
            checkoutOrigin.host == '::1') &&
        (checkoutOrigin.scheme == 'http' || checkoutOrigin.scheme == 'https');
    if (uri == null ||
        !uri.hasAuthority ||
        !isAllowedScheme ||
        !hasRootPath ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (allowLocalMockCheckoutUrls && (!isLoopback || !validCheckoutOrigin)) ||
        (!allowLocalMockCheckoutUrls && localCheckoutOrigin != null)) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Must be an approved HTTPS or localhost origin.',
      );
    }
    return FoundingFriendPaymentConfig._(
      uri,
      allowLocalMockCheckoutUrls,
      checkoutOrigin,
    );
  }

  const FoundingFriendPaymentConfig._(
    this.baseUri,
    this.allowLocalMockCheckoutUrls,
    this.localCheckoutOrigin,
  );

  /// Reads the explicit localhost Worker origin for development.
  factory FoundingFriendPaymentConfig.localFromEnvironment() {
    const baseUrl = String.fromEnvironment(
      'FUN_APP_PAYMENT_WORKER_BASE_URL',
    );
    const checkoutOrigin = String.fromEnvironment(
      'FUN_APP_PUBLIC_APP_ORIGIN',
      defaultValue: 'http://localhost:7357',
    );
    return FoundingFriendPaymentConfig(
      baseUrl: baseUrl,
      allowLocalMockCheckoutUrls: true,
      localCheckoutOrigin: checkoutOrigin,
    );
  }

  /// Uses same-origin production routes without enabling payment creation.
  factory FoundingFriendPaymentConfig.production() =>
      FoundingFriendPaymentConfig(
        baseUrl: 'https://funapp.world',
        allowLocalMockCheckoutUrls: false,
      );

  /// Worker origin.
  final Uri baseUri;

  /// Whether loopback checkout redirects are accepted from a local mock.
  final bool allowLocalMockCheckoutUrls;

  /// Exact Flutter origin accepted only for a local mock redirect.
  final Uri? localCheckoutOrigin;

  /// Resolves an exact endpoint against [baseUri].
  Uri endpoint(String path) => baseUri.resolve(path);
}
