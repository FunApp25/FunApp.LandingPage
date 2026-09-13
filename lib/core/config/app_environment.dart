/// Compile-time key used to select the application environment.
const appEnvironmentDefineName = 'FUN_APP_ENVIRONMENT';

/// Injectable name for development registrations.
const developmentEnvironmentName = 'development';

/// Injectable name for production registrations.
const productionEnvironmentName = 'production';

/// Supported application environments.
enum AppEnvironment {
  /// Local development with deterministic development data sources.
  development,

  /// Production composition with real-provider data sources.
  production;

  /// Parses a compile-time environment value.
  ///
  /// An absent value is represented by an empty string and defaults to
  /// [development]. Any other unsupported value is a configuration error.
  static AppEnvironment fromValue(String value) {
    if (value.isEmpty || value == developmentEnvironmentName) {
      return AppEnvironment.development;
    } else if (value == productionEnvironmentName) {
      return AppEnvironment.production;
    } else {
      throw FormatException(
        'Unsupported $appEnvironmentDefineName value: "$value". '
        'Expected "$developmentEnvironmentName" or '
        '"$productionEnvironmentName".',
      );
    }
  }
}
