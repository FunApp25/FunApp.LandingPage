import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/development_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/hubspot_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_exception.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';
import 'package:fun_app_landing_page/data/venue/venue_lead_repository.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
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

  test('HubSpot deadline aborts and settles as unavailable', () async {
    final client = _AbortThenSuccessClient();
    final dataSource = _hubSpotDataSource(
      client,
      submissionTimeout: const Duration(milliseconds: 10),
    );

    await expectLater(
      dataSource.submitVenueLead(lead),
      throwsA(isA<VenueLeadServiceUnavailableException>()),
    );

    expect(client.requestCount, 1);
    expect(client.firstRequestAborted, isTrue);
    client.completeFirstRequestWithLateSuccess();
    await Future<void>.delayed(Duration.zero);
  });

  test('timeout clears BLoC submission and permits a safe retry', () async {
    final client = _AbortThenSuccessClient();
    final repository = VenueLeadRepository(
      _hubSpotDataSource(
        client,
        submissionTimeout: const Duration(milliseconds: 10),
      ),
    );
    final bloc = VenueLeadFormBloc(repository);
    addTearDown(bloc.close);
    await _populateValidDraft(bloc);

    final firstCompletion = bloc.stream.firstWhere(
      (state) => !state.isSubmitting && state.submissionResult.isSome(),
    );
    bloc.add(const VenueLeadFormEvent.submitted());
    await firstCompletion;

    expect(bloc.state.isSubmitting, isFalse);
    expect(
      bloc.state.submissionResult,
      some(
        left<AppFailure, Unit>(const AppFailure.serviceUnavailable()),
      ),
    );
    expect(client.firstRequestAborted, isTrue);

    client.completeFirstRequestWithLateSuccess();
    await Future<void>.delayed(Duration.zero);
    expect(
      bloc.state.submissionResult,
      some(
        left<AppFailure, Unit>(const AppFailure.serviceUnavailable()),
      ),
    );

    final retryCompletion = bloc.stream.firstWhere(
      (state) => !state.isSubmitting && state.submissionResult.isSome(),
    );
    bloc.add(const VenueLeadFormEvent.submitted());
    await retryCompletion;

    expect(bloc.state.submissionResult, some(right<AppFailure, Unit>(unit)));
    expect(client.requestCount, 2);
  });
}

HubSpotVenueLeadDataSource _hubSpotDataSource(
  http.Client client, {
  Duration submissionTimeout = defaultHubSpotSubmissionTimeout,
}) => HubSpotVenueLeadDataSource(
  client: client,
  portalId: '123456789',
  venueFormGuid: '00000000-0000-0000-0000-000000000000',
  submissionTimeout: submissionTimeout,
);

Future<void> _populateValidDraft(VenueLeadFormBloc bloc) async {
  final validDraft = bloc.stream.firstWhere((state) => state.lead.isValid);
  bloc
    ..add(const VenueLeadFormEvent.venueNameChanged('Synthetic Venue'))
    ..add(
      const VenueLeadFormEvent.websiteChanged('https://venue.example.com'),
    )
    ..add(const VenueLeadFormEvent.firstNameChanged('Test'))
    ..add(const VenueLeadFormEvent.lastNameChanged('Contact'))
    ..add(const VenueLeadFormEvent.roleChanged('Manager'))
    ..add(const VenueLeadFormEvent.emailChanged('contact@example.com'));
  await validDraft;
}

class _AbortThenSuccessClient extends http.BaseClient {
  final Completer<http.StreamedResponse> _firstResponse = Completer();
  int requestCount = 0;
  bool firstRequestAborted = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requestCount += 1;

    if (requestCount == 1) {
      final abortableRequest = request as http.AbortableRequest;

      return Future.any([
        _firstResponse.future,
        abortableRequest.abortTrigger!.then<http.StreamedResponse>((_) {
          firstRequestAborted = true;
          throw http.RequestAbortedException(request.url);
        }),
      ]);
    } else {
      return Future.value(_successResponse(request));
    }
  }

  void completeFirstRequestWithLateSuccess() {
    if (!_firstResponse.isCompleted) {
      _firstResponse.complete(
        _successResponse(),
      );
    }
  }

  http.StreamedResponse _successResponse([http.BaseRequest? request]) =>
      http.StreamedResponse(
        const Stream<List<int>>.empty(),
        200,
        request: request,
      );
}
