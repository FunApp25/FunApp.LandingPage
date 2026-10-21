import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/founding_friend_payment_repository_interface.dart';

/// Fail-closed payment repository used unless a transport is explicit.
final class DeferredFoundingFriendPaymentRepository
    implements FoundingFriendPaymentRepositoryInterface {
  @override
  Future<Either<AppFailure, FoundingFriendCheckout>> createCheckout({
    required String email,
    required String attemptId,
  }) async => left(const AppFailure.serviceUnavailable());

  @override
  Future<Either<AppFailure, FoundingFriendPaymentVerification>> verifyCheckout(
    String sessionId,
  ) async => left(const AppFailure.serviceUnavailable());
}
