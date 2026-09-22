import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/failures/errors.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';

void main() {
  test('valid values expose validity, unit, and trusted value', () {
    final valueObject = _TestValueObject(right('value'));

    expect(valueObject.isValid(), isTrue);
    expect(
      valueObject.failureOrUnit,
      right<ValueFailure<dynamic>, Unit>(unit),
    );
    expect(valueObject.getOrCrash(), 'value');
  });

  test('invalid values expose failure and throw only on trusted access', () {
    const failure = ValueFailure<String>.invalidEmail(
      failedValue: 'invalid',
    );
    final valueObject = _TestValueObject(
      left<ValueFailure<String>, String>(failure),
    );

    expect(valueObject.isValid(), isFalse);
    expect(
      valueObject.failureOrUnit,
      left<ValueFailure<dynamic>, Unit>(failure),
    );
    expect(valueObject.getOrCrash, throwsA(isA<UnexpectedValueError>()));
  });

  test('uses runtime type and Either value for equality and hash code', () {
    final first = _TestValueObject(right('value'));
    final second = _TestValueObject(right('value'));
    final different = _TestValueObject(right('other'));

    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(first, isNot(different));
  });
}

class _TestValueObject extends ValueObject<String> {
  const _TestValueObject(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
}
