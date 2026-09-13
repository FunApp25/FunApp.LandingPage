import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';

void main() {
  test('accepts an email without lowercasing it', () {
    const input = 'Venue.Contact@Example.com';

    expect(
      EmailAddress(input).value,
      right<ValueFailure<String>, String>(input),
    );
  });

  test('reports empty input before email format', () {
    expect(
      EmailAddress('').value,
      left<ValueFailure<String>, String>(
        const ValueFailure.emptyString(failedValue: ''),
      ),
    );
  });

  test('reports multiline input before email format', () {
    const input = 'person\n@example.com';

    expect(
      EmailAddress(input).value,
      left<ValueFailure<String>, String>(
        const ValueFailure.multiLineString(failedValue: input),
      ),
    );
  });

  test('reports invalid format after structural validation', () {
    const input = 'not-an-email';

    expect(
      EmailAddress(input).value,
      left<ValueFailure<String>, String>(
        const ValueFailure.invalidEmail(failedValue: input),
      ),
    );
  });

  test('does not silently trim surrounding whitespace', () {
    const input = ' person@example.com ';

    expect(
      EmailAddress(input).value,
      left<ValueFailure<String>, String>(
        const ValueFailure.invalidEmail(failedValue: input),
      ),
    );
  });
}
