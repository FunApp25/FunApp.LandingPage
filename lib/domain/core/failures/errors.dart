import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';

/// An error raised when invalid input reaches a trusted-value code path.
class UnexpectedValueError extends Error {
  /// Creates an [UnexpectedValueError] for [valueFailure].
  UnexpectedValueError(this.valueFailure);

  /// The validation failure that made the value unsafe to use.
  final ValueFailure<dynamic> valueFailure;

  @override
  String toString() => Error.safeToString(
    'Unexpected value at an unrecoverable point.',
  );
}
