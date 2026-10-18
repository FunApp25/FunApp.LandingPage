import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/config/development_registration_transport.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_exception.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/worker_user_registration_data_source.dart';
import 'package:fun_app_landing_page/data/user_registration/models/founding_friend_registration_dto.dart';
import 'package:fun_app_landing_page/data/user_registration/models/founding_friend_registration_request.dart';
import 'package:fun_app_landing_page/data/user_registration/models/here_and_now_registration_dto.dart';
import 'package:fun_app_landing_page/data/user_registration/models/here_and_now_registration_request.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('serializes exact required-only first-party request payloads', () {
    expect(
      HereAndNowRegistrationRequest.fromDto(_hereAndNowDto).toJson(),
      {
        'firstName': 'Alex',
        'lastName': 'Morgan',
        'email': 'alex@example.com',
        'age': 29,
        'marketingConsent': false,
      },
    );
    expect(
      FoundingFriendRegistrationRequest.fromDto(
        _foundingFriendDto,
      ).toJson(),
      {
        'firstName': 'Taylor',
        'lastName': 'Jones',
        'email': 'taylor@example.com',
        'age': 31,
        'country': 'United Kingdom',
        'marketingConsent': true,
      },
    );
  });

  test('serializes optional values without provider identifiers', () {
    final body = FoundingFriendRegistrationRequest.fromDto(
      const FoundingFriendRegistrationDto(
        firstName: 'Taylor',
        lastName: 'Jones',
        email: 'taylor@example.com',
        age: 31,
        country: 'United Kingdom',
        gender: 'Non-binary',
        usageReason: 'Meet local people',
        marketingConsent: true,
      ),
    ).toJson();

    expect(body['gender'], 'Non-binary');
    expect(body['usageReason'], 'Meet local people');
    expect(body, isNot(contains('portalId')));
    expect(body, isNot(contains('formGuid')));
  });

  test('posts each request to its exact local Worker endpoint', () async {
    final requests = <http.Request>[];
    final dataSource = _dataSource(
      MockClient((request) async {
        requests.add(request);
        return http.Response('ignored', 204);
      }),
    );

    await dataSource.submitHereAndNowRegistration(_hereAndNowDto);
    await dataSource.submitFoundingFriendRegistration(_foundingFriendDto);

    expect(requests.map((request) => request.url), [
      Uri.parse(
        'http://localhost:8787/api/registrations/here-and-now',
      ),
      Uri.parse(
        'http://localhost:8787/api/registrations/founding-friend',
      ),
    ]);
    expect(
      requests,
      everyElement(
        predicate<http.Request>(
          (request) =>
              request.method == 'POST' &&
              request.headers['content-type'] == 'application/json' &&
              !request.headers.containsKey('authorization'),
        ),
      ),
    );
    expect(jsonDecode(requests.first.body), {
      'firstName': 'Alex',
      'lastName': 'Morgan',
      'email': 'alex@example.com',
      'age': 29,
      'marketingConsent': false,
    });
  });

  final responseCases = <(String, int, Matcher)>[
    (
      '400 invalid request',
      400,
      isA<UserRegistrationSubmissionRejectedException>(),
    ),
    (
      '422 provider rejection',
      422,
      isA<UserRegistrationSubmissionRejectedException>(),
    ),
    (
      '429 rate limit',
      429,
      isA<UserRegistrationServiceUnavailableException>(),
    ),
    (
      '503 unavailable',
      503,
      isA<UserRegistrationServiceUnavailableException>(),
    ),
    (
      '500 internal failure',
      500,
      isA<UserRegistrationUnexpectedDataSourceException>(),
    ),
    (
      'unrecognised response',
      418,
      isA<UserRegistrationUnexpectedDataSourceException>(),
    ),
  ];

  for (final (name, statusCode, matcher) in responseCases) {
    test('classifies $name without parsing the response body', () async {
      final dataSource = _dataSource(
        MockClient((_) async => http.Response('{not json', statusCode)),
      );

      await expectLater(
        dataSource.submitHereAndNowRegistration(_hereAndNowDto),
        throwsA(matcher),
      );
    });
  }

  test('classifies transport failures as unavailable without retry', () async {
    var calls = 0;
    final dataSource = _dataSource(
      MockClient((request) async {
        calls += 1;
        throw http.ClientException('Synthetic failure.', request.url);
      }),
    );

    await expectLater(
      dataSource.submitHereAndNowRegistration(_hereAndNowDto),
      throwsA(isA<UserRegistrationServiceUnavailableException>()),
    );
    expect(calls, 1);
  });

  test('aborts a timed-out request and does not retry', () async {
    final client = _NeverCompletingClient();
    final dataSource = _dataSource(
      client,
      submissionTimeout: const Duration(milliseconds: 10),
    );

    await expectLater(
      dataSource.submitHereAndNowRegistration(_hereAndNowDto),
      throwsA(isA<UserRegistrationServiceUnavailableException>()),
    );
    expect(client.calls, 1);
    expect(client.wasAborted, isTrue);
  });
}

final _workerConfig = LocalRegistrationWorkerConfig(
  baseUrl: 'http://localhost:8787',
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
  gender: null,
  usageReason: null,
  marketingConsent: true,
);

WorkerUserRegistrationDataSource _dataSource(
  http.Client client, {
  Duration submissionTimeout = defaultWorkerRegistrationSubmissionTimeout,
}) => WorkerUserRegistrationDataSource(
  client: client,
  config: _workerConfig,
  submissionTimeout: submissionTimeout,
);

final class _NeverCompletingClient extends http.BaseClient {
  int calls = 0;
  bool wasAborted = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    calls += 1;
    final abortableRequest = request as http.AbortableRequest;
    return abortableRequest.abortTrigger!.then<http.StreamedResponse>((_) {
      wasAborted = true;
      throw http.RequestAbortedException(request.url);
    });
  }
}
