import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/user_registration/founding_friend_registration_form_bloc/founding_friend_registration_form_bloc.dart';
import 'package:fun_app_landing_page/application/user_registration/here_and_now_registration_form_bloc/here_and_now_registration_form_bloc.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/core/config/app_environment.dart';
import 'package:fun_app_landing_page/core/config/development_registration_transport.dart';
import 'package:fun_app_landing_page/core/config/hubspot_registration_forms_config.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/hubspot_user_registration_data_source.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_interface.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/worker_user_registration_data_source.dart';
import 'package:fun_app_landing_page/data/user_registration/deferred_founding_friend_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/deferred_here_and_now_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/founding_friend_registration_repository.dart';
import 'package:fun_app_landing_page/data/user_registration/here_and_now_registration_repository.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/development_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/production_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/data/venue/venue_lead_repository.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/website.dart';
import 'package:fun_app_landing_page/domain/user_registration/founding_friend_registration_repository_interface.dart';
import 'package:fun_app_landing_page/domain/user_registration/here_and_now_registration_repository_interface.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';
import 'package:fun_app_landing_page/domain/venue/venue_lead_repository_interface.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('development resolves repository, fake data source, and BLoC', () async {
    configureDependencies(AppEnvironment.development);

    expect(
      getIt<VenueLeadRepositoryInterface>(),
      isA<VenueLeadRepository>(),
    );
    expect(
      getIt<VenueLeadDataSourceInterface>(),
      isA<DevelopmentVenueLeadDataSource>(),
    );
    expect(getIt.isRegistered<http.Client>(), isFalse);
    final bloc = getIt<VenueLeadFormBloc>();
    await bloc.close();
    expect(
      getIt<HereAndNowRegistrationRepositoryInterface>(),
      isA<DeferredHereAndNowRegistrationRepository>(),
    );
    expect(
      getIt<FoundingFriendRegistrationRepositoryInterface>(),
      isA<DeferredFoundingFriendRegistrationRepository>(),
    );
    await getIt<HereAndNowRegistrationFormBloc>().close();
    await getIt<FoundingFriendRegistrationFormBloc>().close();
  });

  test(
    'configured development wires both BLoCs to direct HubSpot HTTP',
    () async {
      final requestedUrls = <Uri>[];
      final client = MockClient((request) async {
        requestedUrls.add(request.url);
        return http.Response('', 200);
      });
      final config = HubSpotRegistrationFormsConfig(
        portalId: '149114580',
        hereAndNowFormGuid: '3284e6bc-e3a2-4d2e-9e21-684399126f3b',
        foundingFriendFormGuid: '39f027d9-e786-4768-b532-54ed44e1f718',
      );
      configureDependencies(
        AppEnvironment.development,
        developmentRegistrationHttpClient: client,
        developmentRegistrationTransport:
            DevelopmentRegistrationTransport.directHubSpot,
        developmentHubSpotConfig: config,
      );

      expect(
        getIt<UserRegistrationDataSourceInterface>(),
        isA<HubSpotUserRegistrationDataSource>(),
      );
      expect(
        getIt<HereAndNowRegistrationRepositoryInterface>(),
        isA<HereAndNowRegistrationRepository>(),
      );
      expect(
        getIt<FoundingFriendRegistrationRepositoryInterface>(),
        isA<FoundingFriendRegistrationRepository>(),
      );

      final hereAndNowBloc = getIt<HereAndNowRegistrationFormBloc>()
        ..add(const HereAndNowRegistrationFormEvent.firstNameChanged('Alex'))
        ..add(const HereAndNowRegistrationFormEvent.lastNameChanged('Morgan'))
        ..add(
          const HereAndNowRegistrationFormEvent.emailChanged(
            'alex@example.com',
          ),
        )
        ..add(const HereAndNowRegistrationFormEvent.ageChanged('29'));
      await hereAndNowBloc.stream.firstWhere(
        (state) => state.registration.isValid,
      );
      final settled = hereAndNowBloc.stream.firstWhere(
        (state) => state.submissionResult.isSome(),
      );
      hereAndNowBloc.add(const HereAndNowRegistrationFormEvent.submitted());
      await settled;

      expect(requestedUrls, [
        config.submissionEndpoint(config.hereAndNowFormGuid),
      ]);
      await hereAndNowBloc.close();
    },
  );

  test(
    'local Worker development wires both repositories to first-party HTTP',
    () async {
      final requestedUrls = <Uri>[];
      final client = MockClient((request) async {
        requestedUrls.add(request.url);
        return http.Response('', 204);
      });
      configureDependencies(
        AppEnvironment.development,
        developmentRegistrationHttpClient: client,
        developmentRegistrationTransport:
            DevelopmentRegistrationTransport.localWorker,
        developmentWorkerConfig: LocalRegistrationWorkerConfig(
          baseUrl: 'http://localhost:8787',
        ),
      );

      expect(
        getIt<UserRegistrationDataSourceInterface>(),
        isA<WorkerUserRegistrationDataSource>(),
      );
      expect(
        getIt<HereAndNowRegistrationRepositoryInterface>(),
        isA<HereAndNowRegistrationRepository>(),
      );
      expect(
        getIt<FoundingFriendRegistrationRepositoryInterface>(),
        isA<FoundingFriendRegistrationRepository>(),
      );

      final hereAndNowBloc = getIt<HereAndNowRegistrationFormBloc>()
        ..add(const HereAndNowRegistrationFormEvent.firstNameChanged('Alex'))
        ..add(const HereAndNowRegistrationFormEvent.lastNameChanged('Morgan'))
        ..add(
          const HereAndNowRegistrationFormEvent.emailChanged(
            'alex@example.com',
          ),
        )
        ..add(const HereAndNowRegistrationFormEvent.ageChanged('29'));
      await hereAndNowBloc.stream.firstWhere(
        (state) => state.registration.isValid,
      );
      final settled = hereAndNowBloc.stream.firstWhere(
        (state) => state.submissionResult.isSome(),
      );
      hereAndNowBloc.add(const HereAndNowRegistrationFormEvent.submitted());
      await settled;

      expect(requestedUrls, [
        Uri.parse(
          'http://localhost:8787/api/registrations/here-and-now',
        ),
      ]);
      await hereAndNowBloc.close();
      await getIt<FoundingFriendRegistrationFormBloc>().close();
    },
  );

  test(
    'production injects the first-party data source without real I/O',
    () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response('response body is not required', 204);
      });
      configureDependencies(
        AppEnvironment.production,
        productionHttpClient: client,
        developmentRegistrationTransport:
            DevelopmentRegistrationTransport.localWorker,
        developmentWorkerConfig: LocalRegistrationWorkerConfig(
          baseUrl: 'http://localhost:8787',
        ),
        developmentHubSpotConfig: HubSpotRegistrationFormsConfig(
          portalId: '149114580',
          hereAndNowFormGuid: '3284e6bc-e3a2-4d2e-9e21-684399126f3b',
          foundingFriendFormGuid: '39f027d9-e786-4768-b532-54ed44e1f718',
        ),
      );

      final repository = getIt<VenueLeadRepositoryInterface>();
      expect(repository, isA<VenueLeadRepository>());
      expect(getIt<http.Client>(), same(client));
      expect(
        getIt<VenueLeadDataSourceInterface>(),
        isA<ProductionVenueLeadDataSource>(),
      );
      expect(
        getIt<VenueLeadDataSourceInterface>(),
        isNot(isA<DevelopmentVenueLeadDataSource>()),
      );
      expect(
        await repository.submitVenueLead(_validLead()),
        right<AppFailure, Unit>(unit),
      );
      expect(
        capturedRequest.url,
        Uri.base.resolve('/api/venue-interest'),
      );
      final bloc = getIt<VenueLeadFormBloc>();
      await bloc.close();
      expect(
        getIt<HereAndNowRegistrationRepositoryInterface>(),
        isA<DeferredHereAndNowRegistrationRepository>(),
      );
      expect(
        getIt<FoundingFriendRegistrationRepositoryInterface>(),
        isA<DeferredFoundingFriendRegistrationRepository>(),
      );
      expect(
        getIt.isRegistered<UserRegistrationDataSourceInterface>(),
        isFalse,
      );
      await getIt<HereAndNowRegistrationFormBloc>().close();
      await getIt<FoundingFriendRegistrationFormBloc>().close();
    },
  );
}

VenueLead _validLead() => VenueLead(
  venueName: NonEmptySingleLineText('The Fun Venue'),
  venueType: none(),
  chainStatus: none(),
  venueCount: none(),
  venueCapacity: none(),
  website: Website('https://venue.example.com'),
  firstName: PersonalName('Alex'),
  lastName: PersonalName('Morgan'),
  role: NonEmptySingleLineText('General manager'),
  email: EmailAddress('alex@venue.example.com'),
  phoneNumber: none(),
);
