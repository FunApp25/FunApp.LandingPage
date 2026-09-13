import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/validators/value_validators.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';

/// A person's present first or last name.
class PersonalName extends ValueObject<String> {
  /// Creates a [PersonalName] without rewriting [input].
  factory PersonalName(String input) => PersonalName._(
    validateRequiredString(input).flatMap(validateSingleLine),
  );

  const PersonalName._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
}
