import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/privacy/pages/privacy_notice_page.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';

void main() {
  test('privacy hash URL preserves only the current origin', () {
    expect(
      privacyNoticeUrlFor(Uri.parse('https://funapp.world/#/')).toString(),
      PrivacyNoticePage.canonicalUrl,
    );
    expect(
      privacyNoticeUrlFor(Uri.parse('http://localhost:4321/?draft=private#/'))
          .toString(),
      'http://localhost:4321/#/privacy',
    );
  });
}
