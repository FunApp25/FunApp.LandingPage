import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fun_app_landing_page/domain/core/failures/errors.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';

/// Base class for immutable values that retain validation failures safely.
@immutable
abstract class ValueObject<T> {
  /// Creates a [ValueObject].
  const ValueObject();

  /// The validated value or its validation failure.
  Either<ValueFailure<T>, T> get value;

  /// The validation failure, or [unit] when this value is valid.
  Either<ValueFailure<dynamic>, Unit> get failureOrUnit => value.fold(
    (failure) => left<ValueFailure<dynamic>, Unit>(failure),
    (_) => right<ValueFailure<dynamic>, Unit>(unit),
  );

  /// Whether this object contains a valid value.
  bool isValid() => value.isRight();

  /// Returns the trusted value or throws [UnexpectedValueError].
  T getOrCrash() => value.fold(
    (failure) => throw UnexpectedValueError(failure),
    (validValue) => validValue,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is ValueObject<T> &&
          other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => value.fold(
    (failure) => failure.toString(),
    (validValue) => '$validValue',
  );
}
