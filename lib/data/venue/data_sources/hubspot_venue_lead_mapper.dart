import 'package:fun_app_landing_page/data/core/hubspot_fields.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';

/// Maps provider-neutral venue-lead values to HubSpot form fields.
final class HubSpotVenueLeadMapper {
  /// Creates a stateless HubSpot field mapper.
  const HubSpotVenueLeadMapper();

  /// Returns the exact field names and string values accepted by HubSpot.
  List<Map<String, String>> toFields(VenueLeadDto lead) {
    final fields = <Map<String, String>>[
      _field(HubSpotFields.venueName, lead.venueName),
    ];

    if (lead.venueType case final venueType?) {
      fields.add(_field(HubSpotFields.venueType, venueType));
    }
    if (lead.chainStatus case final chainStatus?) {
      fields.add(_field(HubSpotFields.chainStatus, chainStatus));
    }
    if (lead.venueCount case final venueCount?) {
      fields.add(_field(HubSpotFields.venueCount, venueCount.toString()));
    }
    if (lead.venueCapacity case final venueCapacity?) {
      fields.add(
        _field(HubSpotFields.venueCapacity, venueCapacity.toString()),
      );
    }
    fields
      ..add(_field(HubSpotFields.website, lead.website))
      ..add(_field(HubSpotFields.firstName, lead.firstName))
      ..add(_field(HubSpotFields.lastName, lead.lastName))
      ..add(_field(HubSpotFields.role, lead.role))
      ..add(_field(HubSpotFields.email, lead.email));
    if (lead.phoneNumber case final phoneNumber?) {
      fields.add(_field(HubSpotFields.phoneNumber, phoneNumber));
    }

    return fields;
  }

  Map<String, String> _field(String name, String value) => {
    'name': name,
    'value': value,
  };
}
