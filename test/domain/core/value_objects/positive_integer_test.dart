import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/positive_integer.dart';

void main() {
  for (final (input, valid) in [
    ('1', true),
    ('9007199254740991', true),
    ('9007199254740992', false),
    ('9007199254740993', false),
    ('999999999999999999999999999999999999999999', false),
    ('', false),
    (' ', false),
    ('many', false),
    ('-1', false),
    ('0', false),
    ('1.5', false),
    ('1e3', false),
  ]) {
    test('quantity boundary $input is valid: $valid', () {
      final quantity = PositiveInteger(input);
      expect(quantity.isValid(), valid);
      if (valid) {
        expect(quantity.getOrCrash().toString(), input);
      }
    });
  }

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
