import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/age.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/founding_friend_registration_repository_interface.dart';
import 'package:injectable/injectable.dart';

part 'founding_friend_registration_form_bloc.freezed.dart';
part 'founding_friend_registration_form_event.dart';
part 'founding_friend_registration_form_state.dart';

/// Owns the Founding Friend registration draft and submission workflow.
@injectable
class FoundingFriendRegistrationFormBloc
    extends
        Bloc<
          FoundingFriendRegistrationFormEvent,
          FoundingFriendRegistrationFormState
        > {
  /// Creates a BLoC backed by a provider-neutral repository.
  FoundingFriendRegistrationFormBloc(this._repository)
    : super(FoundingFriendRegistrationFormState.initial()) {
    on<_FirstNameChanged>(_onFirstNameChanged);
    on<_LastNameChanged>(_onLastNameChanged);
    on<_EmailChanged>(_onEmailChanged);
    on<_AgeChanged>(_onAgeChanged);
    on<_CountryChanged>(_onCountryChanged);
    on<_GenderChanged>(_onGenderChanged);
    on<_UsageReasonChanged>(_onUsageReasonChanged);
    on<_MarketingConsentChanged>(_onMarketingConsentChanged);
    on<_Submitted>(_onSubmitted);
  }

  final FoundingFriendRegistrationRepositoryInterface _repository;

  void _onFirstNameChanged(
    _FirstNameChanged event,
    Emitter<FoundingFriendRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(firstName: PersonalName(event.firstName)),
  );

  void _onLastNameChanged(
    _LastNameChanged event,
    Emitter<FoundingFriendRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(lastName: PersonalName(event.lastName)),
  );

  void _onEmailChanged(
    _EmailChanged event,
    Emitter<FoundingFriendRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(email: EmailAddress(event.email)),
  );

  void _onAgeChanged(
    _AgeChanged event,
    Emitter<FoundingFriendRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(age: Age(event.age)),
  );

  void _onCountryChanged(
    _CountryChanged event,
    Emitter<FoundingFriendRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(
      country: NonEmptySingleLineText(event.country ?? ''),
    ),
  );

  void _onGenderChanged(
    _GenderChanged event,
    Emitter<FoundingFriendRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(
      gender: _optionalSingleLineText(event.gender),
    ),
  );

  void _onUsageReasonChanged(
    _UsageReasonChanged event,
    Emitter<FoundingFriendRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(
      usageReason: _optionalText(event.usageReason),
    ),
  );

  void _onMarketingConsentChanged(
    _MarketingConsentChanged event,
    Emitter<FoundingFriendRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(marketingConsent: event.marketingConsent),
  );

  Future<void> _onSubmitted(
    _Submitted event,
    Emitter<FoundingFriendRegistrationFormState> emit,
  ) async {
    if (!state.isSubmitting) {
      final attemptedState = state.copyWith(
        hasAttemptedSubmit: true,
        submissionResult: none(),
      );

      if (state.registration.isValid) {
        final submittedRegistration = state.registration;
        emit(attemptedState.copyWith(isSubmitting: true));

        final result = await _repository.submitFoundingFriendRegistration(
          submittedRegistration,
        );
        final currentDraftWasSubmitted =
            state.registration == submittedRegistration;

        emit(
          state.copyWith(
            isSubmitting: false,
            hasAttemptedSubmit: true,
            submissionResult: currentDraftWasSubmitted ? some(result) : none(),
          ),
        );
      } else {
        emit(attemptedState.copyWith(isSubmitting: false));
      }
    }
  }

  void _emitRegistrationChange(
    Emitter<FoundingFriendRegistrationFormState> emit,
    FoundingFriendRegistration registration,
  ) => emit(
    state.copyWith(
      registration: registration,
      submissionResult: none(),
    ),
  );

  Option<NonEmptySingleLineText> _optionalSingleLineText(String? input) =>
      input == null || input.trim().isEmpty
      ? none()
      : some(NonEmptySingleLineText(input));

  Option<String> _optionalText(String input) =>
      input.trim().isEmpty ? none() : some(input);
}
