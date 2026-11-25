import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/config/hubspot_registration_forms_config.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/hubspot_user_registration_data_source.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_exception.dart';
import 'package:fun_app_landing_page/data/user_registration/models/founding_friend_registration_dto.dart';
import 'package:fun_app_landing_page/data/user_registration/models/here_and_now_registration_dto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'posts the exact Here & Now HubSpot payload without consent metadata',
    () async {
      late http.Request capturedRequest;
      final dataSource = _dataSource(
        MockClient((request) async {
          capturedRequest = request;
          return http.Response('{not parsed', 200);
        }),
      );

      await dataSource.submitHereAndNowRegistration(_hereAndNowDto);

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url, _hereAndNowEndpoint);
      expect(capturedRequest.headers['content-type'], 'application/json');
      expect(capturedRequest.headers, isNot(contains('authorization')));
      expect(
        jsonDecode(capturedRequest.body),
        {
          'fields': [
            {'name': 'firstname', 'value': 'Alex'},
            {'name': 'lastname', 'value': 'Morgan'},
            {'name': 'email', 'value': 'alex@example.com'},
            {'name': 'age', 'value': '29'},
            {'name': 'marketing_consent', 'value': 'false'},
          ],
        },
      );
      expect(capturedRequest.body, isNot(contains('legalConsentOptions')));
    },
  );

  test('posts the full Founding Friend HubSpot payload', () async {
    late http.Request capturedRequest;
    final dataSource = _dataSource(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 200);
      }),
    );

    await dataSource.submitFoundingFriendRegistration(_foundingFriendDto);

    expect(capturedRequest.url, _foundingFriendEndpoint);
    expect(
      jsonDecode(capturedRequest.body),
      {
        'fields': [
          {'name': 'firstname', 'value': 'Taylor'},
          {'name': 'lastname', 'value': 'Jones'},
          {'name': 'email', 'value': 'taylor@example.com'},
          {'name': 'age', 'value': '31'},
          {'name': 'gender', 'value': 'Non-binary'},
          {'name': 'usage_reason', 'value': 'Meeting people nearby'},
          {'name': 'marketing_consent', 'value': 'true'},
          {'name': 'country', 'value': 'United Kingdom'},
        ],
      },
    );
  });

  for (final gender in const [
    'Man',
    'Woman',
    'Non-binary',
    'Prefer not to answer',
  ]) {
    test('maps accepted gender enumeration value $gender unchanged', () async {
      late http.Request capturedRequest;
      final dataSource = _dataSource(
        MockClient((request) async {
          capturedRequest = request;
          return http.Response('', 200);
        }),
      );

      await dataSource.submitHereAndNowRegistration(
        HereAndNowRegistrationDto(
          firstName: 'Alex',
          lastName: 'Morgan',
          email: 'alex@example.com',
          age: 29,
          gender: gender,
          usageReason: null,
          marketingConsent: false,
        ),
      );

      expect(capturedRequest.body, contains('"value":"$gender"'));
    });
  }

  test('rejects an unaccepted gender value before HTTP', () async {
    var calls = 0;
    final dataSource = _dataSource(
      MockClient((_) async {
        calls += 1;
        return http.Response('', 200);
      }),
    );

    expect(
      () => dataSource.submitHereAndNowRegistration(
        const HereAndNowRegistrationDto(
          firstName: 'Alex',
          lastName: 'Morgan',
          email: 'alex@example.com',
          age: 29,
          gender: 'Other',
          usageReason: null,
          marketingConsent: false,
        ),
      ),
      throwsFormatException,
    );
    expect(calls, 0);
  });

  final responseCases = <(String, int, Matcher)>[
    (
      '400 validation rejection',
      400,
      isA<UserRegistrationSubmissionRejectedException>(),
    ),
    (
      '429 rate limit',
      429,
      isA<UserRegistrationServiceUnavailableException>(),
    ),
    (
      '500 provider failure',
      500,
      isA<UserRegistrationServiceUnavailableException>(),
    ),
    (
      '503 provider failure',
      503,
      isA<UserRegistrationServiceUnavailableException>(),
    ),
    (
      'unexpected response',
      418,
      isA<UserRegistrationUnexpectedDataSourceException>(),
    ),
  ];

  for (final (name, statusCode, matcher) in responseCases) {
    test('classifies $name without parsing its body', () async {
      final dataSource = _dataSource(
        MockClient((_) async => http.Response('{not json', statusCode)),
      );

      await expectLater(
        dataSource.submitHereAndNowRegistration(_hereAndNowDto),
        throwsA(matcher),
      );
    });
  }

  test('classifies a transport failure as unavailable', () async {
    final dataSource = _dataSource(
      MockClient((request) async {
        throw http.ClientException('Synthetic failure.', request.url);
      }),
    );

    await expectLater(
      dataSource.submitHereAndNowRegistration(_hereAndNowDto),
      throwsA(isA<UserRegistrationServiceUnavailableException>()),
    );
  });

  test('aborts a timed-out request and reports unavailable', () async {
    final client = _NeverCompletingClient();
    final dataSource = _dataSource(
      client,
      submissionTimeout: const Duration(milliseconds: 10),
    );

    await expectLater(
      dataSource.submitHereAndNowRegistration(_hereAndNowDto),
      throwsA(isA<UserRegistrationServiceUnavailableException>()),
    );
    expect(client.wasAborted, isTrue);
  });
}

final _config = HubSpotRegistrationFormsConfig(
  portalId: '149114580',
  hereAndNowFormGuid: '3284e6bc-e3a2-4d2e-9e21-684399126f3b',
  foundingFriendFormGuid: '39f027d9-e786-4768-b532-54ed44e1f718',
);
final Uri _hereAndNowEndpoint = _config.submissionEndpoint(
  _config.hereAndNowFormGuid,
);
final Uri _foundingFriendEndpoint = _config.submissionEndpoint(
  _config.foundingFriendFormGuid,
);

const _hereAndNowDto = HereAndNowRegistrationDto(
  firstName: 'Alex',
  lastName: 'Morgan',
  email: 'alex@example.com',
  age: 29,
  gender: null,
  usageReason: null,
  marketingConsent: false,
);

const _foundingFriendDto = FoundingFriendRegistrationDto(
  firstName: 'Taylor',
  lastName: 'Jones',
  email: 'taylor@example.com',
  age: 31,
  country: 'United Kingdom',
  gender: 'Non-binary',
  usageReason: 'Meeting people nearby',
  marketingConsent: true,
);

HubSpotUserRegistrationDataSource _dataSource(
  http.Client client, {
  Duration submissionTimeout = defaultHubSpotRegistrationSubmissionTimeout,
}) => HubSpotUserRegistrationDataSource(
  client: client,
  config: _config,
  submissionTimeout: submissionTimeout,
);

final class _NeverCompletingClient extends http.BaseClient {
  bool wasAborted = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final abortableRequest = request as http.AbortableRequest;
    return abortableRequest.abortTrigger!.then<http.StreamedResponse>((_) {
      wasAborted = true;
      throw http.RequestAbortedException(request.url);
    });
  }
}
