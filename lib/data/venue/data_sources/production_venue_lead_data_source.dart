import 'dart:async';
import 'dart:convert';

import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_exception.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_interest_request.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';
import 'package:http/http.dart' as http;

/// Relative path for the same-origin public venue-interest endpoint.
const productionVenueLeadEndpointPath = '/api/venue-interest';

/// Maximum time allowed for one production venue-lead submission.
const defaultProductionVenueLeadSubmissionTimeout = Duration(seconds: 15);

/// Production venue-lead boundary backed by Fun App's first-party endpoint.
final class ProductionVenueLeadDataSource
    implements VenueLeadDataSourceInterface {
  /// Creates a [ProductionVenueLeadDataSource].
  factory ProductionVenueLeadDataSource({
    required http.Client client,
    Uri? endpoint,
    Duration submissionTimeout = defaultProductionVenueLeadSubmissionTimeout,
  }) => ProductionVenueLeadDataSource._(
    client,
    endpoint ?? Uri.base.resolve(productionVenueLeadEndpointPath),
    submissionTimeout,
  );

  const ProductionVenueLeadDataSource._(
    this._client,
    this._endpoint,
    this._submissionTimeout,
  );

  final http.Client _client;
  final Uri _endpoint;
  final Duration _submissionTimeout;

  @override
  Future<void> submitVenueLead(VenueLeadDto lead) async {
    final abortCompleter = Completer<void>();
    final timeoutTimer = Timer(
      _submissionTimeout,
      abortCompleter.complete,
    );
    final request =
        http.AbortableRequest(
            'POST',
            _endpoint,
            abortTrigger: abortCompleter.future,
          )
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(
            VenueInterestRequest.fromVenueLead(lead).toJson(),
          );
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

    if (statusCode == 204) {
      return;
    } else if (statusCode == 400 || statusCode == 422) {
      throw const VenueLeadSubmissionRejectedException();
    } else if (statusCode == 429 || statusCode == 503) {
      throw const VenueLeadServiceUnavailableException();
    } else {
      throw const VenueLeadUnexpectedDataSourceException();
    }
  }
}
