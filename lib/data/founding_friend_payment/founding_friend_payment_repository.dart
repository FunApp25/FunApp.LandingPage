import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/data_sources/founding_friend_payment_data_source_exception.dart';
import 'package:fun_app_landing_page/data/founding_friend_payment/data_sources/founding_friend_payment_data_source_interface.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/founding_friend_payment_repository_interface.dart';

/// Provider-neutral repository backed by the first-party payment Worker.
final class FoundingFriendPaymentRepository
    implements FoundingFriendPaymentRepositoryInterface {
  /// Creates the repository.
  const FoundingFriendPaymentRepository(this._dataSource);

  final FoundingFriendPaymentDataSourceInterface _dataSource;

  @override
  Future<Either<AppFailure, FoundingFriendCheckout>> createCheckout({
    required String email,
    required String attemptId,
  }) async {
    try {
      return right(
        await _dataSource.createCheckout(email: email, attemptId: attemptId),
      );
    } on FoundingFriendPaymentServiceUnavailableException {
      return left(const AppFailure.serviceUnavailable());
    } on FoundingFriendPaymentRejectedException {
      return left(const AppFailure.submissionRejected());
    } on Object {
      return left(const AppFailure.unexpected());
    }
  }

  @override
  Future<Either<AppFailure, FoundingFriendPaymentVerification>> verifyCheckout(
    String sessionId,
  ) async {
    try {
      return right(await _dataSource.verifyCheckout(sessionId));
    } on FoundingFriendPaymentServiceUnavailableException {
      return left(const AppFailure.serviceUnavailable());
    } on FoundingFriendPaymentRejectedException {
      return left(const AppFailure.submissionRejected());
    } on Object {
      return left(const AppFailure.unexpected());
    }
  }
}
