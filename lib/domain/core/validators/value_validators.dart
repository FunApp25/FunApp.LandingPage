import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';

final _lineBreakRegex = RegExp(r'[\r\n]');
final _emailRegex = RegExp(
  r"^(?!.*\.\.)[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]{1,64}@(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$",
);
final _urlWhitespaceRegex = RegExp(r'\s');
final _numericStringRegex = RegExp(r'^[0-9]+$');
final _integerStringRegex = RegExp(r'^-?[0-9]+$');

/// Validates that [input] contains non-whitespace content without changing it.
Either<ValueFailure<String>, String> validateRequiredString(String input) {
  if (input.trim().isNotEmpty) {
    return right(input);
  } else {
    return left(ValueFailure.emptyString(failedValue: input));
  }
}

/// Validates that [input] contains no carriage-return or newline characters.
Either<ValueFailure<String>, String> validateSingleLine(String input) {
  if (!_lineBreakRegex.hasMatch(input)) {
    return right(input);
  } else {
    return left(ValueFailure.multiLineString(failedValue: input));
  }
}

/// Validates the structural format of an email address.
Either<ValueFailure<String>, String> validateEmail(String input) {
  if (_emailRegex.hasMatch(input)) {
    return right(input);
  } else {
    return left(ValueFailure.invalidEmail(failedValue: input));
  }
}

/// Validates an HTTP or HTTPS URL with a non-empty host.
Either<ValueFailure<String>, String> validateWebsiteUrl(String input) {
  final uri = Uri.tryParse(input);
  final isValidUrl =
      uri != null &&
      !_urlWhitespaceRegex.hasMatch(input) &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;

  if (isValidUrl) {
    return right(input);
  } else {
    return left(ValueFailure.invalidUrl(failedValue: input));
  }
}

/// Validates that [input] consists only of decimal digits.
Either<ValueFailure<String>, String> validateNumericString(String input) {
  if (_numericStringRegex.hasMatch(input)) {
    return right(input);
  } else {
    return left(ValueFailure.invalidNumericInput(failedValue: input));
  }
}

/// Parses a base-ten integer from a locale-independent textual input.
Either<ValueFailure<int>, int> validateInteger(String input) {
  final parsedValue = _integerStringRegex.hasMatch(input)
      ? int.tryParse(input)
      : null;

  if (parsedValue != null) {
    return right(parsedValue);
  } else {
    return left(ValueFailure.invalidNumericInput(failedValue: input));
  }
}

/// Validates that [input] is at least one.
Either<ValueFailure<int>, int> validatePositiveInteger(int input) {
  if (input >= 1) {
    return right(input);
  } else {
    return left(ValueFailure.belowMinimum(failedValue: input, minimum: 1));
  }
}
