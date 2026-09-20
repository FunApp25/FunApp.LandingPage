import 'package:web/web.dart' as web;

/// Opens the approved Privacy Notice link in the current browser context.
void launchPrivacyNoticeLinkImpl(Uri uri) {
  web.window.location.href = uri.toString();
}

/// Requests a separate tab without passing application state in the URL.
void launchExternalLinkInNewTabImpl(Uri uri) {
  web.window.open(uri.toString(), '_blank', 'noopener,noreferrer');
}
