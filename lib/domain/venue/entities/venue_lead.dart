import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/validators/value_validators.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/phone_number.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/positive_integer.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/website.dart';

part 'venue_lead.freezed.dart';

/// Provider-neutral information supplied by a prospective venue contact.
@freezed
abstract class VenueLead with _$VenueLead {
  /// Creates a [VenueLead].
  const factory VenueLead({
    required NonEmptySingleLineText venueName,
    required Option<NonEmptySingleLineText> venueType,
    required Option<NonEmptySingleLineText> chainStatus,
    required Option<PositiveInteger> venueCount,
    required Option<PositiveInteger> venueCapacity,
    required Website website,
    required PersonalName firstName,
    required PersonalName lastName,
    required NonEmptySingleLineText role,
    required EmailAddress email,
    required Option<PhoneNumber> phoneNumber,
  }) = _VenueLead;

  const VenueLead._();

  /// Creates an incomplete draft with invalid empty required values.
  factory VenueLead.empty() => VenueLead(
    venueName: NonEmptySingleLineText(''),
    venueType: none(),
    chainStatus: none(),
    venueCount: none(),
    venueCapacity: none(),
    website: Website(''),
    firstName: PersonalName(''),
    lastName: PersonalName(''),
    role: NonEmptySingleLineText(''),
    email: EmailAddress(''),
    phoneNumber: none(),
  );

  /// Validates venueName against its existing submission contract.
  Either<ValueFailure<dynamic>, Unit> get venueNameValidation => venueName.value
      .flatMap((text) => validateMaxLength(text, 512))
      .map((_) => unit);

  /// Validates venueType against its existing submission contract.
  Either<ValueFailure<dynamic>, Unit> get venueTypeValidation => venueType.fold(
    () => right(unit),
    (value) => value.value
        .flatMap((text) => validateMaxLength(text, 256))
        .map((_) => unit),
  );

  /// Validates website against its existing submission contract.
  Either<ValueFailure<dynamic>, Unit> get websiteValidation => website.value
      .flatMap((text) => validateMaxLength(text, 2048))
      .map((_) => unit);

  /// Validates firstName against its existing submission contract.
  Either<ValueFailure<dynamic>, Unit> get firstNameValidation => firstName.value
      .flatMap((text) => validateMaxLength(text, 256))
      .map((_) => unit);

  /// Validates lastName against its existing submission contract.
  Either<ValueFailure<dynamic>, Unit> get lastNameValidation => lastName.value
      .flatMap((text) => validateMaxLength(text, 256))
      .map((_) => unit);

  /// Validates role against its existing submission contract.
  Either<ValueFailure<dynamic>, Unit> get roleValidation => role.value
      .flatMap((text) => validateMaxLength(text, 256))
      .map((_) => unit);

  /// Validates email against its existing submission contract.
  Either<ValueFailure<dynamic>, Unit> get emailValidation => email.value
      .flatMap((text) => validateMaxLength(text, 320))
      .map((_) => unit);

  /// Validates phoneNumber against its existing submission contract.
  Either<ValueFailure<dynamic>, Unit> get phoneNumberValidation =>
      phoneNumber.fold(
        () => right(unit),
        (value) => value.value
            .flatMap((text) => validateMaxLength(text, 64))
            .map((_) => unit),
      );

  /// The first validation failure in product-field order, when present.
  Option<ValueFailure<dynamic>> get failureOption {
    final failuresOrUnit = <Either<ValueFailure<dynamic>, Unit>>[
      venueNameValidation,
      venueTypeValidation,
      chainStatus.fold(
        () => right<ValueFailure<dynamic>, Unit>(unit),
        (value) => value.failureOrUnit,
      ),
      venueCount.fold(
        () => right<ValueFailure<dynamic>, Unit>(unit),
        (value) => value.failureOrUnit,
      ),
      venueCapacity.fold(
        () => right<ValueFailure<dynamic>, Unit>(unit),
        (value) => value.failureOrUnit,
      ),
      websiteValidation,
      firstNameValidation,
      lastNameValidation,
      roleValidation,
      emailValidation,
      phoneNumberValidation,
    ];

    return failuresOrUnit
        .firstWhere(
          (failureOrUnit) => failureOrUnit.isLeft(),
          orElse: () => right<ValueFailure<dynamic>, Unit>(unit),
        )
        .fold(
          some,
          (_) => none<ValueFailure<dynamic>>(),
        );
  }

  /// The first validation failure, or [unit] when the lead is valid.
  Either<ValueFailure<dynamic>, Unit> get failureOrUnit => failureOption.fold(
    () => right(unit),
    left,
  );

  /// Whether every required and present optional value is valid.
  bool get isValid => failureOption.isNone();
}
