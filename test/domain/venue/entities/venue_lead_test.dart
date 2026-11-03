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
  for (final (name, valid) in [
    ('a' * 512, true),
    ('a' * 513, false),
    ('', false),
    (' ' * 512, false),
    ('界' * 512, true),
    ('界' * 513, false),
    ('😀' * 256, true),
    ('${'😀' * 256}a', false),
    ('e\u0301' * 256, true),
    ('  Café Київ 東京  ', true),
  ]) {
    test('venue name boundary ${name.length} units is valid: $valid', () {
      final lead = _validLead().copyWith(
        venueName: NonEmptySingleLineText(name),
      );
      expect(lead.isValid, valid);
      expect(lead.venueNameValidation.isRight(), valid);
      if (valid) {
        expect(lead.venueName.getOrCrash(), name);
      }
    });
  }

  test('related Venue text limits apply only within the Venue aggregate', () {
    final lead = _validLead();
    for (final length in [256, 257]) {
      final text = '界' * length;
      final valid = length == 256;
      expect(
        lead.copyWith(venueType: some(NonEmptySingleLineText(text))).isValid,
        valid,
      );
      expect(lead.copyWith(firstName: PersonalName(text)).isValid, valid);
      expect(lead.copyWith(lastName: PersonalName(text)).isValid, valid);
      expect(lead.copyWith(role: NonEmptySingleLineText(text)).isValid, valid);
      expect(PersonalName(text).isValid(), isTrue);
      expect(NonEmptySingleLineText(text).isValid(), isTrue);
    }
    for (final length in [2048, 2049]) {
      final website = 'example.com/${'界' * (length - 12)}';
      expect(lead.copyWith(website: Website(website)).isValid, length == 2048);
    }
    for (final length in [320, 321]) {
      final email =
          '${'a' * 64}@${'b' * 63}.${'c' * 63}.${'d' * 63}.'
          '${'e' * (length == 320 ? 63 : 59)}'
          "${length == 321 ? '.test' : ''}";
      expect(email.length, length);
      expect(EmailAddress(email).isValid(), isTrue);
      expect(lead.copyWith(email: EmailAddress(email)).isValid, length == 320);
    }
    for (final length in [64, 65]) {
      expect(
        lead.copyWith(phoneNumber: some(PhoneNumber('0' * length))).isValid,
        length == 64,
      );
    }
  });

  test('empty creates an invalid typed draft with no optional values', () {
    final lead = VenueLead.empty();

    expect(lead.venueName, NonEmptySingleLineText(''));
    expect(lead.website, Website(''));
    expect(lead.firstName, PersonalName(''));
    expect(lead.lastName, PersonalName(''));
    expect(lead.role, NonEmptySingleLineText(''));
    expect(lead.email, EmailAddress(''));
    expect(lead.venueType, none<NonEmptySingleLineText>());
    expect(lead.chainStatus, none<NonEmptySingleLineText>());
    expect(lead.venueCount, none<PositiveInteger>());
    expect(lead.venueCapacity, none<PositiveInteger>());
    expect(lead.phoneNumber, none<PhoneNumber>());
    expect(lead.isValid, isFalse);
  });

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
      chainStatus: some(NonEmptySingleLineText('Part of chain')),
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
        _validLead().copyWith(website: Website('example')),
        const ValueFailure<String>.invalidUrl(failedValue: 'example'),
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
      chainStatus: some(NonEmptySingleLineText('Part of chain')),
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
