import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
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

  /// The first validation failure in product-field order, when present.
  Option<ValueFailure<dynamic>> get failureOption {
    final failuresOrUnit = <Either<ValueFailure<dynamic>, Unit>>[
      venueName.failureOrUnit,
      venueType.fold(
        () => right<ValueFailure<dynamic>, Unit>(unit),
        (value) => value.failureOrUnit,
      ),
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
      website.failureOrUnit,
      firstName.failureOrUnit,
      lastName.failureOrUnit,
      role.failureOrUnit,
      email.failureOrUnit,
      phoneNumber.fold(
        () => right<ValueFailure<dynamic>, Unit>(unit),
        (value) => value.failureOrUnit,
      ),
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
