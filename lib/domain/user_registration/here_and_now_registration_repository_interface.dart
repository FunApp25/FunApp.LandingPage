import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/here_and_now_registration.dart';

/// Provider-neutral boundary for Here & Now waitlist submissions.
abstract interface class HereAndNowRegistrationRepositoryInterface {
  /// Performs one logical registration submission.
  Future<Either<AppFailure, Unit>> submitHereAndNowRegistration(
    HereAndNowRegistration registration,
  );
}
