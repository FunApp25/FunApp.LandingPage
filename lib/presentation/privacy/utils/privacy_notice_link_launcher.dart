import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher_stub.dart'
    if (dart.library.js_interop) 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher_web.dart';

/// Opens one approved external link from the Privacy Notice.
void launchPrivacyNoticeLink(Uri uri) => launchPrivacyNoticeLinkImpl(uri);

/// Builds the hash route on the current origin for local and production runs.
Uri privacyNoticeUrlFor(Uri base) => Uri(
  scheme: base.scheme,
  host: base.host,
  port: base.hasPort ? base.port : null,
  path: '/',
  fragment: '/privacy',
);

/// Opens an approved public destination in another browser context.
void launchExternalLinkInNewTab(Uri uri) => launchExternalLinkInNewTabImpl(uri);
