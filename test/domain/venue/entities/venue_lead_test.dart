import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/phone_number.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/positive_integer.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/website.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';

void main() {
  test('is valid with required fields and all optional fields absent', () {
    final lead = _validLead();

    expect(lead.venueType, none<NonEmptySingleLineText>());
    expect(lead.chainStatus, none<NonEmptySingleLineText>());
    expect(lead.venueCount, none<PositiveInteger>());
    expect(lead.venueCapacity, none<PositiveInteger>());
    expect(lead.phoneNumber, none<PhoneNumber>());
    expect(lead.failureOption, none<ValueFailure<dynamic>>());
    expect(
      lead.failureOrUnit,
      right<ValueFailure<dynamic>, Unit>(unit),
    );
    expect(lead.isValid, isTrue);
  });

  test('is valid with every optional field populated', () {
    final lead = _validLead().copyWith(
      venueType: some(NonEmptySingleLineText('Music venue')),
      chainStatus: some(NonEmptySingleLineText('Part of a chain')),
      venueCount: some(PositiveInteger('4')),
      venueCapacity: some(PositiveInteger('850')),
      phoneNumber: some(PhoneNumber('0034123456789')),
    );

    expect(lead.isValid, isTrue);
  });

  group('required fields', () {
    test('rejects an invalid venue name', () {
      _expectInvalid(
        _validLead().copyWith(venueName: NonEmptySingleLineText('')),
        const ValueFailure<String>.emptyString(failedValue: ''),
      );
    });

    test('rejects an invalid website', () {
      _expectInvalid(
        _validLead().copyWith(website: Website('example.com')),
        const ValueFailure<String>.invalidUrl(failedValue: 'example.com'),
      );
    });

    test('rejects an invalid first name', () {
      _expectInvalid(
        _validLead().copyWith(firstName: PersonalName('')),
        const ValueFailure<String>.emptyString(failedValue: ''),
      );
    });

    test('rejects an invalid last name', () {
      _expectInvalid(
        _validLead().copyWith(lastName: PersonalName('')),
        const ValueFailure<String>.emptyString(failedValue: ''),
      );
    });

    test('rejects an invalid role', () {
      _expectInvalid(
        _validLead().copyWith(role: NonEmptySingleLineText('')),
        const ValueFailure<String>.emptyString(failedValue: ''),
      );
    });

    test('rejects an invalid email', () {
      _expectInvalid(
        _validLead().copyWith(email: EmailAddress('invalid')),
        const ValueFailure<String>.invalidEmail(failedValue: 'invalid'),
      );
    });
  });

  group('present optional fields', () {
    test('rejects an invalid venue type', () {
      _expectInvalid(
        _validLead().copyWith(
          venueType: some(NonEmptySingleLineText('')),
        ),
        const ValueFailure<String>.emptyString(failedValue: ''),
      );
    });

    test('rejects an invalid chain status', () {
      const input = 'Part of\na chain';
      _expectInvalid(
        _validLead().copyWith(
          chainStatus: some(NonEmptySingleLineText(input)),
        ),
        const ValueFailure<String>.multiLineString(failedValue: input),
      );
    });

    test('rejects an invalid venue count', () {
      _expectInvalid(
        _validLead().copyWith(venueCount: some(PositiveInteger('0'))),
        const ValueFailure<int>.belowMinimum(
          failedValue: 0,
          minimum: 1,
        ),
      );
    });

    test('rejects an invalid venue capacity', () {
      _expectInvalid(
        _validLead().copyWith(venueCapacity: some(PositiveInteger('many'))),
        const ValueFailure<int>.invalidNumericInput(failedValue: 'many'),
      );
    });

    test('rejects an invalid phone number', () {
      _expectInvalid(
        _validLead().copyWith(phoneNumber: some(PhoneNumber('+34123'))),
        const ValueFailure<String>.invalidNumericInput(
          failedValue: '+34123',
        ),
      );
    });
  });

  test('reports the first failure in product-field order', () {
    final lead = _validLead().copyWith(
      venueName: NonEmptySingleLineText(''),
      website: Website('invalid'),
      email: EmailAddress('invalid'),
    );

    expect(
      lead.failureOption,
      some<ValueFailure<dynamic>>(
        const ValueFailure<String>.emptyString(failedValue: ''),
      ),
    );
  });

  test('does not require venue count when a chain status is present', () {
    final lead = _validLead().copyWith(
      chainStatus: some(NonEmptySingleLineText('Part of a chain')),
      venueCount: none<PositiveInteger>(),
    );

    expect(lead.isValid, isTrue);
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

void _expectInvalid(VenueLead lead, ValueFailure<dynamic> expectedFailure) {
  expect(lead.failureOption, some(expectedFailure));
  expect(
    lead.failureOrUnit,
    left<ValueFailure<dynamic>, Unit>(expectedFailure),
  );
  expect(lead.isValid, isFalse);
}
