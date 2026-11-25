part of 'founding_friend_registration_form_bloc.dart';

/// Raw form intents for the Founding Friend registration workflow.
@freezed
sealed class FoundingFriendRegistrationFormEvent
    with _$FoundingFriendRegistrationFormEvent {
  /// Updates the required first name.
  const factory FoundingFriendRegistrationFormEvent.firstNameChanged(
    String firstName,
  ) = _FirstNameChanged;

  /// Updates the required last name.
  const factory FoundingFriendRegistrationFormEvent.lastNameChanged(
    String lastName,
  ) = _LastNameChanged;

  /// Updates the required email address.
  const factory FoundingFriendRegistrationFormEvent.emailChanged(String email) =
      _EmailChanged;

  /// Updates the required integer age input.
  const factory FoundingFriendRegistrationFormEvent.ageChanged(String age) =
      _AgeChanged;

  /// Updates the required country selection.
  const factory FoundingFriendRegistrationFormEvent.countryChanged(
    String? country,
  ) = _CountryChanged;

  /// Updates or clears the optional gender selection.
  const factory FoundingFriendRegistrationFormEvent.genderChanged(
    String? gender,
  ) = _GenderChanged;

  /// Updates or clears the optional usage reason.
  const factory FoundingFriendRegistrationFormEvent.usageReasonChanged(
    String usageReason,
  ) = _UsageReasonChanged;

  /// Updates the optional marketing opt-in.
  const factory FoundingFriendRegistrationFormEvent.marketingConsentChanged({
    required bool marketingConsent,
  }) = _MarketingConsentChanged;

  /// Attempts to submit the current draft once.
  const factory FoundingFriendRegistrationFormEvent.submitted() = _Submitted;
}
