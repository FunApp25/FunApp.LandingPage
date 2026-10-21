import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';

/// Raw first-party payment transport boundary.
abstract interface class FoundingFriendPaymentDataSourceInterface {
  /// Requests one hosted Checkout Session.
  Future<FoundingFriendCheckout> createCheckout({
    required String email,
    required String attemptId,
  });

  /// Retrieves one sanitized payment verification result.
  Future<FoundingFriendPaymentVerification> verifyCheckout(String sessionId);
}
