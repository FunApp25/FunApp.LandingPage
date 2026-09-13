import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/validators/value_validators.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';

/// A required email address that preserves its original input.
class EmailAddress extends ValueObject<String> {
  /// Creates an [EmailAddress] without normalizing [input].
  factory EmailAddress(String input) => EmailAddress._(
    validateRequiredString(
      input,
    ).flatMap(validateSingleLine).flatMap(validateEmail),
  );

  const EmailAddress._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
}
