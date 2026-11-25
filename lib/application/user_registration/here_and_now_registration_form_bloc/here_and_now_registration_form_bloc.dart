import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/age.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/here_and_now_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/here_and_now_registration_repository_interface.dart';
import 'package:injectable/injectable.dart';

part 'here_and_now_registration_form_bloc.freezed.dart';
part 'here_and_now_registration_form_event.dart';
part 'here_and_now_registration_form_state.dart';

/// Owns the Here & Now registration draft and submission workflow.
@injectable
class HereAndNowRegistrationFormBloc
    extends
        Bloc<HereAndNowRegistrationFormEvent, HereAndNowRegistrationFormState> {
  /// Creates a BLoC backed by a provider-neutral repository.
  HereAndNowRegistrationFormBloc(this._repository)
    : super(HereAndNowRegistrationFormState.initial()) {
    on<_FirstNameChanged>(_onFirstNameChanged);
    on<_LastNameChanged>(_onLastNameChanged);
    on<_EmailChanged>(_onEmailChanged);
    on<_AgeChanged>(_onAgeChanged);
    on<_GenderChanged>(_onGenderChanged);
    on<_UsageReasonChanged>(_onUsageReasonChanged);
    on<_MarketingConsentChanged>(_onMarketingConsentChanged);
    on<_Submitted>(_onSubmitted);
  }

  final HereAndNowRegistrationRepositoryInterface _repository;

  void _onFirstNameChanged(
    _FirstNameChanged event,
    Emitter<HereAndNowRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(firstName: PersonalName(event.firstName)),
  );

  void _onLastNameChanged(
    _LastNameChanged event,
    Emitter<HereAndNowRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(lastName: PersonalName(event.lastName)),
  );

  void _onEmailChanged(
    _EmailChanged event,
    Emitter<HereAndNowRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(email: EmailAddress(event.email)),
  );

  void _onAgeChanged(
    _AgeChanged event,
    Emitter<HereAndNowRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(age: Age(event.age)),
  );

  void _onGenderChanged(
    _GenderChanged event,
    Emitter<HereAndNowRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(
      gender: _optionalSingleLineText(event.gender),
    ),
  );

  void _onUsageReasonChanged(
    _UsageReasonChanged event,
    Emitter<HereAndNowRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(
      usageReason: _optionalText(event.usageReason),
    ),
  );

  void _onMarketingConsentChanged(
    _MarketingConsentChanged event,
    Emitter<HereAndNowRegistrationFormState> emit,
  ) => _emitRegistrationChange(
    emit,
    state.registration.copyWith(marketingConsent: event.marketingConsent),
  );

  Future<void> _onSubmitted(
    _Submitted event,
    Emitter<HereAndNowRegistrationFormState> emit,
  ) async {
    if (!state.isSubmitting) {
      final attemptedState = state.copyWith(
        hasAttemptedSubmit: true,
        submissionResult: none(),
      );

      if (state.registration.isValid) {
        final submittedRegistration = state.registration;
        emit(attemptedState.copyWith(isSubmitting: true));

        final result = await _repository.submitHereAndNowRegistration(
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
    Emitter<HereAndNowRegistrationFormState> emit,
    HereAndNowRegistration registration,
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
