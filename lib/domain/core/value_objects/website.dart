import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/validators/value_validators.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';

/// A required HTTP or HTTPS website URL.
class Website extends ValueObject<String> {
  /// Creates a [Website] without normalizing or resolving [input].
  factory Website(String input) => Website._(
    validateRequiredString(
      input,
    ).flatMap(validateSingleLine).flatMap(validateWebsiteUrl),
  );

  const Website._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
}
