import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';

/// Validated provider-neutral values for a Founding Friend submission.
final class FoundingFriendRegistrationDto {
  /// Creates a [FoundingFriendRegistrationDto].
  const FoundingFriendRegistrationDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    required this.country,
    required this.gender,
    required this.usageReason,
    required this.marketingConsent,
  });

  /// Extracts values from an aggregate already validated by its repository.
  factory FoundingFriendRegistrationDto.fromValidDomain(
    FoundingFriendRegistration registration,
  ) => FoundingFriendRegistrationDto(
    firstName: registration.firstName.getOrCrash(),
    lastName: registration.lastName.getOrCrash(),
    email: registration.email.getOrCrash(),
    age: registration.age.getOrCrash(),
    country: registration.country.getOrCrash(),
    gender: registration.gender.fold(
      () => null,
      (value) => value.getOrCrash(),
    ),
    usageReason: registration.usageReason.toNullable(),
    marketingConsent: registration.marketingConsent,
  );

  /// Validated first name, preserved without normalization.
  final String firstName;

  /// Validated last name, preserved without normalization.
  final String lastName;

  /// Validated email, preserved without normalization.
  final String email;

  /// Integer age with no eligibility threshold applied.
  final int age;

  /// Required HubSpot-compatible country enumeration value.
  final String country;

  /// Optional HubSpot-compatible gender value.
  final String? gender;

  /// Optional free-text usage reason.
  final String? usageReason;

  /// Optional marketing email preference.
  final bool marketingConsent;
}
