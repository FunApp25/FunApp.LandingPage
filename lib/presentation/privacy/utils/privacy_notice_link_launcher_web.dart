import 'package:web/web.dart' as web;

/// Opens the approved Privacy Notice link in the current browser context.
void launchPrivacyNoticeLinkImpl(Uri uri) {
  web.window.location.href = uri.toString();
}
