import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/core/config/app_environment.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/development_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/hubspot_venue_lead_data_source.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/data/venue/venue_lead_repository.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/website.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';
import 'package:fun_app_landing_page/domain/venue/venue_lead_repository_interface.dart';

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
    final bloc = getIt<VenueLeadFormBloc>();
    await bloc.close();
  });

  test(
    'production resolves the HubSpot stub and maps its unavailable result',
    () async {
      configureDependencies(AppEnvironment.production);

      final repository = getIt<VenueLeadRepositoryInterface>();
      expect(repository, isA<VenueLeadRepository>());
      expect(
        getIt<VenueLeadDataSourceInterface>(),
        isA<HubSpotVenueLeadDataSource>(),
      );
      expect(
        await repository.submitVenueLead(_validLead()),
        left<AppFailure, Unit>(const AppFailure.serviceUnavailable()),
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
