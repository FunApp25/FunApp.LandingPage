import 'package:fun_app_landing_page/data/user_registration/models/founding_friend_registration_dto.dart';

/// First-party JSON request for Founding Friend registration.
final class FoundingFriendRegistrationRequest {
  const FoundingFriendRegistrationRequest._(this._registration);

  /// Creates the Worker request from a validated provider-neutral DTO.
  factory FoundingFriendRegistrationRequest.fromDto(
    FoundingFriendRegistrationDto registration,
  ) => FoundingFriendRegistrationRequest._(registration);

  final FoundingFriendRegistrationDto _registration;

  /// Serializes only the Fun App-owned registration contract.
  Map<String, Object> toJson() {
    final request = <String, Object>{
      'firstName': _registration.firstName,
      'lastName': _registration.lastName,
      'email': _registration.email,
      'age': _registration.age,
      'country': _registration.country,
      'marketingConsent': _registration.marketingConsent,
    };

    if (_registration.gender case final gender?) {
      request['gender'] = gender;
    }
    if (_registration.usageReason case final usageReason?) {
      request['usageReason'] = usageReason;
    }

    return request;
  }
}
