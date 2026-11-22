import 'package:fun_app_landing_page/core/config/venue_booking_url_stub.dart'
    if (dart.library.js_interop) 'package:fun_app_landing_page/core/config/venue_booking_url_web.dart';

/// Reads the optional public booking destination supplied at build time.
final Uri? venueBookingUrl = parseVenueBookingUrl(
  const String.fromEnvironment('FUN_APP_VENUE_BOOKING_URL'),
);

/// Accepts an absolute HTTPS destination without browser URL repair.
Uri? parseVenueBookingUrl(String value) {
  final authority = _httpsAuthority.firstMatch(value);
  if (authority == null || _invalidCharacters.hasMatch(value)) {
    return null;
  }

  // Validate the raw port before Uri can normalize it or parse an overflow.
  final rawPort = authority.group(1);
  final port = rawPort == null ? 443 : int.tryParse(rawPort);
  if (port == null || port < 1 || port > 65535) {
    return null;
  }

  final uri = Uri.tryParse(value);
  if (uri != null &&
      _isValidHost(uri.host) &&
      isBrowserHttpsUrl(uri.toString())) {
    return uri;
  }
  return null;
}

final _httpsAuthority = RegExp(
  r'^https://(?:\[[^/?#\]@%]+\]|[^:/?#\[\]@%]+)(?::([0-9]+))?(?=[/?#]|$)',
  caseSensitive: false,
);
final _invalidCharacters = RegExp(
  r'[\s\x00-\x1f\x7f\\<>"{}|^\x60]|%(?![\da-fA-F]{2})',
);
final _hostname = RegExp(
  r'^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)*'
  r'[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.?$',
  caseSensitive: false,
);
final _numericLabel = RegExp(
  r'(?:^|\.)(?:[0-9]+|0x[0-9a-f]*)\.?$',
  caseSensitive: false,
);

bool _isValidHost(String host) {
  if (host.contains(':')) {
    try {
      Uri.parseIPv6Address(host);
      return true;
    } on FormatException {
      return false;
    }
  } else if (_hostname.hasMatch(host) && host.length <= 253) {
    if (_numericLabel.hasMatch(host)) {
      try {
        final octets = Uri.parseIPv4Address(host);
        return octets.join('.') == host;
      } on FormatException {
        return false;
      }
    }
    return true;
  }
  return false;
}
