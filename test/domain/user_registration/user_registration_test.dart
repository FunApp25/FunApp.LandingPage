import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/age.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/here_and_now_registration.dart';

void main() {
  for (final (email, valid) in [
    ('first.last+tag@EXAMPLE.com', true),
    ('person@xn--bcher-kva.example', true),
    ('a@${'b' * 63}.${'c' * 63}.${'d' * 63}.${'e' * 60}', true),
    ('a@${'b' * 63}.${'c' * 63}.${'d' * 63}.${'e' * 61}', false),
    ('a@${'b' * 63}.${'c' * 63}.${'d' * 63}.${'e' * 62}.test', false),
    ('person@bücher.example', false),
    ('δοκιμή@example.com', false),
    (' person@example.com ', false),
  ]) {
    test('Founding Friend email ${email.length} units is valid: $valid', () {
      final address = EmailAddress(email);
      final registration = FoundingFriendRegistration.empty().copyWith(
        firstName: PersonalName('界'),
        lastName: PersonalName('Jones'),
        email: address,
        age: Age('0'),
        country: NonEmptySingleLineText('United Kingdom'),
      );
      expect(registration.emailValidation.isRight(), valid);
      expect(registration.isValid, valid);
      if (email.length > 254) {
        expect(address.isValid(), isTrue);
        expect(
          HereAndNowRegistration.empty()
              .copyWith(
                firstName: registration.firstName,
                lastName: registration.lastName,
                email: address,
                age: registration.age,
              )
              .isValid,
          isTrue,
        );
      }
      expect(
        address.value.fold((failure) => failure.failedValue, (value) => value),
        email,
      );
    });
  }

  group('Age', () {
    test(
      'accepts integer input without inventing an eligibility threshold',
      () {
        expect(Age('0').getOrCrash(), 0);
        expect(Age('-1').getOrCrash(), -1);
        expect(Age('29').getOrCrash(), 29);
      },
    );

    test('rejects blank and non-integer input', () {
      expect(Age('').isValid(), isFalse);
      expect(Age('29.5').isValid(), isFalse);
      expect(Age('29 years').isValid(), isFalse);
    });

    test('accepts only integers that JavaScript can serialize exactly', () {
      expect(Age('9007199254740991').getOrCrash(), 9007199254740991);
      expect(Age('-9007199254740991').getOrCrash(), -9007199254740991);
      expect(Age('9007199254740992').isValid(), isFalse);
      expect(Age('-9007199254740992').isValid(), isFalse);
    });
  });

  test('Here & Now requires only name, email, and integer age', () {
    final registration = HereAndNowRegistration(
      firstName: PersonalName('Alex'),
      lastName: PersonalName('Morgan'),
      email: EmailAddress('alex@example.com'),
      age: Age('29'),
      gender: none(),
      usageReason: none(),
      marketingConsent: false,
    );

    expect(registration.isValid, isTrue);
    expect(
      registration.copyWith(email: EmailAddress('invalid')).isValid,
      isFalse,
    );
    expect(
      registration.copyWith(age: Age('not-an-integer')).isValid,
      isFalse,
    );
  });

  test('Founding Friend additionally requires country but not opt-in', () {
    final registration = FoundingFriendRegistration(
      firstName: PersonalName('Taylor'),
      lastName: PersonalName('Jones'),
      email: EmailAddress('taylor@example.com'),
      age: Age('31'),
      country: NonEmptySingleLineText('Afghanistan'),
      gender: none(),
      usageReason: some('Meet people nearby'),
      marketingConsent: false,
    );

    expect(registration.isValid, isTrue);
    expect(
      registration.copyWith(country: NonEmptySingleLineText(' ')).isValid,
      isFalse,
    );
  });
}
