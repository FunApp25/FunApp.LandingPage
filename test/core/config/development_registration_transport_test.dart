import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/config/development_registration_transport.dart';

void main() {
  test('local Worker config accepts loopback HTTP origins', () {
    for (final origin in [
      'http://localhost:8787',
      'http://127.0.0.1:8787',
      'https://[::1]:8787',
    ]) {
      final config = LocalRegistrationWorkerConfig(baseUrl: origin);

      expect(
        config.endpoint('/api/registrations/here-and-now').path,
        '/api/registrations/here-and-now',
      );
    }
  });

  test('local Worker config rejects non-local or ambiguous URLs', () {
    for (final baseUrl in [
      '',
      'https://funapp.world',
      'file:///tmp/worker',
      'http://localhost:8787/path',
      'http://user@localhost:8787',
      'http://localhost:8787?query=true',
      'http://localhost:8787/#fragment',
    ]) {
      expect(
        () => LocalRegistrationWorkerConfig(baseUrl: baseUrl),
        throwsArgumentError,
        reason: baseUrl,
      );
    }
  });

  test('staging Worker config is fixed to the staging origin', () {
    final config = StagingRegistrationWorkerConfig();

    expect(config.baseUri, Uri.parse('https://staging.funapp.world'));
    expect(
      config.endpoint('/api/registrations/founding-friend'),
      Uri.parse(
        'https://staging.funapp.world/api/registrations/founding-friend',
      ),
    );
  });
}
