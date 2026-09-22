import 'dart:js_interop';

@JS('Document')
extension type _Document._(JSObject _) implements JSObject {
  external _Element? get documentElement;
}

@JS('Element')
extension type _Element._(JSObject _) implements JSObject {
  external void setAttribute(String name, String value);
}

@JS('document')
external _Document get _document;

/// Updates the root HTML element for browser and assistive-technology clients.
void setDocumentLanguage(String languageCode) {
  _document.documentElement?.setAttribute('lang', languageCode);
}
