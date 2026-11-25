part of 'here_and_now_registration_form_bloc.dart';

/// Editable Here & Now registration draft and one-shot submission state.
@freezed
abstract class HereAndNowRegistrationFormState
    with _$HereAndNowRegistrationFormState {
  /// Creates a [HereAndNowRegistrationFormState].
  const factory HereAndNowRegistrationFormState({
    required HereAndNowRegistration registration,
    required bool hasAttemptedSubmit,
    required bool isSubmitting,
    required Option<Either<AppFailure, Unit>> submissionResult,
  }) = _HereAndNowRegistrationFormState;

  /// Creates the initial incomplete form state.
  factory HereAndNowRegistrationFormState.initial() =>
      HereAndNowRegistrationFormState(
        registration: HereAndNowRegistration.empty(),
        hasAttemptedSubmit: false,
        isSubmitting: false,
        submissionResult: none(),
      );
}
