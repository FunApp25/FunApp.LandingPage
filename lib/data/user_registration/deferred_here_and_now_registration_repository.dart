import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/here_and_now_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/here_and_now_registration_repository_interface.dart';

/// Fail-closed repository used unless registration transport is authorized.
final class DeferredHereAndNowRegistrationRepository
    implements HereAndNowRegistrationRepositoryInterface {
  @override
  Future<Either<AppFailure, Unit>> submitHereAndNowRegistration(
    HereAndNowRegistration registration,
  ) async => left(const AppFailure.serviceUnavailable());
}
