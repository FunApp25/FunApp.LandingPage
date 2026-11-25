import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_exception.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_interface.dart';
import 'package:fun_app_landing_page/data/user_registration/models/here_and_now_registration_dto.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/here_and_now_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/here_and_now_registration_repository_interface.dart';

/// Here & Now repository backed by the configured registration data source.
final class HereAndNowRegistrationRepository
    implements HereAndNowRegistrationRepositoryInterface {
  /// Creates a repository backed by [UserRegistrationDataSourceInterface].
  const HereAndNowRegistrationRepository(this._dataSource);

  final UserRegistrationDataSourceInterface _dataSource;

  @override
  Future<Either<AppFailure, Unit>> submitHereAndNowRegistration(
    HereAndNowRegistration registration,
  ) async {
    if (registration.isValid) {
      try {
        await _dataSource.submitHereAndNowRegistration(
          HereAndNowRegistrationDto.fromValidDomain(registration),
        );
        return right(unit);
      } on UserRegistrationServiceUnavailableException {
        return left(const AppFailure.serviceUnavailable());
      } on UserRegistrationSubmissionRejectedException {
        return left(const AppFailure.submissionRejected());
      } on UserRegistrationUnexpectedDataSourceException {
        return left(const AppFailure.unexpected());
      } on Object {
        return left(const AppFailure.unexpected());
      }
    } else {
      return left(const AppFailure.unexpected());
    }
  }
}
