import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/age.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';

part 'founding_friend_registration.freezed.dart';

/// Provider-neutral details submitted for Founding Friend registration.
@freezed
abstract class FoundingFriendRegistration with _$FoundingFriendRegistration {
  /// Creates a [FoundingFriendRegistration].
  const factory FoundingFriendRegistration({
    required PersonalName firstName,
    required PersonalName lastName,
    required EmailAddress email,
    required Age age,
    required NonEmptySingleLineText country,
    required Option<NonEmptySingleLineText> gender,
    required Option<String> usageReason,
    required bool marketingConsent,
  }) = _FoundingFriendRegistration;

  const FoundingFriendRegistration._();

  /// Creates an incomplete editable draft.
  factory FoundingFriendRegistration.empty() => FoundingFriendRegistration(
    firstName: PersonalName(''),
    lastName: PersonalName(''),
    email: EmailAddress(''),
    age: Age(''),
    country: NonEmptySingleLineText(''),
    gender: none(),
    usageReason: none(),
    marketingConsent: false,
  );

  /// The first validation failure in product-field order, when present.
  Option<ValueFailure<dynamic>> get failureOption {
    final failuresOrUnit = <Either<ValueFailure<dynamic>, Unit>>[
      firstName.failureOrUnit,
      lastName.failureOrUnit,
      email.failureOrUnit,
      age.failureOrUnit,
      country.failureOrUnit,
      gender.fold(
        () => right<ValueFailure<dynamic>, Unit>(unit),
        (value) => value.failureOrUnit,
      ),
    ];

    return failuresOrUnit
        .firstWhere(
          (failureOrUnit) => failureOrUnit.isLeft(),
          orElse: () => right<ValueFailure<dynamic>, Unit>(unit),
        )
        .fold(some, (_) => none<ValueFailure<dynamic>>());
  }

  /// Whether every required and present optional value is valid.
  bool get isValid => failureOption.isNone();
}
