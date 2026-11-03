import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';

/// Returns localized validation copy for a registration [value].
String? userSignUpValidationMessage<T>(
  AppLocalizations l10n,
  Either<ValueFailure<dynamic>, T> value,
) => value.fold<String?>(
  (failure) => switch (failure) {
    TooLong(:final maximumLength) => l10n.validationMaxLength(maximumLength),
    EmptyString() => l10n.userSignUpValidationRequired,
    MultiLineString() => l10n.venueLeadValidationSingleLine,
    InvalidEmail() => l10n.userSignUpValidationEmail,
    InvalidNumericInput() => l10n.userSignUpValidationInteger,
    InvalidUrl() || BelowMinimum() => l10n.userSignUpValidationRequired,
  },
  (_) => null,
);
