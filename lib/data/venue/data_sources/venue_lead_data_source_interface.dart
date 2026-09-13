import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';

/// Data-layer boundary for submitting validated venue-lead values.
abstract interface class VenueLeadDataSourceInterface {
  /// Submits one provider-neutral venue-lead data transfer object.
  Future<void> submitVenueLead(VenueLeadDto lead);
}
