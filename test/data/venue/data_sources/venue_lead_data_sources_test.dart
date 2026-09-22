import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/development_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/production_venue_lead_data_source.dart';
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
    website: 'example.com',
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

  test('production resolves the endpoint against the current origin', () async {
    late http.Request capturedRequest;
    final dataSource = ProductionVenueLeadDataSource(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 204);
      }),
    );

    await dataSource.submitVenueLead(lead);

    expect(
      capturedRequest.url,
      Uri.base.resolve(productionVenueLeadEndpointPath),
    );
    expect(capturedRequest.url.path, productionVenueLeadEndpointPath);
  });

  test(
    'production posts the exact required first-party JSON request',
    () async {
      late http.Request capturedRequest;
      final dataSource = _productionDataSource(
        MockClient((request) async {
          capturedRequest = request;
          return http.Response('ignored worker response body', 204);
        }),
      );

      await dataSource.submitVenueLead(lead);

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url, _endpoint);
      expect(capturedRequest.headers['content-type'], 'application/json');
      expect(capturedRequest.headers, isNot(contains('authorization')));
      expect(
        jsonDecode(capturedRequest.body),
        {
          'venueName': 'The Fun Venue',
          'website': 'example.com',
          'firstName': 'Alex',
          'lastName': 'Morgan',
          'role': 'General manager',
          'email': 'alex@venue.example.com',
        },
      );
      for (final forbiddenValue in ['authorization', 'token', 'credential']) {
        expect(capturedRequest.body, isNot(contains(forbiddenValue)));
      }
    },
  );

  test(
    'production serializes an Independent enquiry without venue count',
    () async {
      late http.Request capturedRequest;
      final dataSource = _productionDataSource(
        MockClient((request) async {
          capturedRequest = request;
          return http.Response('', 204);
        }),
      );

      await dataSource.submitVenueLead(
        lead.copyWith(
          venueType: 'Pub',
          chainStatus: 'Independent',
        ),
      );

      final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
      expect(body['venueType'], 'Pub');
      expect(body['chainStatus'], 'Independent');
      expect(body, isNot(contains('venueCount')));
      expect(body, isNot(contains('venueCapacity')));
      expect(body, isNot(contains('phoneNumber')));
    },
  );

  test(
    'production serializes a full Part of chain enquiry without mutation',
    () async {
      late http.Request capturedRequest;
      final dataSource = _productionDataSource(
        MockClient((request) async {
          capturedRequest = request;
          return http.Response('', 204);
        }),
      );

      await dataSource.submitVenueLead(
        lead.copyWith(
          venueType: 'Music venue',
          chainStatus: 'Part of chain',
          venueCount: 4,
          venueCapacity: 850,
          website: 'subdomain.venue.test/path?interest=fun',
          phoneNumber: '0034123456789',
        ),
      );

      expect(
        jsonDecode(capturedRequest.body),
        {
          'venueName': 'The Fun Venue',
          'venueType': 'Music venue',
          'chainStatus': 'Part of chain',
          'venueCount': 4,
          'venueCapacity': 850,
          'website': 'subdomain.venue.test/path?interest=fun',
          'firstName': 'Alex',
          'lastName': 'Morgan',
          'role': 'General manager',
          'email': 'alex@venue.example.com',
          'phoneNumber': '0034123456789',
        },
      );
    },
  );

  test(
    'production accepts 204 without exposing or parsing the response body',
    () async {
      final dataSource = _productionDataSource(
        MockClient(
          (_) async => http.Response('{not valid json', 204),
        ),
      );

      await expectLater(dataSource.submitVenueLead(lead), completes);
    },
  );

  final responseCases = <(String, int, Matcher)>[
    (
      '400 as submission rejected',
      400,
      isA<VenueLeadSubmissionRejectedException>(),
    ),
    (
      '422 as submission rejected',
      422,
      isA<VenueLeadSubmissionRejectedException>(),
    ),
    (
      '429 as service unavailable',
      429,
      isA<VenueLeadServiceUnavailableException>(),
    ),
    (
      '503 as service unavailable',
      503,
      isA<VenueLeadServiceUnavailableException>(),
    ),
    (
      '500 as unexpected',
      500,
      isA<VenueLeadUnexpectedDataSourceException>(),
    ),
    (
      'unrecognised 418 as unexpected',
      418,
      isA<VenueLeadUnexpectedDataSourceException>(),
    ),
  ];

  for (final (name, statusCode, exceptionMatcher) in responseCases) {
    test('production classifies $name without parsing the body', () async {
      final dataSource = _productionDataSource(
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

  test(
    'production classifies client transport failures as unavailable',
    () async {
      final dataSource = _productionDataSource(
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
    },
  );

  test('production deadline aborts and settles as unavailable', () async {
    final client = _AbortThenSuccessClient();
    final dataSource = _productionDataSource(
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
      _productionDataSource(
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

final _endpoint = Uri(
  scheme: 'https',
  host: 'venue-interest.test',
  path: '/api/venue-interest',
);

ProductionVenueLeadDataSource _productionDataSource(
  http.Client client, {
  Duration submissionTimeout = defaultProductionVenueLeadSubmissionTimeout,
}) => ProductionVenueLeadDataSource(
  client: client,
  endpoint: _endpoint,
  submissionTimeout: submissionTimeout,
);

Future<void> _populateValidDraft(VenueLeadFormBloc bloc) async {
  final validDraft = bloc.stream.firstWhere((state) => state.lead.isValid);
  bloc
    ..add(const VenueLeadFormEvent.venueNameChanged('Synthetic Venue'))
    ..add(const VenueLeadFormEvent.websiteChanged('https://venue.example.com'))
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
        204,
        request: request,
      );
}
