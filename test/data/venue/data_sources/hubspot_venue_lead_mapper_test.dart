import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/data/core/hubspot_fields.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/hubspot_venue_lead_mapper.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';

void main() {
  const mapper = HubSpotVenueLeadMapper();

  test('maps required-only values and omits absent optional fields', () {
    final fields = mapper.toFields(_requiredOnlyLead);

    expect(fields, [
      {'name': HubSpotFields.venueName, 'value': 'Synthetic Venue'},
      {'name': HubSpotFields.website, 'value': 'https://venue.test'},
      {'name': HubSpotFields.firstName, 'value': 'Test'},
      {'name': HubSpotFields.lastName, 'value': 'Contact'},
      {'name': HubSpotFields.role, 'value': 'Test role'},
      {'name': HubSpotFields.email, 'value': 'contact@venue.test'},
    ]);
    expect(
      fields.map((field) => field['name']),
      isNot(contains(HubSpotFields.venueType)),
    );
    expect(
      fields.map((field) => field['name']),
      isNot(contains(HubSpotFields.chainStatus)),
    );
    expect(
      fields.map((field) => field['name']),
      isNot(contains(HubSpotFields.venueCount)),
    );
    expect(
      fields.map((field) => field['name']),
      isNot(contains(HubSpotFields.venueCapacity)),
    );
    expect(
      fields.map((field) => field['name']),
      isNot(contains(HubSpotFields.phoneNumber)),
    );
  });

  test('maps every field with exact HubSpot names and string values', () {
    final fields = mapper.toFields(
      _requiredOnlyLead.copyWith(
        venueType: 'Music venue',
        chainStatus: 'Part of a chain',
        venueCount: 4,
        venueCapacity: 850,
        phoneNumber: '0034123456789',
      ),
    );

    expect(fields, [
      {'name': 'your_venue_s_name', 'value': 'Synthetic Venue'},
      {'name': 'type_of_venue', 'value': 'Music venue'},
      {
        'name': 'independent_or_part_of_chain_',
        'value': 'Part of a chain',
      },
      {'name': 'if_chain__number_of_venues', 'value': '4'},
      {'name': 'your_venue_s_capacity', 'value': '850'},
      {'name': 'website', 'value': 'https://venue.test'},
      {'name': 'first_name', 'value': 'Test'},
      {'name': 'last_name', 'value': 'Contact'},
      {'name': 'role', 'value': 'Test role'},
      {'name': 'email', 'value': 'contact@venue.test'},
      {'name': 'phone_number', 'value': '0034123456789'},
    ]);
    expect(HubSpotFields.chainStatus, 'independent_or_part_of_chain_');
    expect(HubSpotFields.venueCount, 'if_chain__number_of_venues');
  });
}

const _requiredOnlyLead = VenueLeadDto(
  venueName: 'Synthetic Venue',
  venueType: null,
  chainStatus: null,
  venueCount: null,
  venueCapacity: null,
  website: 'https://venue.test',
  firstName: 'Test',
  lastName: 'Contact',
  role: 'Test role',
  email: 'contact@venue.test',
  phoneNumber: null,
);
