import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/phone_number.dart';

void main() {
  test('accepts numeric text and preserves leading zeroes', () {
    const input = '00123456789';

    expect(
      PhoneNumber(input).value,
      right<ValueFailure<String>, String>(input),
    );
  });

  test('reports empty input before numeric format', () {
    expect(
      PhoneNumber('').value,
      left<ValueFailure<String>, String>(
        const ValueFailure.emptyString(failedValue: ''),
      ),
    );
  });

  test('reports multiline input before numeric format', () {
    const input = '123\n456';

    expect(
      PhoneNumber(input).value,
      left<ValueFailure<String>, String>(
        const ValueFailure.multiLineString(failedValue: input),
      ),
    );
  });

  test('rejects non-digit telephone formatting', () {
    for (final input in ['+34123456789', '123 456 789', '123-456-789']) {
      expect(
        PhoneNumber(input).value,
        left<ValueFailure<String>, String>(
          ValueFailure.invalidNumericInput(failedValue: input),
        ),
      );
    }
  });
}
