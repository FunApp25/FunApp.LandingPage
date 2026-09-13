import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/config/hubspot_forms_config.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/development_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/hubspot_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_exception.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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

  test('HubSpot posts the minimal unauthenticated Forms v3 request', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('response body is not required', 200);
    });
    final dataSource = _hubSpotDataSource(client);

    await dataSource.submitVenueLead(lead);

    expect(capturedRequest.method, 'POST');
    expect(
      capturedRequest.url,
      Uri.parse(
        'https://api.hsforms.com/submissions/v3/integration/submit/'
        '123456789/00000000-0000-0000-0000-000000000000',
      ),
    );
    expect(capturedRequest.headers['content-type'], 'application/json');
    expect(capturedRequest.headers, isNot(contains('authorization')));

    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(body.keys, ['fields']);
    expect(body['fields'], [
      {'name': 'your_venue_s_name', 'value': 'The Fun Venue'},
      {'name': 'website', 'value': 'https://venue.example.com'},
      {'name': 'first_name', 'value': 'Alex'},
      {'name': 'last_name', 'value': 'Morgan'},
      {'name': 'role', 'value': 'General manager'},
      {'name': 'email', 'value': 'alex@venue.example.com'},
    ]);
    for (final forbiddenValue in [
      'authorization',
      'token',
      'credential',
      'skipValidation',
      'legalConsentOptions',
      'context',
      'objectTypeId',
      'submittedAt',
    ]) {
      expect(capturedRequest.body, isNot(contains(forbiddenValue)));
    }
  });

  test('HubSpot accepts 200 without parsing the response body', () async {
    final dataSource = _hubSpotDataSource(
      MockClient(
        (_) async => http.Response('{not valid json', 200),
      ),
    );

    await expectLater(dataSource.submitVenueLead(lead), completes);
  });

  final responseCases = <(String, int, Matcher)>[
    (
      '400 as submission rejected',
      400,
      isA<VenueLeadSubmissionRejectedException>(),
    ),
    (
      '429 as service unavailable',
      429,
      isA<VenueLeadServiceUnavailableException>(),
    ),
    (
      '500 as service unavailable',
      500,
      isA<VenueLeadServiceUnavailableException>(),
    ),
    (
      'representative 503 as service unavailable',
      503,
      isA<VenueLeadServiceUnavailableException>(),
    ),
    (
      'representative 401 as unexpected',
      401,
      isA<VenueLeadUnexpectedDataSourceException>(),
    ),
  ];

  for (final (name, statusCode, exceptionMatcher) in responseCases) {
    test('HubSpot classifies $name without parsing the body', () async {
      final dataSource = _hubSpotDataSource(
        MockClient(
          (_) async => http.Response('{not valid json', statusCode),
        ),
      );

      await expectLater(
        dataSource.submitVenueLead(lead),
        throwsA(exceptionMatcher),
      );
    });
  }

  test('HubSpot classifies client transport failures as unavailable', () async {
    final dataSource = _hubSpotDataSource(
      MockClient((request) async {
        throw http.ClientException(
          'Synthetic transport failure.',
          request.url,
        );
      }),
    );

    await expectLater(
      dataSource.submitVenueLead(lead),
      throwsA(isA<VenueLeadServiceUnavailableException>()),
    );
  });
}

HubSpotVenueLeadDataSource _hubSpotDataSource(http.Client client) =>
    HubSpotVenueLeadDataSource(
      client,
      HubSpotFormsConfig.fromValues(
        portalId: '123456789',
        venueFormGuid: '00000000-0000-0000-0000-000000000000',
      ),
    );
