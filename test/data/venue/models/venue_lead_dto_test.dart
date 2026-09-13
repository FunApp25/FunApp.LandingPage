import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/phone_number.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/positive_integer.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/website.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';

void main() {
  test('extracts validated required values and preserves optional absence', () {
    final dto = VenueLeadDto.fromValidDomain(_validLead());

    expect(
      dto,
      const VenueLeadDto(
        venueName: '  The Fun Venue  ',
        venueType: null,
        chainStatus: null,
        venueCount: null,
        venueCapacity: null,
        website: 'https://venue.example.com/path',
        firstName: 'Alex',
        lastName: 'Morgan',
        role: 'General manager',
        email: 'Alex@venue.example.com',
        phoneNumber: null,
      ),
    );
  });

  test('extracts every validated optional value without provider metadata', () {
    final dto = VenueLeadDto.fromValidDomain(
      _validLead().copyWith(
        venueType: some(NonEmptySingleLineText('Music venue')),
        chainStatus: some(NonEmptySingleLineText('Part of a chain')),
        venueCount: some(PositiveInteger('4')),
        venueCapacity: some(PositiveInteger('850')),
        phoneNumber: some(PhoneNumber('0034123456789')),
      ),
    );

    expect(dto.venueType, 'Music venue');
    expect(dto.chainStatus, 'Part of a chain');
    expect(dto.venueCount, 4);
    expect(dto.venueCapacity, 850);
    expect(dto.phoneNumber, '0034123456789');
    expect(dto.toString(), isNot(contains('HubSpot')));
    expect(
      dto.toString(),
      isNot(contains('independent_or_part_of_chain_')),
    );
    expect(
      dto.toString(),
      isNot(contains('if_chain__number_of_venues')),
    );
  });
}

VenueLead _validLead() => VenueLead(
  venueName: NonEmptySingleLineText('  The Fun Venue  '),
  venueType: none(),
  chainStatus: none(),
  venueCount: none(),
  venueCapacity: none(),
  website: Website('https://venue.example.com/path'),
  firstName: PersonalName('Alex'),
  lastName: PersonalName('Morgan'),
  role: NonEmptySingleLineText('General manager'),
  email: EmailAddress('Alex@venue.example.com'),
  phoneNumber: none(),
);
