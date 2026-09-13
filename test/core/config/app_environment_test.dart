import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/config/app_environment.dart';

void main() {
  test('absent environment value defaults to development', () {
    expect(AppEnvironment.fromValue(''), AppEnvironment.development);
  });

  test('parses the explicit development environment', () {
    expect(
      AppEnvironment.fromValue(developmentEnvironmentName),
      AppEnvironment.development,
    );
  });

  test('parses the explicit production environment', () {
    expect(
      AppEnvironment.fromValue(productionEnvironmentName),
      AppEnvironment.production,
    );
  });

  test('rejects an unknown non-empty environment value', () {
    expect(
      () => AppEnvironment.fromValue('prodution'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains(appEnvironmentDefineName),
        ),
      ),
    );
  });
}
