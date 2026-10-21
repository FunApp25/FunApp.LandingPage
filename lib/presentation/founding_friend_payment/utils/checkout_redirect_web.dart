import 'package:web/web.dart' as web;

/// Navigates the current browser tab to a prevalidated Checkout URL.
Future<bool> redirectToCheckout(Uri checkoutUrl) async {
  try {
    web.window.location.assign(checkoutUrl.toString());
    return true;
  } on Object {
    return false;
  }
}
