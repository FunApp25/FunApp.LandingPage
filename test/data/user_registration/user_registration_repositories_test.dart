import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/config/development_registration_transport.dart';
import 'package:fun_app_landing_page/core/config/founding_friend_payment_config.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/data_sources/worker_founding_friend_payment_data_source.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_exception.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_interface.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/worker_user_registration_data_source.dart';
import 'package:fun_app_landing_page/data/user_registration/founding_friend_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/here_and_now_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/models/founding_friend_registration_dto.dart';
import 'package:fun_app_landing_page/data/user_registration/models/here_and_now_registration_dto.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/age.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/here_and_now_registration.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    '254-unit email passes registration and Checkout serialization unchanged',
    () async {
      final email = 'a@${'b' * 63}.${'c' * 63}.${'d' * 63}.${'e' * 60}';
      expect(email.length, 254);
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        if (request.url.path.contains('/registrations/')) {
          return http.Response('', 204);
        } else {
          return http.Response(
            jsonEncode({
              'checkoutUrl': 'https://checkout.stripe.com/c/pay/safe',
              'sessionId': 'cs_test_abcdefghijklmnopqrstuvwxyz123456',
            }),
            201,
          );
        }
      });
      final registration = _foundingFriendRegistration().copyWith(
        email: EmailAddress(email),
      );
      final result = await FoundingFriendRegistrationRepository(
        WorkerUserRegistrationDataSource(
          client: client,
          config: LocalRegistrationWorkerConfig(
            baseUrl: 'http://localhost:8787',
          ),
        ),
      ).submitFoundingFriendRegistration(registration);
      expect(result.isRight(), isTrue);
      await WorkerFoundingFriendPaymentDataSource(
        client: client,
        config: FoundingFriendPaymentConfig(
          baseUrl: 'http://localhost:8788',
          allowLocalMockCheckoutUrls: true,
          localCheckoutOrigin: 'http://localhost:7357',
        ),
      ).createCheckout(
        email: registration.emailValidation.getOrElse(
          () => throw StateError('invalid'),
        ),
        attemptId: '123e4567-e89b-42d3-a456-426614174000',
      );
      expect(requests, hasLength(2));
      for (final request in requests) {
        expect(
          (jsonDecode(request.body) as Map<String, dynamic>)['email'],
          email,
        );
        expect(request.bodyBytes.length, lessThan(4 * 1024));
      }
    },
  );

  for (final length in [255, 261]) {
    test(
      'Founding Friend rejects $length-unit email before data-source I/O',
      () async {
        final email =
            'a@${'b' * 63}.${'c' * 63}.${'d' * 63}.'
            '${'e' * (length == 255 ? 61 : 62)}'
            "${length == 261 ? '.test' : ''}";
        expect(email.length, length);
        final source = _DataSource();
        final registration = _foundingFriendRegistration().copyWith(
          email: EmailAddress(email),
        );
        await FoundingFriendRegistrationRepository(source)
            .submitFoundingFriendRegistration(registration);
        expect(source.calls, 0);
      },
    );
  }

  late _DataSource dataSource;

  setUp(() {
    dataSource = _DataSource();
  });

  test(
    'Here & Now repository maps a valid aggregate and returns unit',
    () async {
      final repository = HereAndNowRegistrationRepository(dataSource);

      expect(
        await repository.submitHereAndNowRegistration(
          _hereAndNowRegistration(),
        ),
        right<AppFailure, Unit>(unit),
      );
      expect(dataSource.hereAndNow?.age, 29);
      expect(dataSource.hereAndNow?.marketingConsent, isFalse);
    },
  );

  test(
    'Founding Friend repository maps exact optional and enum values',
    () async {
      final repository = FoundingFriendRegistrationRepository(dataSource);

      expect(
        await repository.submitFoundingFriendRegistration(
          _foundingFriendRegistration(),
        ),
        right<AppFailure, Unit>(unit),
      );
      expect(dataSource.foundingFriend?.country, 'United Kingdom');
      expect(dataSource.foundingFriend?.gender, 'Woman');
      expect(dataSource.foundingFriend?.usageReason, 'Meet local people');
      expect(dataSource.foundingFriend?.marketingConsent, isTrue);
    },
  );

  final failureCases = <(Object, AppFailure)>[
    (
      const UserRegistrationServiceUnavailableException(),
      const AppFailure.serviceUnavailable(),
    ),
    (
      const UserRegistrationSubmissionRejectedException(),
      const AppFailure.submissionRejected(),
    ),
    (
      const UserRegistrationUnexpectedDataSourceException(),
      const AppFailure.unexpected(),
    ),
    (StateError('synthetic'), const AppFailure.unexpected()),
  ];

  for (final (exception, expected) in failureCases) {
    test('both repositories map ${exception.runtimeType}', () async {
      dataSource.exception = exception;

      expect(
        await HereAndNowRegistrationRepository(
          dataSource,
        ).submitHereAndNowRegistration(_hereAndNowRegistration()),
        left<AppFailure, Unit>(expected),
      );
      expect(
        await FoundingFriendRegistrationRepository(
          dataSource,
        ).submitFoundingFriendRegistration(_foundingFriendRegistration()),
        left<AppFailure, Unit>(expected),
      );
    });
  }

  test('invalid aggregates fail without calling the data source', () async {
    expect(
      await HereAndNowRegistrationRepository(
        dataSource,
      ).submitHereAndNowRegistration(HereAndNowRegistration.empty()),
      left<AppFailure, Unit>(const AppFailure.unexpected()),
    );
    expect(
      await FoundingFriendRegistrationRepository(
        dataSource,
      ).submitFoundingFriendRegistration(FoundingFriendRegistration.empty()),
      left<AppFailure, Unit>(const AppFailure.unexpected()),
    );
    expect(dataSource.calls, 0);
  });
}

HereAndNowRegistration _hereAndNowRegistration() => HereAndNowRegistration(
  firstName: PersonalName('Alex'),
  lastName: PersonalName('Morgan'),
  email: EmailAddress('alex@example.com'),
  age: Age('29'),
  gender: none(),
  usageReason: none(),
  marketingConsent: false,
);

FoundingFriendRegistration _foundingFriendRegistration() =>
    FoundingFriendRegistration(
      firstName: PersonalName('Taylor'),
      lastName: PersonalName('Jones'),
      email: EmailAddress('taylor@example.com'),
      age: Age('31'),
      country: NonEmptySingleLineText('United Kingdom'),
      gender: some(NonEmptySingleLineText('Woman')),
      usageReason: some('Meet local people'),
      marketingConsent: true,
    );

final class _DataSource implements UserRegistrationDataSourceInterface {
  int calls = 0;
  Object? exception;
  HereAndNowRegistrationDto? hereAndNow;
  FoundingFriendRegistrationDto? foundingFriend;

  @override
  Future<void> submitHereAndNowRegistration(
    HereAndNowRegistrationDto registration,
  ) async {
    calls += 1;
    hereAndNow = registration;
    _throwIfConfigured();
  }

  @override
  Future<void> submitFoundingFriendRegistration(
    FoundingFriendRegistrationDto registration,
  ) async {
    calls += 1;
    foundingFriend = registration;
    _throwIfConfigured();
  }

  void _throwIfConfigured() {
    if (exception != null) {
      Error.throwWithStackTrace(exception!, StackTrace.current);
    }
  }
}
