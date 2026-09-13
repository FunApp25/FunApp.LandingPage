import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/positive_integer.dart';

void main() {
  test('parses a positive integral quantity', () {
    expect(
      PositiveInteger('42').value,
      right<ValueFailure<int>, int>(42),
    );
  });

  test('rejects non-integral input without throwing', () {
    const input = '4.2';

    expect(
      PositiveInteger(input).value,
      left<ValueFailure<int>, int>(
        const ValueFailure.invalidNumericInput(failedValue: input),
      ),
    );
  });

  test('rejects zero and negative quantities', () {
    for (final input in ['0', '-3']) {
      final parsedValue = int.parse(input);

      expect(
        PositiveInteger(input).value,
        left<ValueFailure<int>, int>(
          ValueFailure.belowMinimum(
            failedValue: parsedValue,
            minimum: 1,
          ),
        ),
      );
    }
  });

  test('uses the parsed quantity for equality', () {
    expect(PositiveInteger('02'), PositiveInteger('2'));
  });
}
