import 'dart:async';
import 'dart:convert';

import 'package:fun_app_landing_page/data/venue/data_sources/hubspot_venue_lead_mapper.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_exception.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';
import 'package:http/http.dart' as http;

/// Maximum time allowed for one production venue-lead submission.
const defaultHubSpotSubmissionTimeout = Duration(seconds: 15);

/// Production venue-lead boundary backed by HubSpot's public Forms API.
final class HubSpotVenueLeadDataSource implements VenueLeadDataSourceInterface {
  /// Creates a [HubSpotVenueLeadDataSource].
  factory HubSpotVenueLeadDataSource({
    required http.Client client,
    required String portalId,
    required String venueFormGuid,
    Duration submissionTimeout = defaultHubSpotSubmissionTimeout,
    HubSpotVenueLeadMapper mapper = const HubSpotVenueLeadMapper(),
  }) => HubSpotVenueLeadDataSource._(
    client,
    portalId,
    venueFormGuid,
    submissionTimeout,
    mapper,
  );

  const HubSpotVenueLeadDataSource._(
    this._client,
    this._portalId,
    this._venueFormGuid,
    this._submissionTimeout,
    this._mapper,
  );

  final http.Client _client;
  final String _portalId;
  final String _venueFormGuid;
  final Duration _submissionTimeout;
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
        _portalId,
        _venueFormGuid,
      ],
    );
    final payload = <String, Object>{
      'fields': _mapper.toFields(lead),
    };
    final abortCompleter = Completer<void>();
    final timeoutTimer = Timer(
      _submissionTimeout,
      abortCompleter.complete,
    );
    final request =
        http.AbortableRequest(
            'POST',
            endpoint,
            abortTrigger: abortCompleter.future,
          )
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(payload);
    final int statusCode;

    try {
      final response = await _client.send(request);
      statusCode = response.statusCode;
      await response.stream.drain<void>();
    } on http.RequestAbortedException {
      throw const VenueLeadServiceUnavailableException();
    } on http.ClientException {
      throw const VenueLeadServiceUnavailableException();
    } finally {
      timeoutTimer.cancel();
    }

    if (statusCode == 200) {
      return;
    } else if (statusCode == 400) {
      throw const VenueLeadSubmissionRejectedException();
    } else if (statusCode == 429 || statusCode >= 500 && statusCode <= 599) {
      throw const VenueLeadServiceUnavailableException();
    } else {
      throw const VenueLeadUnexpectedDataSourceException();
    }
  }
}
