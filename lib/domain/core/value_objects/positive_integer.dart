import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/validators/value_validators.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';

/// A positive integral quantity parsed from locale-independent text.
class PositiveInteger extends ValueObject<int> {
  /// Creates a [PositiveInteger] without throwing for invalid editable input.
  factory PositiveInteger(String input) => PositiveInteger._(
    validateInteger(input).flatMap(validatePositiveInteger),
  );

  const PositiveInteger._(this.value);

  @override
  final Either<ValueFailure<int>, int> value;
}
