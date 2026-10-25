/// Explicit registration transport choices available to development builds.
enum DevelopmentRegistrationTransport {
  /// No registration I/O.
  deferred,

  /// Temporary direct browser-to-HubSpot verification transport.
  directHubSpot,

  /// Local first-party Worker transport backed by deterministic mocks.
  localWorker;

  /// Reads the explicitly selected development transport.
  static DevelopmentRegistrationTransport fromEnvironment() {
    const value = String.fromEnvironment('FUN_APP_REGISTRATION_TRANSPORT');

    if (value.isEmpty || value == 'deferred') {
      return DevelopmentRegistrationTransport.deferred;
    } else if (value == 'direct_hubspot') {
      return DevelopmentRegistrationTransport.directHubSpot;
    } else if (value == 'local_worker') {
      return DevelopmentRegistrationTransport.localWorker;
    } else {
      throw ArgumentError.value(
        value,
        'FUN_APP_REGISTRATION_TRANSPORT',
        'Must be deferred, direct_hubspot, or local_worker.',
      );
    }
  }
}

/// Validated origin for a first-party registration Worker transport.
sealed class RegistrationWorkerConfig {
  const RegistrationWorkerConfig(this.baseUri);

  /// Worker origin.
  final Uri baseUri;

  /// Resolves an exact Worker endpoint path against the configured origin.
  Uri endpoint(String path) => baseUri.resolve(path);
}

/// Validated localhost origin for the development Worker transport.
final class LocalRegistrationWorkerConfig extends RegistrationWorkerConfig {
  /// Creates a local Worker configuration.
  factory LocalRegistrationWorkerConfig({required String baseUrl}) {
    final uri = Uri.tryParse(baseUrl);
    final isLoopbackHost =
        uri?.host == 'localhost' ||
        uri?.host == '127.0.0.1' ||
        uri?.host == '::1';
    final hasRootPath = (uri?.path.isEmpty ?? false) || uri?.path == '/';

    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        !isLoopbackHost ||
        !hasRootPath ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Must be an HTTP(S) localhost origin without a path.',
      );
    }

    return LocalRegistrationWorkerConfig._(uri);
  }

  const LocalRegistrationWorkerConfig._(super.baseUri);

  /// Reads the local Worker base URL supplied at compile time.
  factory LocalRegistrationWorkerConfig.fromEnvironment() {
    const baseUrl = String.fromEnvironment(
      'FUN_APP_REGISTRATION_WORKER_BASE_URL',
    );
    return LocalRegistrationWorkerConfig(baseUrl: baseUrl);
  }
}

/// Fixed hosted origin for the isolated staging registration Worker routes.
final class StagingRegistrationWorkerConfig extends RegistrationWorkerConfig {
  /// Creates the staging configuration without accepting runtime overrides.
  factory StagingRegistrationWorkerConfig() =>
      StagingRegistrationWorkerConfig._(
        Uri.parse('https://staging.funapp.world'),
      );

  const StagingRegistrationWorkerConfig._(super.baseUri);
}
