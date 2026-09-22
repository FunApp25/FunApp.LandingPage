import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/validators/value_validators.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';

/// A present phone identifier containing decimal digits only.
class PhoneNumber extends ValueObject<String> {
  /// Creates a [PhoneNumber] while preserving leading zeroes in [input].
  factory PhoneNumber(String input) => PhoneNumber._(
    validateRequiredString(
      input,
    ).flatMap(validateSingleLine).flatMap(validateNumericString),
  );

  const PhoneNumber._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
}
