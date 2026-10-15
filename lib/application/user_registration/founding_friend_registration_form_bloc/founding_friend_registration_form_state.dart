part of 'founding_friend_registration_form_bloc.dart';

/// Editable Founding Friend draft and one-shot submission state.
@freezed
abstract class FoundingFriendRegistrationFormState
    with _$FoundingFriendRegistrationFormState {
  /// Creates a [FoundingFriendRegistrationFormState].
  const factory FoundingFriendRegistrationFormState({
    required FoundingFriendRegistration registration,
    required bool hasAttemptedSubmit,
    required bool isSubmitting,
    required Option<Either<AppFailure, Unit>> submissionResult,
  }) = _FoundingFriendRegistrationFormState;

  /// Creates the initial incomplete form state.
  factory FoundingFriendRegistrationFormState.initial() =>
      FoundingFriendRegistrationFormState(
        registration: FoundingFriendRegistration.empty(),
        hasAttemptedSubmit: false,
        isSubmitting: false,
        submissionResult: none(),
      );
}
