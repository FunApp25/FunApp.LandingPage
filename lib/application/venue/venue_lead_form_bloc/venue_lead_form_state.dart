part of 'venue_lead_form_bloc.dart';

/// Editable venue-lead draft and one-shot submission state.
@freezed
abstract class VenueLeadFormState with _$VenueLeadFormState {
  /// Creates a [VenueLeadFormState].
  const factory VenueLeadFormState({
    required VenueLead lead,
    required bool hasAttemptedSubmit,
    required bool isSubmitting,
    required Option<Either<AppFailure, Unit>> submissionResult,
  }) = _VenueLeadFormState;

  /// Creates the initial incomplete venue-lead form state.
  factory VenueLeadFormState.initial() => VenueLeadFormState(
    lead: VenueLead.empty(),
    hasAttemptedSubmit: false,
    isSubmitting: false,
    submissionResult: none(),
  );
}
