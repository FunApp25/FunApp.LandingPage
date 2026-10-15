import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';

/// Provider-neutral boundary for Founding Friend registration submissions.
abstract interface class FoundingFriendRegistrationRepositoryInterface {
  /// Performs one logical registration submission.
  Future<Either<AppFailure, Unit>> submitFoundingFriendRegistration(
    FoundingFriendRegistration registration,
  );
}
