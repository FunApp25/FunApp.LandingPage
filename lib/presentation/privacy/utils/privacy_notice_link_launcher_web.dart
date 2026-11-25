import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Opens an approved contact link in the current browser context.
void launchContactLinkImpl(Uri uri) {
  web.window.location.href = uri.toString();
}

/// Requests a separate tab without passing application state in the URL.
void launchExternalLinkInNewTabImpl(Uri uri) {
  web.window.open(uri.toString(), '_blank', 'noopener,noreferrer');
}

/// Keeps native semantics URLs without duplicating Flutter callback navigation.
void Function() installLegalLinkNavigationImpl(String identifier) {
  final listener = ((web.Event event) {
    final target = event.target;
    if (target != null && target.isA<web.Element>()) {
      final anchor = (target as web.Element).closest(
        'a[flt-semantics-identifier="$identifier"]',
      );
      if (anchor != null) {
        // Flutter callbacks already select the correct tab and navigation mode.
        event.preventDefault();
      }
    }
  }).toJS;
  web.document.addEventListener('click', listener, true.toJS);
  return () => web.document.removeEventListener('click', listener, true.toJS);
}
