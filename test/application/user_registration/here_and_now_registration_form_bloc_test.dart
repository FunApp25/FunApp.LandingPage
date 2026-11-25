import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/user_registration/here_and_now_registration_form_bloc/here_and_now_registration_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/age.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/here_and_now_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/here_and_now_registration_repository_interface.dart';

void main() {
  late _Repository repository;

  setUp(() {
    repository = _Repository();
  });

  HereAndNowRegistrationFormBloc buildBloc() =>
      HereAndNowRegistrationFormBloc(repository);

  test('initial state is an incomplete editable draft', () async {
    final bloc = buildBloc();
    addTearDown(bloc.close);

    expect(bloc.state.registration.isValid, isFalse);
    expect(bloc.state.hasAttemptedSubmit, isFalse);
    expect(bloc.state.isSubmitting, isFalse);
    expect(bloc.state.submissionResult, none<Either<AppFailure, Unit>>());
  });

  blocTest<HereAndNowRegistrationFormBloc, HereAndNowRegistrationFormState>(
    'invalid submit exposes validation and does not call the repository',
    build: buildBloc,
    act: (bloc) => bloc.add(const HereAndNowRegistrationFormEvent.submitted()),
    expect: () => [
      _state(
        registration: HereAndNowRegistration.empty(),
        hasAttemptedSubmit: true,
      ),
    ],
    verify: (_) => expect(repository.submissions, isEmpty),
  );

  for (final result in <Either<AppFailure, Unit>>[
    right(unit),
    left(const AppFailure.serviceUnavailable()),
  ]) {
    final outcome = result.isRight() ? 'success' : 'failure';
    blocTest<HereAndNowRegistrationFormBloc, HereAndNowRegistrationFormState>(
      'valid submit emits pending then $outcome',
      setUp: () {
        repository.onSubmit = (_) async => result;
      },
      build: buildBloc,
      seed: () => _state(registration: _validRegistration()),
      act: (bloc) =>
          bloc.add(const HereAndNowRegistrationFormEvent.submitted()),
      expect: () => [
        _state(
          registration: _validRegistration(),
          hasAttemptedSubmit: true,
          isSubmitting: true,
        ),
        _state(
          registration: _validRegistration(),
          hasAttemptedSubmit: true,
          submissionResult: some(result),
        ),
      ],
      verify: (_) => expect(repository.submissions, [_validRegistration()]),
    );
  }

  blocTest<HereAndNowRegistrationFormBloc, HereAndNowRegistrationFormState>(
    'blocks a duplicate submission while one call is in flight',
    setUp: () {
      final completer = Completer<Either<AppFailure, Unit>>();
      repository.configurePending(completer);
    },
    build: buildBloc,
    seed: () => _state(registration: _validRegistration()),
    act: (bloc) async {
      bloc
        ..add(const HereAndNowRegistrationFormEvent.submitted())
        ..add(const HereAndNowRegistrationFormEvent.submitted());
      await Future<void>.delayed(Duration.zero);
      expect(repository.submissions, hasLength(1));
      repository.complete!();
    },
    expect: () => [
      _state(
        registration: _validRegistration(),
        hasAttemptedSubmit: true,
        isSubmitting: true,
      ),
      _state(
        registration: _validRegistration(),
        hasAttemptedSubmit: true,
        submissionResult: some(right(unit)),
      ),
    ],
  );

  blocTest<HereAndNowRegistrationFormBloc, HereAndNowRegistrationFormState>(
    'failure can be retried successfully',
    setUp: () {
      repository.onSubmit = (_) async => repository.submissions.length == 1
          ? left(const AppFailure.serviceUnavailable())
          : right(unit);
    },
    build: buildBloc,
    seed: () => _state(registration: _validRegistration()),
    act: (bloc) async {
      final firstCompletion = bloc.stream.firstWhere(
        (state) => !state.isSubmitting && state.submissionResult.isSome(),
      );
      bloc.add(const HereAndNowRegistrationFormEvent.submitted());
      await firstCompletion;
      bloc.add(const HereAndNowRegistrationFormEvent.submitted());
    },
    expect: () => [
      _state(
        registration: _validRegistration(),
        hasAttemptedSubmit: true,
        isSubmitting: true,
      ),
      _state(
        registration: _validRegistration(),
        hasAttemptedSubmit: true,
        submissionResult: some(
          left(const AppFailure.serviceUnavailable()),
        ),
      ),
      _state(
        registration: _validRegistration(),
        hasAttemptedSubmit: true,
        isSubmitting: true,
      ),
      _state(
        registration: _validRegistration(),
        hasAttemptedSubmit: true,
        submissionResult: some(right(unit)),
      ),
    ],
    verify: (_) => expect(repository.submissions, hasLength(2)),
  );

  blocTest<HereAndNowRegistrationFormBloc, HereAndNowRegistrationFormState>(
    'discards a stale completion after the draft changes in flight',
    setUp: () {
      final completer = Completer<Either<AppFailure, Unit>>();
      repository.configurePending(completer);
    },
    build: buildBloc,
    seed: () => _state(registration: _validRegistration()),
    act: (bloc) async {
      final pending = bloc.stream.firstWhere((state) => state.isSubmitting);
      bloc.add(const HereAndNowRegistrationFormEvent.submitted());
      await pending;
      bloc.add(
        const HereAndNowRegistrationFormEvent.firstNameChanged('Edited'),
      );
      await bloc.stream.firstWhere(
        (state) => state.registration.firstName == PersonalName('Edited'),
      );
      repository.complete!();
    },
    expect: () => [
      _state(
        registration: _validRegistration(),
        hasAttemptedSubmit: true,
        isSubmitting: true,
      ),
      _state(
        registration: _validRegistration().copyWith(
          firstName: PersonalName('Edited'),
        ),
        hasAttemptedSubmit: true,
        isSubmitting: true,
      ),
      _state(
        registration: _validRegistration().copyWith(
          firstName: PersonalName('Edited'),
        ),
        hasAttemptedSubmit: true,
      ),
    ],
  );
}

HereAndNowRegistrationFormState _state({
  required HereAndNowRegistration registration,
  bool hasAttemptedSubmit = false,
  bool isSubmitting = false,
  Option<Either<AppFailure, Unit>>? submissionResult,
}) => HereAndNowRegistrationFormState(
  registration: registration,
  hasAttemptedSubmit: hasAttemptedSubmit,
  isSubmitting: isSubmitting,
  submissionResult: submissionResult ?? none(),
);

HereAndNowRegistration _validRegistration() => HereAndNowRegistration(
  firstName: PersonalName('Alex'),
  lastName: PersonalName('Morgan'),
  email: EmailAddress('alex@example.com'),
  age: Age('29'),
  gender: none(),
  usageReason: none(),
  marketingConsent: false,
);

final class _Repository implements HereAndNowRegistrationRepositoryInterface {
  Future<Either<AppFailure, Unit>> Function(HereAndNowRegistration)? onSubmit;
  VoidCallback? complete;
  final submissions = <HereAndNowRegistration>[];

  void configurePending(Completer<Either<AppFailure, Unit>> completer) {
    onSubmit = (_) => completer.future;
    complete = () => completer.complete(right(unit));
  }

  @override
  Future<Either<AppFailure, Unit>> submitHereAndNowRegistration(
    HereAndNowRegistration registration,
  ) {
    submissions.add(registration);
    return onSubmit?.call(registration) ?? Future.value(right(unit));
  }
}

typedef VoidCallback = void Function();
