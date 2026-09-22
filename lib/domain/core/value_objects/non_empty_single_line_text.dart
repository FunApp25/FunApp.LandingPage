import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/validators/value_validators.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';

/// Present free text that must contain content and remain on one line.
class NonEmptySingleLineText extends ValueObject<String> {
  /// Creates a [NonEmptySingleLineText] without rewriting [input].
  factory NonEmptySingleLineText(String input) => NonEmptySingleLineText._(
    validateRequiredString(input).flatMap(validateSingleLine),
  );

  const NonEmptySingleLineText._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
}
