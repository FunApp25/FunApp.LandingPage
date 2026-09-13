import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';

void main() {
  test('accepts a present single-line personal name', () {
    expect(
      PersonalName('Marta').value,
      right<ValueFailure<String>, String>('Marta'),
    );
  });

  test('rejects a whitespace-only personal name', () {
    const input = '   ';

    expect(
      PersonalName(input).value,
      left<ValueFailure<String>, String>(
        const ValueFailure.emptyString(failedValue: input),
      ),
    );
  });

  test('rejects a multiline personal name', () {
    const input = 'Mary\nJane';

    expect(
      PersonalName(input).value,
      left<ValueFailure<String>, String>(
        const ValueFailure.multiLineString(failedValue: input),
      ),
    );
  });
}
