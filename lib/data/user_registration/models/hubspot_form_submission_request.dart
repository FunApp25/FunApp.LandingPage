import 'package:fun_app_landing_page/data/user_registration/models/founding_friend_registration_dto.dart';
import 'package:fun_app_landing_page/data/user_registration/models/here_and_now_registration_dto.dart';

/// Exact HubSpot contact-property names used by both registration forms.
abstract final class HubSpotRegistrationFields {
  /// Contact first name.
  static const firstName = 'firstname';

  /// Contact last name.
  static const lastName = 'lastname';

  /// Contact email address.
  static const email = 'email';

  /// Contact numeric age.
  static const age = 'age';

  /// Contact gender enumeration.
  static const gender = 'gender';

  /// Contact country enumeration.
  static const country = 'country';

  /// Contact free-text intended use.
  static const usageReason = 'usage_reason';

  /// Contact marketing email preference.
  static const marketingConsent = 'marketing_consent';
}

/// Accepted values confirmed for HubSpot's contact gender enumeration.
const hubSpotRegistrationGenderValues = <String>{
  'Man',
  'Woman',
  'Non-binary',
  'Prefer not to answer',
};

/// Provider request for HubSpot's unauthenticated Forms v3 endpoint.
final class HubSpotFormSubmissionRequest {
  const HubSpotFormSubmissionRequest._(this.fields);

  /// Maps a Here & Now DTO to exact HubSpot property values.
  factory HubSpotFormSubmissionRequest.hereAndNow(
    HereAndNowRegistrationDto registration,
  ) => HubSpotFormSubmissionRequest._(
    _sharedFields(
      firstName: registration.firstName,
      lastName: registration.lastName,
      email: registration.email,
      age: registration.age,
      gender: registration.gender,
      usageReason: registration.usageReason,
      marketingConsent: registration.marketingConsent,
    ),
  );

  /// Maps a Founding Friend DTO to exact HubSpot property values.
  factory HubSpotFormSubmissionRequest.foundingFriend(
    FoundingFriendRegistrationDto registration,
  ) => HubSpotFormSubmissionRequest._([
    ..._sharedFields(
      firstName: registration.firstName,
      lastName: registration.lastName,
      email: registration.email,
      age: registration.age,
      gender: registration.gender,
      usageReason: registration.usageReason,
      marketingConsent: registration.marketingConsent,
    ),
    HubSpotFormField(
      name: HubSpotRegistrationFields.country,
      value: registration.country,
    ),
  ]);

  /// Ordered fields included in the provider request.
  final List<HubSpotFormField> fields;

  /// Serializes only the Forms v3 field collection.
  Map<String, Object> toJson() => {
    'fields': [for (final field in fields) field.toJson()],
  };

  static List<HubSpotFormField> _sharedFields({
    required String firstName,
    required String lastName,
    required String email,
    required int age,
    required String? gender,
    required String? usageReason,
    required bool marketingConsent,
  }) {
    if (gender != null && !hubSpotRegistrationGenderValues.contains(gender)) {
      throw const FormatException('Unsupported HubSpot gender value.');
    }

    return [
      HubSpotFormField(
        name: HubSpotRegistrationFields.firstName,
        value: firstName,
      ),
      HubSpotFormField(
        name: HubSpotRegistrationFields.lastName,
        value: lastName,
      ),
      HubSpotFormField(name: HubSpotRegistrationFields.email, value: email),
      HubSpotFormField(
        name: HubSpotRegistrationFields.age,
        value: age.toString(),
      ),
      if (gender != null)
        HubSpotFormField(
          name: HubSpotRegistrationFields.gender,
          value: gender,
        ),
      if (usageReason != null)
        HubSpotFormField(
          name: HubSpotRegistrationFields.usageReason,
          value: usageReason,
        ),
      HubSpotFormField(
        name: HubSpotRegistrationFields.marketingConsent,
        value: marketingConsent.toString(),
      ),
    ];
  }
}

/// One string-valued field accepted by the Forms v3 submission endpoint.
final class HubSpotFormField {
  /// Creates one HubSpot field entry.
  const HubSpotFormField({required this.name, required this.value});

  /// Exact HubSpot internal property name.
  final String name;

  /// Forms API string representation of the property value.
  final String value;

  /// Serializes this entry for the Forms API.
  Map<String, String> toJson() => {'name': name, 'value': value};
}
