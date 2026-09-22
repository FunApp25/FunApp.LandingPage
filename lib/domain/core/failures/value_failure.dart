import 'package:freezed_annotation/freezed_annotation.dart';

part 'value_failure.freezed.dart';

/// A stable validation failure that retains the rejected input.
@freezed
sealed class ValueFailure<T> with _$ValueFailure<T> {
  const ValueFailure._();

  /// Creates a failure for a required string with no non-whitespace content.
  const factory ValueFailure.emptyString({
    required String failedValue,
  }) = EmptyString<T>;

  /// Creates a failure for a string containing a line break.
  const factory ValueFailure.multiLineString({
    required String failedValue,
  }) = MultiLineString<T>;

  /// Creates a failure for an invalid email address.
  const factory ValueFailure.invalidEmail({
    required String failedValue,
  }) = InvalidEmail<T>;

  /// Creates a failure for an invalid HTTP or HTTPS website URL.
  const factory ValueFailure.invalidUrl({
    required String failedValue,
  }) = InvalidUrl<T>;

  /// Creates a failure for text that cannot satisfy a numeric requirement.
  const factory ValueFailure.invalidNumericInput({
    required String failedValue,
  }) = InvalidNumericInput<T>;

  /// Creates a failure for a value below its inclusive minimum.
  const factory ValueFailure.belowMinimum({
    required T failedValue,
    required T minimum,
  }) = BelowMinimum<T>;
}
