import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_exception.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_interface.dart';
import 'package:fun_app_landing_page/data/user_registration/models/founding_friend_registration_dto.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/founding_friend_registration_repository_interface.dart';

/// Founding Friend repository backed by the registration data source.
final class FoundingFriendRegistrationRepository
    implements FoundingFriendRegistrationRepositoryInterface {
  /// Creates a repository backed by [UserRegistrationDataSourceInterface].
  const FoundingFriendRegistrationRepository(this._dataSource);

  final UserRegistrationDataSourceInterface _dataSource;

  @override
  Future<Either<AppFailure, Unit>> submitFoundingFriendRegistration(
    FoundingFriendRegistration registration,
  ) async {
    if (registration.isValid) {
      try {
        await _dataSource.submitFoundingFriendRegistration(
          FoundingFriendRegistrationDto.fromValidDomain(registration),
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
