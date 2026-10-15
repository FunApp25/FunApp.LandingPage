import 'package:fun_app_landing_page/data/user_registration/models/founding_friend_registration_dto.dart';
import 'package:fun_app_landing_page/data/user_registration/models/here_and_now_registration_dto.dart';

/// Provider boundary for the two independent registration workflows.
abstract interface class UserRegistrationDataSourceInterface {
  /// Submits one validated Here & Now DTO.
  Future<void> submitHereAndNowRegistration(
    HereAndNowRegistrationDto registration,
  );

  /// Submits one validated Founding Friend DTO.
  Future<void> submitFoundingFriendRegistration(
    FoundingFriendRegistrationDto registration,
  );
}
