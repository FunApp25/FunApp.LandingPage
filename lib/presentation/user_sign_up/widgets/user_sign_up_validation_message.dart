import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';

/// Returns localized validation copy for a registration [value].
String? userSignUpValidationMessage<T>(
  AppLocalizations l10n,
  ValueObject<T> value,
) => value.value.fold<String?>(
  (failure) => switch (failure) {
    EmptyString() => l10n.userSignUpValidationRequired,
    MultiLineString() => l10n.venueLeadValidationSingleLine,
    InvalidEmail() => l10n.userSignUpValidationEmail,
    InvalidNumericInput() => l10n.userSignUpValidationInteger,
    InvalidUrl() || BelowMinimum() => l10n.userSignUpValidationRequired,
  },
  (_) => null,
);
