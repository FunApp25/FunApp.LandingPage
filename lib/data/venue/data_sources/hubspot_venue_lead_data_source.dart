import 'dart:convert';

import 'package:fun_app_landing_page/core/config/hubspot_forms_config.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/hubspot_venue_lead_mapper.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_exception.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';
import 'package:http/http.dart' as http;

/// Production venue-lead boundary backed by HubSpot's public Forms API.
final class HubSpotVenueLeadDataSource implements VenueLeadDataSourceInterface {
  /// Creates a [HubSpotVenueLeadDataSource].
  const HubSpotVenueLeadDataSource(
    this._client,
    this._config, [
    this._mapper = const HubSpotVenueLeadMapper(),
  ]);

  final http.Client _client;
  final HubSpotFormsConfig _config;
  final HubSpotVenueLeadMapper _mapper;

  @override
  Future<void> submitVenueLead(VenueLeadDto lead) async {
    final endpoint = Uri(
      scheme: 'https',
      host: 'api.hsforms.com',
      pathSegments: [
        'submissions',
        'v3',
        'integration',
        'submit',
        _config.portalId,
        _config.venueFormGuid,
      ],
    );
    final payload = <String, Object>{
      'fields': _mapper.toFields(lead),
    };
    final http.Response response;

    try {
      response = await _client.post(
        endpoint,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } on http.ClientException {
      throw const VenueLeadServiceUnavailableException();
    }

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 400) {
      throw const VenueLeadSubmissionRejectedException();
    } else if (response.statusCode == 429 ||
        response.statusCode >= 500 && response.statusCode <= 599) {
      throw const VenueLeadServiceUnavailableException();
    } else {
      throw const VenueLeadUnexpectedDataSourceException();
    }
  }
}
