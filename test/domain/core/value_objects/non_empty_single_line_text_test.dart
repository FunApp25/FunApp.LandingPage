import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';

void main() {
  test('accepts and preserves present single-line text', () {
    const input = '  Venue role  ';

    expect(
      NonEmptySingleLineText(input).value,
      right<ValueFailure<String>, String>(input),
    );
  });

  test('rejects whitespace-only text before single-line validation', () {
    const input = ' \n ';

    expect(
      NonEmptySingleLineText(input).value,
      left<ValueFailure<String>, String>(
        const ValueFailure.emptyString(failedValue: input),
      ),
    );
  });

  test('rejects multiline text after required validation', () {
    const input = 'Venue\nrole';

    expect(
      NonEmptySingleLineText(input).value,
      left<ValueFailure<String>, String>(
        const ValueFailure.multiLineString(failedValue: input),
      ),
    );
  });

  test('uses validated value equality', () {
    expect(
      NonEmptySingleLineText('Manager'),
      NonEmptySingleLineText('Manager'),
    );
  });
}
