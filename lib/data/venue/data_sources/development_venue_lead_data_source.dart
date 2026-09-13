import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';

/// Deterministic local venue-lead submission boundary with no external I/O.
final class DevelopmentVenueLeadDataSource
    implements VenueLeadDataSourceInterface {
  /// Creates a [DevelopmentVenueLeadDataSource].
  const DevelopmentVenueLeadDataSource();

  @override
  Future<void> submitVenueLead(VenueLeadDto lead) async {}
}
