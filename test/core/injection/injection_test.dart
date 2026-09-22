import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/core/config/app_environment.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/development_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/production_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/data/venue/venue_lead_repository.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/website.dart';
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
  });

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
