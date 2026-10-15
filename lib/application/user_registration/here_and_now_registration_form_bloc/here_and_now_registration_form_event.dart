part of 'here_and_now_registration_form_bloc.dart';

/// Raw form intents for the Here & Now registration workflow.
@freezed
sealed class HereAndNowRegistrationFormEvent
    with _$HereAndNowRegistrationFormEvent {
  /// Updates the required first name.
  const factory HereAndNowRegistrationFormEvent.firstNameChanged(
    String firstName,
  ) = _FirstNameChanged;

  /// Updates the required last name.
  const factory HereAndNowRegistrationFormEvent.lastNameChanged(
    String lastName,
  ) = _LastNameChanged;

  /// Updates the required email address.
  const factory HereAndNowRegistrationFormEvent.emailChanged(String email) =
      _EmailChanged;

  /// Updates the required integer age input.
  const factory HereAndNowRegistrationFormEvent.ageChanged(String age) =
      _AgeChanged;

  /// Updates or clears the optional gender selection.
  const factory HereAndNowRegistrationFormEvent.genderChanged(String? gender) =
      _GenderChanged;

  /// Updates or clears the optional usage reason.
  const factory HereAndNowRegistrationFormEvent.usageReasonChanged(
    String usageReason,
  ) = _UsageReasonChanged;

  /// Updates the optional marketing opt-in.
  const factory HereAndNowRegistrationFormEvent.marketingConsentChanged({
    required bool marketingConsent,
  }) = _MarketingConsentChanged;

  /// Attempts to submit the current draft once.
  const factory HereAndNowRegistrationFormEvent.submitted() = _Submitted;
}
