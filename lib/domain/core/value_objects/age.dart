import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/validators/value_validators.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';

/// An integer age with no product eligibility threshold applied.
class Age extends ValueObject<int> {
  /// Creates an [Age] without throwing for invalid editable input.
  factory Age(String input) => Age._(validateRequiredInteger(input));

  const Age._(this.value);

  @override
  final Either<ValueFailure<int>, int> value;
}
