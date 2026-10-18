import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/founding_friend_registration_repository_interface.dart';

/// Fail-closed repository used unless registration transport is authorized.
final class DeferredFoundingFriendRegistrationRepository
    implements FoundingFriendRegistrationRepositoryInterface {
  @override
  Future<Either<AppFailure, Unit>> submitFoundingFriendRegistration(
    FoundingFriendRegistration registration,
  ) async => left(const AppFailure.serviceUnavailable());
}
