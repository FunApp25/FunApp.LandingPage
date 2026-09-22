part of 'venue_lead_form_bloc.dart';

/// Raw form intents for the prospective-venue lead workflow.
@freezed
sealed class VenueLeadFormEvent with _$VenueLeadFormEvent {
  /// Updates the required venue name.
  const factory VenueLeadFormEvent.venueNameChanged(String venueName) =
      _VenueNameChanged;

  /// Updates or clears the optional venue type.
  const factory VenueLeadFormEvent.venueTypeChanged(String venueType) =
      _VenueTypeChanged;

  /// Updates or clears the optional independent/chain status.
  const factory VenueLeadFormEvent.chainStatusChanged(String chainStatus) =
      _ChainStatusChanged;

  /// Updates or clears the optional venue count.
  const factory VenueLeadFormEvent.venueCountChanged(String venueCount) =
      _VenueCountChanged;

  /// Updates or clears the optional venue capacity.
  const factory VenueLeadFormEvent.venueCapacityChanged(String venueCapacity) =
      _VenueCapacityChanged;

  /// Updates the required website.
  const factory VenueLeadFormEvent.websiteChanged(String website) =
      _WebsiteChanged;

  /// Updates the required contact first name.
  const factory VenueLeadFormEvent.firstNameChanged(String firstName) =
      _FirstNameChanged;

  /// Updates the required contact last name.
  const factory VenueLeadFormEvent.lastNameChanged(String lastName) =
      _LastNameChanged;

  /// Updates the required contact role.
  const factory VenueLeadFormEvent.roleChanged(String role) = _RoleChanged;

  /// Updates the required contact email.
  const factory VenueLeadFormEvent.emailChanged(String email) = _EmailChanged;

  /// Updates or clears the optional contact phone number.
  const factory VenueLeadFormEvent.phoneNumberChanged(String phoneNumber) =
      _PhoneNumberChanged;

  /// Attempts to submit the current venue-lead draft once.
  const factory VenueLeadFormEvent.submitted() = _Submitted;
}
