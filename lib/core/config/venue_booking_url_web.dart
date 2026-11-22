import 'package:web/web.dart' as web;

/// Checks the same URL that will be passed to browser navigation.
bool isBrowserHttpsUrl(String value) {
  try {
    return web.URL(value).protocol == 'https:';
  } on Object {
    return false;
  }
}
