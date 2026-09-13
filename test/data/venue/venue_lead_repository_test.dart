import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_exception.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';
import 'package:fun_app_landing_page/data/venue/venue_lead_repository.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/phone_number.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/positive_integer.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/website.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';

void main() {
  late _VenueLeadDataSource dataSource;
  late VenueLeadRepository repository;

  setUp(() {
    dataSource = _VenueLeadDataSource();
    repository = VenueLeadRepository(dataSource);
  });

  test('submits required-only values once and returns unit', () async {
    final result = await repository.submitVenueLead(_validLead());

    expect(result, right<AppFailure, Unit>(unit));
    expect(dataSource.calls, 1);
    expect(
      dataSource.submittedLead,
      const VenueLeadDto(
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
      ),
    );
  });

  test('submits the exact fully populated translation', () async {
    final lead = _validLead().copyWith(
      venueType: some(NonEmptySingleLineText('Music venue')),
      chainStatus: some(NonEmptySingleLineText('Part of a chain')),
      venueCount: some(PositiveInteger('4')),
      venueCapacity: some(PositiveInteger('850')),
      phoneNumber: some(PhoneNumber('0034123456789')),
    );

    await repository.submitVenueLead(lead);

    expect(
      dataSource.submittedLead,
      const VenueLeadDto(
        venueName: 'The Fun Venue',
        venueType: 'Music venue',
        chainStatus: 'Part of a chain',
        venueCount: 4,
        venueCapacity: 850,
        website: 'https://venue.example.com',
        firstName: 'Alex',
        lastName: 'Morgan',
        role: 'General manager',
        email: 'alex@venue.example.com',
        phoneNumber: '0034123456789',
      ),
    );
    expect(dataSource.calls, 1);
  });

  final classifiedFailures =
      <
        (
          String,
          Object,
          AppFailure,
        )
      >[
        (
          'service unavailable',
          const VenueLeadServiceUnavailableException(),
          const AppFailure.serviceUnavailable(),
        ),
        (
          'submission rejected',
          const VenueLeadSubmissionRejectedException(),
          const AppFailure.submissionRejected(),
        ),
        (
          'typed unexpected data-source response',
          const VenueLeadUnexpectedDataSourceException(),
          const AppFailure.unexpected(),
        ),
        (
          'unexpected',
          StateError('unexpected data-source failure'),
          const AppFailure.unexpected(),
        ),
      ];

  for (final (name, exception, expectedFailure) in classifiedFailures) {
    test('maps $name without exposing the data-source exception', () async {
      dataSource.exception = exception;

      final result = await repository.submitVenueLead(_validLead());

      expect(result, left<AppFailure, Unit>(expectedFailure));
      expect(dataSource.calls, 1);
    });
  }

  test('rejects invalid domain input without extraction or I/O', () async {
    final result = await repository.submitVenueLead(VenueLead.empty());

    expect(
      result,
      left<AppFailure, Unit>(const AppFailure.unexpected()),
    );
    expect(dataSource.calls, 0);
    expect(dataSource.submittedLead, isNull);
  });
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

final class _VenueLeadDataSource implements VenueLeadDataSourceInterface {
  int calls = 0;
  VenueLeadDto? submittedLead;
  Object? exception;

  @override
  Future<void> submitVenueLead(VenueLeadDto lead) async {
    calls += 1;
    submittedLead = lead;

    if (exception != null) {
      Error.throwWithStackTrace(exception!, StackTrace.current);
    }
  }
}
