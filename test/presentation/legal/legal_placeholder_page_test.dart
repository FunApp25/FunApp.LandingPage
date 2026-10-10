import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_placeholder_page.dart';
import 'package:fun_app_landing_page/presentation/privacy/pages/privacy_notice_page.dart';

import '../landing/landing_test_helpers.dart';

void main() {
  const examples = <({String route, LegalPlaceholderKind kind, String title})>[
    (
      route: LegalPlaceholderPage.termsRouteName,
      kind: LegalPlaceholderKind.terms,
      title: 'Terms of Use',
    ),
    (
      route: LegalPlaceholderPage.refundsRouteName,
      kind: LegalPlaceholderKind.refunds,
      title: 'Refund & Cancellation Policy',
    ),
    (
      route: LegalPlaceholderPage.cookiesRouteName,
      kind: LegalPlaceholderKind.cookies,
      title: 'Cookie Policy',
    ),
    (
      route: LegalPlaceholderPage.cookieBannerRouteName,
      kind: LegalPlaceholderKind.cookieBanner,
      title: 'Cookie Banner',
    ),
  ];

  for (final example in examples) {
    testWidgets('${example.route} resolves to branded Markdown content', (
      tester,
    ) async {
      setTestSurface(tester, const Size(390, 844));
      await tester.pumpWidget(const FunAppLandingPageApp());
      Navigator.of(
        tester.element(find.byType(LandingPage)),
      ).pushNamed(example.route);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.byKey(Key('legalPlaceholderPage-${example.kind.name}')),
        findsOneWidget,
      );
      expect(find.text(example.title), findsWidgets);
      expect(
        find.byKey(Key('legalDocumentCard-${example.kind.name}')),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('legalDocumentMarkdown-${example.kind.name}')),
        findsOneWidget,
      );
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Reject'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('${example.route} supports direct hash-route initialization', (
      tester,
    ) async {
      tester.binding.platformDispatcher.defaultRouteNameTestValue =
          example.route;
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );
      await tester.pumpWidget(const FunAppLandingPageApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.byKey(Key('legalPlaceholderPage-${example.kind.name}')),
        findsOneWidget,
      );
      expect(find.byType(LandingPage), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('review documents explicitly avoid invented legal behavior', (
    tester,
  ) async {
    for (final example in const [
      (
        kind: LegalPlaceholderKind.terms,
        body: 'Fun App does not yet have an approved Terms of Use document',
      ),
      (
        kind: LegalPlaceholderKind.refunds,
        body:
            'Fun App does not yet have an approved Refund & Cancellation '
            'Policy',
      ),
      (
        kind: LegalPlaceholderKind.cookieBanner,
        body: 'It does not save a choice',
      ),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LegalPlaceholderPage(
            kind: example.kind,
            markdownData: '${example.body}.',
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining(example.body), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Reject'), findsNothing);
    }
  });

  testWidgets('cookie policy is exactly the approved privacy excerpt', (
    tester,
  ) async {
    final privacy = await tester.runAsync(
      () => File(PrivacyNoticePage.assetPath).readAsString(),
    );
    expect(privacy, isNotNull);
    final excerpt = extractCookiePolicyMarkdown(privacy!);

    expect(excerpt, startsWith('## 10. Cookies and similar technologies'));
    expect(excerpt, isNot(contains('## 11. Your data protection rights')));
    expect(
      excerpt,
      privacy
          .substring(
            privacy.indexOf('## 10. Cookies and similar technologies'),
            privacy.indexOf('## 11. Your data protection rights'),
          )
          .trim(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LegalPlaceholderPage(
          kind: LegalPlaceholderKind.cookies,
          markdownData: excerpt,
        ),
      ),
    );
    expect(
      find.textContaining('standalone Cookie Policy approval remains pending'),
      findsOneWidget,
    );
  });

  testWidgets('footer Privacy navigation stays in the current route stack', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 1000));
    await tester.pumpWidget(const FunAppLandingPageApp());
    final terms = find.byKey(const Key('footerTermsLink'));
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final privacy = find.descendant(
      of: find.byKey(const Key('legalPlaceholderPage-terms')),
      matching: find.byKey(const Key('footerPrivacyNoticeLink')),
    );
    await tester.ensureVisible(privacy);
    await tester.tap(privacy);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(PrivacyNoticePage), findsOneWidget);
  });

  testWidgets('legal layout is localized and bounded at target widths', (
    tester,
  ) async {
    for (final locale in AppLocalizations.supportedLocales) {
      for (final width in const [320.0, 390.0, 599.0, 600.0, 768.0, 1440.0]) {
        setTestSurface(tester, Size(width, 1000));
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            theme: appTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: const LegalPlaceholderPage(
              kind: LegalPlaceholderKind.terms,
              markdownData: '## Draft\n\nReview only.',
            ),
          ),
        );
        await tester.pump();

        final content = tester.getRect(
          find.byKey(const Key('legalPlaceholderContent-terms')),
        );
        expect(content.left, greaterThanOrEqualTo(0));
        expect(content.right, lessThanOrEqualTo(width));
        expect(tester.takeException(), isNull);
      }
    }
  });
}
