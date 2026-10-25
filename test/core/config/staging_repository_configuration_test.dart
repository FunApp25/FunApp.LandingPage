import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Wrangler keeps production and staging Worker identities isolated', () {
    final registration = _readJsonc(
      'cloudflare/venue-interest-worker/wrangler.jsonc',
    );
    final payment = _readJsonc(
      'cloudflare/founding-friend-payment-worker/wrangler.jsonc',
    );
    final registrationStaging = _stagingEnvironment(registration);
    final paymentStaging = _stagingEnvironment(payment);

    expect(registration['name'], 'funapp-venue-interest');
    expect(registration['main'], 'src/index.ts');
    expect(
      registrationStaging['name'],
      'funapp-venue-interest-staging',
    );
    expect(registrationStaging['main'], 'src/staging.ts');
    expect(payment['name'], 'funapp-founding-friend-payment');
    expect(payment['main'], 'src/index.ts');
    expect(
      paymentStaging['name'],
      'funapp-founding-friend-payment-staging',
    );
    expect(paymentStaging['main'], 'src/staging.ts');

    final registrationVars = _objectMap(registrationStaging['vars']);
    expect(registrationVars, {
      'STAGING_REGISTRATION_MOCK_ENABLED': 'true',
    });
    expect(
      registrationVars.keys.any((key) => key.startsWith('HUBSPOT_')),
      false,
    );

    final paymentVars = _objectMap(paymentStaging['vars']);
    expect(paymentVars['PAYMENT_CREATION_ENABLED'], 'false');
    expect(paymentVars['STRIPE_EXPECTED_LIVEMODE'], 'false');
    expect(
      paymentVars['PUBLIC_APP_ORIGIN'],
      'https://staging.funapp.world',
    );
    expect(paymentVars.containsKey('STRIPE_SECRET_KEY'), false);
    expect(paymentVars.containsKey('PURCHASE_REFERENCE_SECRET'), false);
    for (final config in [
      registration,
      registrationStaging,
      payment,
      paymentStaging,
    ]) {
      expect(config.containsKey('route'), false);
      expect(config.containsKey('routes'), false);
    }

    final namespaces = <String>{
      _rateLimitNamespace(registration),
      _rateLimitNamespace(registrationStaging),
      _rateLimitNamespace(payment),
      _rateLimitNamespace(paymentStaging),
    };
    expect(namespaces, hasLength(4));
  });

  test('production deploy workflows explicitly select root Worker configs', () {
    for (final path in [
      '.github/workflows/deploy-venue-interest-worker.yml',
      '.github/workflows/deploy-founding-friend-payment-worker.yml',
    ]) {
      final workflow = File(path).readAsStringSync();

      expect(workflow, contains('environment: production'), reason: path);
      expect(workflow, contains('command: deploy --env=""'), reason: path);
      expect(workflow, isNot(contains('command: deploy --env staging')));
    }
  });

  test('local launch modes retain isolated and combined mocked Workers', () {
    final launch = _readJsonc('.vscode/launch.json');
    final configurations = (launch['configurations']! as List<dynamic>)
        .map(_objectMap)
        .toList();
    final registrationOnly = configurations.singleWhere(
      (configuration) =>
          configuration['name'] ==
          'Fun App Landing — Development (Local Registration Worker)',
    );
    final bothWorkers = configurations.singleWhere(
      (configuration) =>
          configuration['name'] ==
          'Fun App Landing — Development (Local Workers)',
    );
    final registrationArgs = (registrationOnly['toolArgs']! as List<dynamic>)
        .cast<String>();
    final bothWorkerArgs = (bothWorkers['toolArgs']! as List<dynamic>)
        .cast<String>();

    expect(
      registrationArgs,
      contains('--dart-define=FUN_APP_REGISTRATION_TRANSPORT=local_worker'),
    );
    expect(
      registrationArgs,
      isNot(contains('--dart-define=FUN_APP_PAYMENT_TRANSPORT=local_worker')),
    );
    expect(
      bothWorkerArgs,
      contains('--dart-define=FUN_APP_REGISTRATION_TRANSPORT=local_worker'),
    );
    expect(
      bothWorkerArgs,
      contains('--dart-define=FUN_APP_PAYMENT_TRANSPORT=local_worker'),
    );
  });

  test('staging workflows are manual-only and hard-code staging targets', () {
    final expectations = <String, List<String>>{
      '.github/workflows/deploy-staging-site.yml': [
        'workflow_dispatch:',
        'environment: staging',
        '--project-name=funapp-landing-staging',
        '-t lib/main_staging.dart',
      ],
      '.github/workflows/deploy-staging-registration-worker.yml': [
        'workflow_dispatch:',
        'environment: staging',
        'command: deploy --env staging',
        'funapp-venue-interest-staging',
      ],
      '.github/workflows/deploy-staging-payment-worker.yml': [
        'workflow_dispatch:',
        'environment: staging',
        'command: deploy --env staging',
        "STRIPE_EXPECTED_LIVEMODE: 'false'",
        'STRIPE_SANDBOX_RESTRICTED_KEY',
      ],
    };

    for (final entry in expectations.entries) {
      final workflow = File(entry.key).readAsStringSync();
      for (final expected in entry.value) {
        expect(workflow, contains(expected), reason: entry.key);
      }
      expect(
        workflow,
        isNot(matches(RegExp(r'^\s*(push|pull_request):', multiLine: true))),
        reason: entry.key,
      );
      expect(workflow, isNot(contains('environment: production')));
      expect(workflow, isNot(contains('funapp.world/api/venue-interest')));
    }
  });

  test('staging artifact preparation removes production host metadata', () {
    final tool = File(
      'tool/prepare_staging_release_artifact.dart',
    ).readAsStringSync();

    expect(tool, contains('CNAME'));
    expect(tool, contains('https://staging.funapp.world/'));
    expect(tool, contains('noindex, nofollow, noarchive'));
    expect(tool, contains('Disallow: /'));
    expect(tool, contains('X-Robots-Tag'));
  });
}

Map<String, Object?> _readJsonc(String path) {
  final source = File(path).readAsLinesSync().where(
    (line) => !line.trimLeft().startsWith('//'),
  );
  return (jsonDecode(source.join('\n')) as Map<String, dynamic>)
      .cast<String, Object?>();
}

Map<String, Object?> _stagingEnvironment(Map<String, Object?> config) =>
    _objectMap(_objectMap(config['env'])['staging']);

Map<String, Object?> _objectMap(Object? value) =>
    (value! as Map<String, dynamic>).cast<String, Object?>();

String _rateLimitNamespace(Map<String, Object?> config) {
  final rateLimits = config['ratelimits']! as List<dynamic>;
  return _objectMap(rateLimits.single)['namespace_id']! as String;
}
