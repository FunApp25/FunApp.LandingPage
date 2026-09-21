import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/privacy/pages/privacy_notice_page.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';

import '../landing/landing_test_helpers.dart';

late String _approvedMarkdown;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    _approvedMarkdown = await rootBundle.loadString(
      PrivacyNoticePage.assetPath,
    );
  });

  test(
    'canonical Privacy Notice Markdown retains approved integrity markers',
    () async {
      final content = _approvedMarkdown;

      expect(content, startsWith('# Fun App Ltd - Privacy Policy\n'));
      expect(content, contains('**Last updated: 15 September 2026**'));
      expect(content, contains('## 1. About Fun App'));
      expect(
        content,
        contains(
          '## 4. Information submitted by businesses, venues, clubs '
          'and charities',
        ),
      );
      expect(content, contains('## 10. Cookies and similar technologies'));
      expect(content, contains('## 11. Your data protection rights'));
      expect(content, contains('## 13. Complaints'));
      expect(content, contains('## 15. Contact Fun App'));
      expect(content, contains('**Company number:** 17261344'));
      expect(
        content,
        contains('[info@funapp.world](mailto:info@funapp.world)'),
      );
      expect(
        content,
        contains(
          '**Privacy Contact:**\\\n'
          '[info@funapp.world](mailto:info@funapp.world)',
        ),
      );
      expect(
        content,
        contains(
          '**Email:**\\\n'
          '[info@funapp.world](mailto:info@funapp.world)\\\n'
          '**Registered office:**',
        ),
      );
      expect(
        content,
        contains('where your doing so is appropriate'),
        reason: 'Approved wording must not be silently corrected.',
      );
      expect(
        RegExp(r'^## \d+\.', multiLine: true).allMatches(content),
        hasLength(15),
      );
      for (final forbidden in const [
        '<script',
        '<iframe',
        'javascript:',
      ]) {
        expect(content.toLowerCase(), isNot(contains(forbidden)));
      }
    },
  );

  test('privacy hash URL stays on the current origin', () {
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

  testWidgets('direct privacy route renders approved structure', (
    tester,
  ) async {
    await _pumpDirectPrivacyRoute(tester);

    expect(find.byType(PrivacyNoticePage), findsOneWidget);
    expect(find.text('Fun App Ltd - Privacy Policy'), findsOneWidget);
    expect(find.text('1. About Fun App'), findsOneWidget);
    expect(find.text('10. Cookies and similar technologies'), findsOneWidget);
    expect(find.text('15. Contact Fun App'), findsOneWidget);
    expect(find.text('Last updated: 15 September 2026'), findsNWidgets(2));
    expect(find.byKey(const Key('privacyNoticeScrollView')), findsOneWidget);
    expect(
      tester
          .widget<Title>(
            find.descendant(
              of: find.byType(PrivacyNoticePage),
              matching: find.byType(Title),
            ),
          )
          .title,
      'Privacy Notice | Fun App',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('privacy page exposes heading semantics without return control', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPrivacyPage(
      tester,
      markdownData: '# Fun App Ltd - Privacy Policy',
    );

    final heading = tester
        .getSemantics(
          find.byKey(const Key('privacyNoticeDocumentHeading')),
        )
        .getSemanticsData();
    expect(heading.label, 'Fun App Ltd - Privacy Policy');
    expect(heading.flagsCollection.isHeader, isTrue);

    expect(find.byKey(const Key('privacyNoticeReturnLink')), findsNothing);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    semantics.dispose();
  });

  testWidgets('approved email links retain inline link semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPrivacyPage(tester);

    final emailLinks = find.semantics.byLabel('info@funapp.world');
    expect(emailLinks, findsNWidgets(3));
    for (final emailLink in emailLinks.evaluate()) {
      final emailSemantics = emailLink.getSemanticsData();
      expect(emailSemantics.label, 'info@funapp.world');
      expect(emailSemantics.flagsCollection.isLink, isTrue);
      expect(emailSemantics.hasAction(SemanticsAction.tap), isTrue);
    }
    expect(
      find.descendant(
        of: find.byKey(const Key('privacyNoticeMarkdown')),
        matching: find.byType(TextButton),
      ),
      findsNothing,
    );
    semantics.dispose();
  });

  testWidgets('contact email links stay in the notice content column', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(320, 568), textScaler: TextScaler.linear(2)),
      (size: Size(390, 844), textScaler: TextScaler.linear(2)),
      (size: Size(768, 1024), textScaler: TextScaler.noScaling),
      (size: Size(1440, 900), textScaler: TextScaler.noScaling),
    ]) {
      setTestSurface(tester, example.size);
      await _pumpPrivacyPage(tester, textScaler: example.textScaler);

      final contentRect = tester.getRect(
        find.byKey(const Key('privacyNoticeContent')),
      );
      for (final contactBlock in [
        _contactBlock('Privacy Contact:'),
        _contactBlock('Email:'),
      ]) {
        expect(contactBlock, findsOneWidget);
        final contactRect = tester.getRect(contactBlock);
        expect(contactRect.left, greaterThanOrEqualTo(contentRect.left));
        expect(contactRect.right, lessThanOrEqualTo(contentRect.right));
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('privacy content scrolls within constrained height', (
    tester,
  ) async {
    setTestSurface(tester, const Size(320, 300));
    await _pumpPrivacyPage(tester);

    final heading = find.byKey(const Key('privacyNoticeDocumentHeading'));
    final initialTop = tester.getTopLeft(heading).dy;
    await tester.drag(
      find.byKey(const Key('privacyNoticeScrollView')),
      const Offset(0, -800),
    );
    await tester.pump();

    expect(tester.getTopLeft(heading).dy, lessThan(initialTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('privacy page remains bounded at mobile and desktop widths', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(320, 568), textScaler: TextScaler.linear(2)),
      (size: Size(768, 1024), textScaler: TextScaler.noScaling),
      (size: Size(1440, 900), textScaler: TextScaler.noScaling),
    ]) {
      setTestSurface(tester, example.size);
      await _pumpPrivacyPage(tester, textScaler: example.textScaler);

      final contentRect = tester.getRect(
        find.byKey(const Key('privacyNoticeContent')),
      );
      expect(contentRect.left, greaterThanOrEqualTo(16));
      expect(contentRect.right, lessThanOrEqualTo(example.size.width - 16));
      expect(contentRect.width, lessThanOrEqualTo(800));
      expect(tester.takeException(), isNull);
    }
  });
}

Finder _contactBlock(String label) => find.byWidgetPredicate(
  (widget) => widget is RichText && widget.text.toPlainText().contains(label),
  description: 'contact block containing $label',
);

Future<void> _pumpDirectPrivacyRoute(
  WidgetTester tester, {
  String? markdownData,
}) async {
  final content = markdownData ?? _approvedMarkdown;
  await tester.pumpWidget(
    MaterialApp(
      initialRoute: PrivacyNoticePage.routeName,
      theme: appTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/': (_) => const Scaffold(key: Key('landingRoute')),
        PrivacyNoticePage.routeName: (_) => PrivacyNoticePage(
          markdownData: content,
        ),
      },
    ),
  );
  await tester.pump();
}

Future<void> _pumpPrivacyPage(
  WidgetTester tester, {
  TextScaler textScaler = TextScaler.noScaling,
  String? markdownData,
}) async {
  final content = markdownData ?? _approvedMarkdown;
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: PrivacyNoticePage(markdownData: content),
    ),
  );
  await tester.pump();
}
