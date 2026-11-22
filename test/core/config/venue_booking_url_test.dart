import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/config/venue_booking_url.dart';

void main() {
  test('accepts HTTPS and retains the configured destination', () {
    const value = 'https://booking.example.test/team?source=a%20b#slots';
    expect(parseVenueBookingUrl(value)?.toString(), value);
    const ipv6 = 'https://[2001:db8::1]:8443/team';
    expect(parseVenueBookingUrl(ipv6)?.toString(), ipv6);
  });

  test('rejects missing, malformed, and unsafe booking configuration', () {
    for (final value in [
      '',
      'javascript:alert(1)',
      'data:text/html,example',
      'http://booking.example.test',
      '/meet',
      'https:///meet',
      'https:booking.example.test',
      'https://user@booking.example.test',
      'https://booking.example.test:bad',
      'https://booking.example.test:+443',
      'https://[2001:db8::1]:+443',
      'https://[v1.foo:bar]:8443/team',
      'https://booking.example.test:',
      'https://booking.example.test:65536',
      'https://booking.example.test:999999999999999999999999',
      'https://booking.example.test/space here',
      'https://booking.example.test/%',
      r'https://booking.example.test\other.example.test',
      'https://book..example.test',
      'https://book_ing.example.test',
      'https://999.0.0.1',
      'https://0x7f000001',
    ]) {
      expect(parseVenueBookingUrl(value), isNull, reason: value);
    }
  });
}
