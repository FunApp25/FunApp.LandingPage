import 'package:flutter/widgets.dart';
import 'package:fun_app_landing_page/presentation/core/utils/document_language_stub.dart'
    if (dart.library.js_interop) 'document_language_web.dart'
    as document_language;

/// Returns the language code for the locale already resolved by Flutter.
String documentLanguageFor(Locale resolvedLocale) =>
    resolvedLocale.languageCode;

/// Keeps the host document language aligned with Flutter's resolved locale.
void synchronizeDocumentLanguage(Locale resolvedLocale) {
  document_language.setDocumentLanguage(
    documentLanguageFor(resolvedLocale),
  );
}
