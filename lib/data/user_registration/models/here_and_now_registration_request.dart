import 'package:fun_app_landing_page/data/user_registration/models/here_and_now_registration_dto.dart';

/// First-party JSON request for Here & Now registration.
final class HereAndNowRegistrationRequest {
  const HereAndNowRegistrationRequest._(this._registration);

  /// Creates the Worker request from a validated provider-neutral DTO.
  factory HereAndNowRegistrationRequest.fromDto(
    HereAndNowRegistrationDto registration,
  ) => HereAndNowRegistrationRequest._(registration);

  final HereAndNowRegistrationDto _registration;

  /// Serializes only the Fun App-owned registration contract.
  Map<String, Object> toJson() {
    final request = <String, Object>{
      'firstName': _registration.firstName,
      'lastName': _registration.lastName,
      'email': _registration.email,
      'age': _registration.age,
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
