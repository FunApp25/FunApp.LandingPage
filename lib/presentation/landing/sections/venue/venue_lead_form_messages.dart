import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';

/// Returns localized validation copy for [value], or null when it is valid.
String? venueLeadValidationMessage<T>(
  AppLocalizations l10n,
  ValueObject<T> value,
) => value.value.fold<String?>(
  (failure) => switch (failure) {
    EmptyString() => l10n.venueLeadValidationRequired,
    MultiLineString() => l10n.venueLeadValidationSingleLine,
    InvalidEmail() => l10n.venueLeadValidationEmail,
    InvalidUrl() => l10n.venueLeadValidationWebsite,
    InvalidNumericInput() => l10n.venueLeadValidationNumbersOnly,
    BelowMinimum() => l10n.venueLeadValidationPositiveInteger,
  },
  (_) => null,
);
