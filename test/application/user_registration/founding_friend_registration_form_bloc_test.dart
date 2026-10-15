import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/user_registration/founding_friend_registration_form_bloc/founding_friend_registration_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/age.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/founding_friend_registration_repository_interface.dart';

void main() {
  late _Repository repository;

  setUp(() {
    repository = _Repository();
  });

  FoundingFriendRegistrationFormBloc buildBloc() =>
      FoundingFriendRegistrationFormBloc(repository);

  blocTest<
    FoundingFriendRegistrationFormBloc,
    FoundingFriendRegistrationFormState
  >(
    'missing country exposes validation and does not call the repository',
    build: buildBloc,
    seed: () => _state(
      registration: _validRegistration().copyWith(
        country: NonEmptySingleLineText(''),
      ),
    ),
    act: (bloc) =>
        bloc.add(const FoundingFriendRegistrationFormEvent.submitted()),
    expect: () => [
      _state(
        registration: _validRegistration().copyWith(
          country: NonEmptySingleLineText(''),
        ),
        hasAttemptedSubmit: true,
      ),
    ],
    verify: (_) => expect(repository.submissions, isEmpty),
  );

  for (final result in <Either<AppFailure, Unit>>[
    right(unit),
    left(const AppFailure.submissionRejected()),
  ]) {
    final outcome = result.isRight() ? 'success' : 'failure';
    blocTest<
      FoundingFriendRegistrationFormBloc,
      FoundingFriendRegistrationFormState
    >(
      'valid submit emits pending then $outcome',
      setUp: () {
        repository.onSubmit = (_) async => result;
      },
      build: buildBloc,
      seed: () => _state(registration: _validRegistration()),
      act: (bloc) =>
          bloc.add(const FoundingFriendRegistrationFormEvent.submitted()),
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

  blocTest<
    FoundingFriendRegistrationFormBloc,
    FoundingFriendRegistrationFormState
  >(
    'blocks duplicate in-flight submissions',
    setUp: () {
      final completer = Completer<Either<AppFailure, Unit>>();
      repository.configurePending(completer);
    },
    build: buildBloc,
    seed: () => _state(registration: _validRegistration()),
    act: (bloc) async {
      bloc
        ..add(const FoundingFriendRegistrationFormEvent.submitted())
        ..add(const FoundingFriendRegistrationFormEvent.submitted());
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

  blocTest<
    FoundingFriendRegistrationFormBloc,
    FoundingFriendRegistrationFormState
  >(
    'failure can be retried successfully without losing the draft',
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
      bloc.add(const FoundingFriendRegistrationFormEvent.submitted());
      await firstCompletion;
      bloc.add(const FoundingFriendRegistrationFormEvent.submitted());
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

  blocTest<
    FoundingFriendRegistrationFormBloc,
    FoundingFriendRegistrationFormState
  >(
    'editing after failure clears the result and preserves validation state',
    build: buildBloc,
    seed: () => _state(
      registration: _validRegistration(),
      hasAttemptedSubmit: true,
      submissionResult: some(left(const AppFailure.unexpected())),
    ),
    act: (bloc) => bloc.add(
      const FoundingFriendRegistrationFormEvent.usageReasonChanged(
        'Updated reason',
      ),
    ),
    expect: () => [
      _state(
        registration: _validRegistration().copyWith(
          usageReason: some('Updated reason'),
        ),
        hasAttemptedSubmit: true,
      ),
    ],
  );
}

FoundingFriendRegistrationFormState _state({
  required FoundingFriendRegistration registration,
  bool hasAttemptedSubmit = false,
  bool isSubmitting = false,
  Option<Either<AppFailure, Unit>>? submissionResult,
}) => FoundingFriendRegistrationFormState(
  registration: registration,
  hasAttemptedSubmit: hasAttemptedSubmit,
  isSubmitting: isSubmitting,
  submissionResult: submissionResult ?? none(),
);

FoundingFriendRegistration _validRegistration() => FoundingFriendRegistration(
  firstName: PersonalName('Taylor'),
  lastName: PersonalName('Jones'),
  email: EmailAddress('taylor@example.com'),
  age: Age('31'),
  country: NonEmptySingleLineText('Afghanistan'),
  gender: none(),
  usageReason: none(),
  marketingConsent: false,
);

final class _Repository
    implements FoundingFriendRegistrationRepositoryInterface {
  Future<Either<AppFailure, Unit>> Function(FoundingFriendRegistration)?
  onSubmit;
  VoidCallback? complete;
  final submissions = <FoundingFriendRegistration>[];

  void configurePending(Completer<Either<AppFailure, Unit>> completer) {
    onSubmit = (_) => completer.future;
    complete = () => completer.complete(right(unit));
  }

  @override
  Future<Either<AppFailure, Unit>> submitFoundingFriendRegistration(
    FoundingFriendRegistration registration,
  ) {
    submissions.add(registration);
    return onSubmit?.call(registration) ?? Future.value(right(unit));
  }
}

typedef VoidCallback = void Function();
