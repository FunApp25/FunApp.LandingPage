import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';

/// Provider-neutral boundary for Founding Friend Checkout and verification.
abstract interface class FoundingFriendPaymentRepositoryInterface {
  /// Creates or safely retries one hosted Checkout attempt.
  Future<Either<AppFailure, FoundingFriendCheckout>> createCheckout({
    required String email,
    required String attemptId,
  });

  /// Retrieves and verifies one opaque Checkout Session.
  Future<Either<AppFailure, FoundingFriendPaymentVerification>> verifyCheckout(
    String sessionId,
  );
}
