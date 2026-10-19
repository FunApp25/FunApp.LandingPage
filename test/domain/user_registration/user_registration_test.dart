import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/age.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/here_and_now_registration.dart';

void main() {
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
