import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_checkout_bloc.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/utils/checkout_redirect_stub.dart'
    if (dart.library.js_interop) 'checkout_redirect_web.dart'
    as implementation;

/// Creates one Checkout BLoC for a payment route lifecycle.
typedef FoundingFriendCheckoutBlocFactory =
    FoundingFriendCheckoutBloc Function();

/// Browser redirect callback used by payment presentation tests.
typedef FoundingFriendCheckoutRedirect = Future<bool> Function(Uri uri);

/// Redirects the current browser tab to an already validated Checkout URL.
Future<bool> redirectToCheckout(Uri checkoutUrl) async =>
    isAllowedCheckoutRedirect(checkoutUrl)
    ? implementation.redirectToCheckout(checkoutUrl)
    : false;

/// Starts a validated redirect and reports navigation failure to [bloc].
Future<void> startFoundingFriendCheckoutRedirect({
  required FoundingFriendCheckoutBloc bloc,
  required Uri checkoutUrl,
  required FoundingFriendCheckoutRedirect redirect,
}) async {
  bloc.add(const FoundingFriendCheckoutRedirectStarted());
  final redirected = await redirect(checkoutUrl);
  if (!redirected && !bloc.isClosed) {
    bloc.add(const FoundingFriendCheckoutRedirectFailed());
  }
}

/// Defense-in-depth validation for Stripe-hosted and loopback mock redirects.
bool isAllowedCheckoutRedirect(Uri uri) {
  final isStripe = uri.scheme == 'https' && uri.host == 'checkout.stripe.com';
  final isLoopback =
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      (uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host == '::1');
  return uri.hasAuthority && uri.userInfo.isEmpty && (isStripe || isLoopback);
}
