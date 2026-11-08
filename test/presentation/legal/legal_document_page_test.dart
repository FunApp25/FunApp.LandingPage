import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/domain/legal/entities/legal_document.dart';
import 'package:fun_app_landing_page/domain/legal/legal_document_repository_interface.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_document_page.dart';
import 'package:fun_app_landing_page/presentation/legal/widgets/legal_document_links.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_form.dart';

import '../../fixtures/legal/legal_test_repository.dart';
import '../landing/landing_test_helpers.dart';

void main() {
  late LegalDocument privacy;
  late Map<LegalDocumentId, LegalDocument> documents;
  setUp(() async {
    documents = {
      for (final id in LegalDocumentId.values)
        id: await fixtureLegalRepository().load(id),
    };
    privacy = documents[LegalDocumentId.privacyNotice]!;
  });
  tearDown(() async => getIt.reset());

  Future<void> pump(
    WidgetTester tester,
    LegalDocumentRepositoryInterface repo, {
    String locale = 'en',
    double width = 390,
    double scale = 1,
    ValueChanged<Uri>? onOpen,
  }) async {
    setTestSurface(tester, Size(width, 900));
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: LegalDocumentPage(
          documentId: LegalDocumentId.privacyNotice,
          repository: repo,
          now: () => DateTime.utc(2026, 11, 8),
          onLinkLaunch: onOpen,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('loading, failure and retry use one operation per attempt', (
    tester,
  ) async {
    final pending = Completer<LegalDocument>();
    final repo = TestLegalRepository((_) => pending.future);
    await pump(tester, repo);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    expect(repo.calls, 1);
    pending.completeError(
      const LegalDocumentException(LegalDocumentFailure.unavailable),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('legalDocumentLoadError')), findsOneWidget);
    await tester.tap(find.byKey(const Key('legalDocumentRetry')));
    await tester.pumpAndSettle();
    expect(repo.calls, 2);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  for (final locale in ['en', 'es', 'cy', 'be']) {
    testWidgets('authoritative English metadata and content in $locale', (
      tester,
    ) async {
      final repo = TestLegalRepository((_) async => privacy);
      await pump(tester, repo, locale: locale);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('legalDocumentHeading')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('legalDocumentHeading'))).data,
        privacy.title,
      );
      final renderer = tester.widget<LegalMarkdownDocument>(
        find.byType(LegalMarkdownDocument),
      );
      expect(renderer.markdownData, privacy.bodyMarkdown);
      expect(find.textContaining('3.0.0'), findsOneWidget);
      expect(find.textContaining('en-GB'), findsOneWidget);
      expect(find.textContaining(privacy.publishedAt), findsOneWidget);
      expect(find.textContaining(privacy.effectiveAt), findsOneWidget);
      expect(
        find.byKey(const Key('legalDocumentFutureEffective')),
        findsOneWidget,
      );
      expect(find.byType(SelectionArea), findsOneWidget);
      expect(repo.calls, 1);
      expect(tester.takeException(), isNull);
    });
  }
  for (final width in [320.0, 390.0, 768.0, 1440.0]) {
    testWidgets('all documents fit at $width with 2x text', (tester) async {
      for (final id in LegalDocumentId.values) {
        final doc = documents[id]!;
        await pump(
          tester,
          TestLegalRepository((_) async => doc),
          width: width,
          scale: 2,
        );
        await tester.pumpAndSettle();
        final rect = tester.getRect(
          find.byKey(const Key('legalDocumentContent')),
        );
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(width));
        expect(tester.takeException(), isNull, reason: id.value);
      }
    });
  }
  testWidgets('links retain text, keyboard focus and link semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final launched = <Uri>[];
    final doc = documents[LegalDocumentId.termsOfUse]!;
    await pump(
      tester,
      TestLegalRepository((_) async => doc),
      onOpen: launched.add,
    );
    await tester.pumpAndSettle();
    final links = find.descendant(
      of: find.byType(LegalMarkdownDocument),
      matching: find.byType(LegalTextLink),
    );
    expect(links, findsNWidgets(3));
    final link = links.first;
    await tester.ensureVisible(link);
    final button = find.descendant(of: link, matching: find.byType(TextButton));
    final node = Focus.of(
      tester.element(find.descendant(of: button, matching: find.byType(Text))),
    )..requestFocus();
    await tester.pump();
    expect(node.hasPrimaryFocus, isTrue);
    expect(
      tester.widget<TextButton>(button).style!.side!.resolve({
        WidgetState.focused,
      })!.width,
      2,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(launched.single.scheme, 'https');
    final data = tester.getSemantics(link).getSemanticsData();
    expect(data.flagsCollection.isLink, isTrue);
    expect(data.linkUrl, launched.single);
    semantics.dispose();
  });

  test(
    'unsafe links, HTML and unsupported constructs fail before rendering',
    () {
      for (final source in [
        '[bad](javascript:alert)',
        '![image](https://example.org/a.png)',
        '<script>alert(1)</script>',
        'inline <b>HTML</b>',
        '```\ncode\n```',
        '| a | b |\n|---|---|\n| x | y |',
      ]) {
        expect(() => validateLegalMarkdown(source), throwsFormatException);
      }
      for (final url in [
        'javascript:alert(1)',
        'data:text/html,x',
        'http://example.org',
        'https://user:password@example.org',
        'mailto:info@funapp.world?body=hello',
      ]) {
        expect(isSafeLegalLink(Uri.parse(url)), isFalse);
      }
      expect(isSafeLegalLink(Uri.parse('mailto:support@funapp.world')), isTrue);
      expect(isSafeLegalLink(Uri.parse('https://funapp.world/')), isTrue);
    },
  );
  test('all exact published bodies use supported constructs', () {
    for (final id in LegalDocumentId.values) {
      expect(
        () => validateLegalMarkdown(
          legalFixture(id.value)['bodyMarkdown'] as String,
        ),
        returnsNormally,
      );
    }
  });

  final routes = <String, LegalDocumentId>{
    '/privacy': LegalDocumentId.privacyNotice,
    '/terms': LegalDocumentId.termsOfUse,
    '/founding-friend/purchase-terms':
        LegalDocumentId.foundingFriendPurchaseTerms,
    '/user-agreement': LegalDocumentId.userAgreement,
    '/acceptable-use-policy': LegalDocumentId.acceptableUsePolicy,
  };
  for (final route in routes.entries) {
    testWidgets('direct ${route.key} resolves its selected document', (
      tester,
    ) async {
      final repo = TestLegalRepository((id) async => documents[id]!);
      getIt.registerSingleton<LegalDocumentRepositoryInterface>(repo);
      tester.binding.platformDispatcher.defaultRouteNameTestValue = route.key;
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );
      await tester.pumpWidget(const FunAppLandingPageApp());
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<LegalDocumentPage>(find.byType(LegalDocumentPage))
            .documentId,
        route.value,
      );
      expect(repo.calls, 1);
      final router = tester.element(find.byType(LegalDocumentPage)).router;
      expect(router.stackData, hasLength(1));
      expect(router.currentPath, route.key);
      for (final key in [
        'footerPrivacyNoticeLink',
        'footerTermsLink',
        'footerPurchaseTermsLink',
        'footerUserAgreementLink',
        'footerAcceptableUsePolicyLink',
      ]) {
        expect(find.byKey(Key(key)), findsOneWidget);
      }
    });
  }

  testWidgets('legal footer navigation preserves history and open snapshots', (
    tester,
  ) async {
    final repo = TestLegalRepository((id) async => documents[id]!);
    getIt.registerSingleton<LegalDocumentRepositoryInterface>(repo);
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/privacy';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    await tester.pumpWidget(const FunAppLandingPageApp());
    await tester.pumpAndSettle();
    final router = tester.element(find.byType(LegalDocumentPage)).router;
    final terms = find.byKey(const Key('footerTermsLink'));
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.pumpAndSettle();
    expect(router.currentPath, '/terms');
    expect(repo.calls, 2);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(router.currentPath, '/privacy');
    expect(repo.calls, 2);
    expect(await tester.binding.handlePushRoute('/terms'), isTrue);
    await tester.pumpAndSettle();
    expect(router.currentPath, '/terms');
    expect(repo.calls, 3);
  });

  testWidgets('original list starts, emphasis and hard breaks remain intact', (
    tester,
  ) async {
    const body =
        '3. **Third**\n4. Fourth\n\nParagraph with *emphasis*.\n\nLine\\\nnext';
    validateLegalMarkdown(body);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SelectionArea(
            child: LegalMarkdownDocument(
              markdownData: body,
              markdownKey: Key('sample'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('3.'), findsOneWidget);
    expect(find.text('4.'), findsOneWidget);
    final texts = tester.widgetList<Text>(find.byType(Text));
    final spans = texts
        .map((text) => text.textSpan)
        .whereType<TextSpan>()
        .toList();
    expect(
      spans.map((span) => span.toPlainText()).join(),
      contains('Line\nnext'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'form context links precede submission without new acceptance fields',
    (tester) async {
      for (final path in ['/here-and-now', '/founding-friend']) {
        tester.binding.platformDispatcher.defaultRouteNameTestValue = path;
        addTearDown(
          tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
        );
        await tester.pumpWidget(UniqueKeyedApp(key: UniqueKey()));
        await tester.pumpAndSettle();
        final form = tester.widget<UserSignUpForm>(find.byType(UserSignUpForm));
        expect(
          find.byKey(const Key('contextualLegalLink-/privacy')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('contextualLegalLink-/terms')),
          findsOneWidget,
        );
        expect(
          find.byKey(
            const Key('contextualLegalLink-/founding-friend/purchase-terms'),
          ),
          path == '/founding-friend' ? findsOneWidget : findsNothing,
        );
        final id = path == '/founding-friend' ? 'foundingFriend' : 'hereAndNow';
        expect(
          tester.getTopLeft(find.byKey(const Key('contextualLegalLinks'))).dy,
          lessThan(
            tester.getTopLeft(find.byKey(Key('userSignUpSubmit-$id'))).dy,
          ),
        );
        expect(form.marketingConsent, isFalse);
        expect(find.text('Accept'), findsNothing);
      }
    },
  );
}

class UniqueKeyedApp extends StatelessWidget {
  const UniqueKeyedApp({super.key});
  @override
  Widget build(BuildContext context) => const FunAppLandingPageApp();
}
