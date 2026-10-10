import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_placeholder_page.dart';

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
    testWidgets('${example.route} resolves to an explicit review placeholder', (
      tester,
    ) async {
      setTestSurface(tester, const Size(390, 844));
      await tester.pumpWidget(const FunAppLandingPageApp());
      await tester.pump();
      Navigator.of(
        tester.element(find.byType(LandingPage)),
      ).pushNamed(example.route);
      await tester.pumpAndSettle();

      expect(
        find.byKey(Key('legalPlaceholderPage-${example.kind.name}')),
        findsOneWidget,
      );
      expect(find.text(example.title), findsWidgets);
      expect(
        find.text('Draft placeholder — content awaiting approval.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'This placeholder must be replaced or removed before production '
          'deployment.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('approved legal document'),
        example.kind == LegalPlaceholderKind.cookieBanner
            ? findsNothing
            : findsOneWidget,
      );
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Reject'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('footer legal controls route while Privacy remains unchanged', (
    tester,
  ) async {
    final launched = <Uri>[];
    setTestSurface(tester, const Size(1440, 1000));
    await tester.pumpWidget(
      FunAppLandingPageApp(onPrivacyNoticeLaunch: launched.add),
    );
    await tester.pump();

    final terms = find.byKey(const Key('footerTermsLink'));
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('legalPlaceholderPage-terms')),
      findsOneWidget,
    );

    final privacy = find.byKey(const Key('footerPrivacyNoticeLink'));
    await tester.ensureVisible(privacy);
    await tester.tap(privacy);
    await tester.pump();
    expect(launched, hasLength(1));
    expect(launched.single.fragment, '/privacy');
  });

  testWidgets('placeholder layout is localized and bounded at target widths', (
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
