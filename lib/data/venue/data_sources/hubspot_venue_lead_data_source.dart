import 'package:fun_app_landing_page/core/config/app_environment.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_exception.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';
import 'package:injectable/injectable.dart';

/// Production venue-lead boundary reserved for the future HubSpot transport.
@LazySingleton(
  as: VenueLeadDataSourceInterface,
  env: [productionEnvironmentName],
)
final class HubSpotVenueLeadDataSource implements VenueLeadDataSourceInterface {
  /// Creates a [HubSpotVenueLeadDataSource].
  const HubSpotVenueLeadDataSource();

  @override
  Future<void> submitVenueLead(VenueLeadDto lead) => Future<void>.error(
    const VenueLeadIntegrationNotImplementedException(),
  );
}
