@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';
import 'package:web/web.dart' as web;

void main() {
  test('managed semantic anchors do not duplicate callback navigation', () {
    final removeListener = installLegalLinkNavigation();
    final anchor = web.document.createElement('a')
      ..setAttribute('flt-semantics-identifier', managedLegalLinkIdentifier)
      ..setAttribute('href', '#/privacy');
    // Flutter handles clicks at the target; the guard must run in capture.
    final child = web.document.createElement('span')
      ..addEventListener(
        'click',
        ((web.Event event) {
          event.stopPropagation();
        }).toJS,
      );
    anchor.appendChild(child);
    web.document.body!.appendChild(anchor);
    addTearDown(() {
      anchor.remove();
      removeListener();
    });

    final click = web.MouseEvent(
      'click',
      web.MouseEventInit(bubbles: true, cancelable: true),
    );
    child.dispatchEvent(click);
    expect(click.defaultPrevented, isTrue);

    anchor
      ..removeAttribute('flt-semantics-identifier')
      ..removeAttribute('href');
    final unrelated = web.MouseEvent(
      'click',
      web.MouseEventInit(bubbles: true, cancelable: true),
    );
    child.dispatchEvent(unrelated);
    expect(unrelated.defaultPrevented, isFalse);

    removeListener();
    anchor.setAttribute('flt-semantics-identifier', managedLegalLinkIdentifier);
    final disposed = web.MouseEvent(
      'click',
      web.MouseEventInit(bubbles: true, cancelable: true),
    );
    child.dispatchEvent(disposed);
    expect(disposed.defaultPrevented, isFalse);
  });
}
