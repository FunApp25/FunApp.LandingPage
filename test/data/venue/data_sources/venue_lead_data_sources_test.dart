import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/development_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/hubspot_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_exception.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';

void main() {
  const lead = VenueLeadDto(
    venueName: 'The Fun Venue',
    venueType: null,
    chainStatus: null,
    venueCount: null,
    venueCapacity: null,
    website: 'https://venue.example.com',
    firstName: 'Alex',
    lastName: 'Morgan',
    role: 'General manager',
    email: 'alex@venue.example.com',
    phoneNumber: null,
  );

  test('development data source succeeds without external I/O', () async {
    const dataSource = DevelopmentVenueLeadDataSource();

    await expectLater(dataSource.submitVenueLead(lead), completes);
  });

  test('HubSpot stub reports integration not implemented', () async {
    const dataSource = HubSpotVenueLeadDataSource();

    await expectLater(
      dataSource.submitVenueLead(lead),
      throwsA(isA<VenueLeadIntegrationNotImplementedException>()),
    );
  });
}
