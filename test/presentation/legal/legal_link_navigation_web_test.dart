@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/domain/legal/entities/legal_document.dart';
import 'package:fun_app_landing_page/domain/legal/legal_document_repository_interface.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_document_page.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';
import 'package:web/web.dart' as web;

void main() {
  testWidgets('browser history restores the active published document title', (
    tester,
  ) async {
    final environment = ui_web.TestEnvironment.instance;
    // Exercise the real engine title channel, while retaining test fonts/URLs.
    ui_web.TestEnvironment.setUp(
      const ui_web.TestEnvironment(
        forceTestFonts: true,
        disableFontFallbacks: true,
        keepSemanticsDisabledOnUpdate: true,
        defaultToTestUrlStrategy: true,
      ),
    );
    addTearDown(() => ui_web.TestEnvironment.setUp(environment));
    final documents = {
      for (final entry in const {
        LegalDocumentId.privacyNotice: 'Privacy Notice',
        LegalDocumentId.termsOfUse: 'Website Terms of Use',
        LegalDocumentId.foundingFriendPurchaseTerms:
            'Founding Friend Purchase Terms & Conditions',
        LegalDocumentId.userAgreement: 'Fun App User Agreement',
        LegalDocumentId.acceptableUsePolicy: 'Acceptable Use Policy',
      }.entries)
        entry.key: LegalDocument(
          id: entry.key,
          title: entry.value,
          version: '1.0.0',
          locale: 'en-GB',
          publishedAt: '2026-11-08T11:57:22.034Z',
          effectiveAt: '2026-11-14T00:00:00+01:00',
          contentSha256: 'a' * 64,
          bodyMarkdown: 'Test publication for ${entry.key.value}.',
          pdfUrl: Uri.https('legal.funapp.world', '/test.pdf'),
        ),
    };
    final repository = _LegalRepository(documents);
    getIt.registerSingleton<LegalDocumentRepositoryInterface>(repository);
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/privacy';
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue();
      await getIt.reset();
    });

    await tester.pumpWidget(const FunAppLandingPageApp());
    await tester.pumpAndSettle();
    final router = tester.element(find.byType(LegalDocumentPage)).router;
    final privacyState = tester.state(find.byType(LegalDocumentPage));

    void expectDocument(LegalDocumentId id, String path, int calls) {
      expect(router.currentPath, path);
      expect(
        tester.widget<Text>(find.byKey(const Key('legalDocumentHeading'))).data,
        documents[id]!.title,
      );
      expect(web.document.title, '${documents[id]!.title} | Fun App');
      expect(repository.calls, calls);
    }

    Future<void> traverseHistory({required bool forward}) async {
      if (forward) {
        await tester.binding.handlePushRoute('/terms');
      } else {
        await tester.binding.handlePopRoute();
      }
      await tester.pumpAndSettle();
    }

    expectDocument(LegalDocumentId.privacyNotice, '/privacy', 1);
    final terms = find.byKey(const Key('footerTermsLink'));
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.pumpAndSettle();
    expectDocument(LegalDocumentId.termsOfUse, '/terms', 2);

    for (var cycle = 0; cycle < 3; cycle++) {
      await traverseHistory(forward: false);
      expectDocument(LegalDocumentId.privacyNotice, '/privacy', 2 + cycle);
      expect(tester.state(find.byType(LegalDocumentPage)), same(privacyState));
      await traverseHistory(forward: true);
      // Forward recreates the popped Terms route, as it did before this fix.
      expectDocument(LegalDocumentId.termsOfUse, '/terms', 3 + cycle);
      expect(router.stackData, hasLength(2));
    }

    unawaited(router.pushPath('/'));
    await tester.pumpAndSettle();
    expect(web.document.title, 'Fun App');
    await traverseHistory(forward: false);
    expectDocument(LegalDocumentId.termsOfUse, '/terms', 5);

    var calls = 5;
    final otherRoutes = {
      LegalDocumentId.foundingFriendPurchaseTerms:
          '/founding-friend/purchase-terms',
      LegalDocumentId.userAgreement: '/user-agreement',
      LegalDocumentId.acceptableUsePolicy: '/acceptable-use-policy',
    };
    for (final route in otherRoutes.entries) {
      unawaited(router.pushPath(route.value));
      await tester.pumpAndSettle();
      expectDocument(route.key, route.value, ++calls);
    }
    final retainedRoutes = [
      ...otherRoutes.entries.take(2).toList().reversed,
      const MapEntry(LegalDocumentId.termsOfUse, '/terms'),
    ];
    for (final route in retainedRoutes) {
      await traverseHistory(forward: false);
      expectDocument(route.key, route.value, calls);
    }
  });

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

final class _LegalRepository implements LegalDocumentRepositoryInterface {
  _LegalRepository(this.documents);

  final Map<LegalDocumentId, LegalDocument> documents;
  int calls = 0;

  @override
  Future<LegalDocument> load(LegalDocumentId id) async {
    calls++;
    return documents[id]!;
  }
}
