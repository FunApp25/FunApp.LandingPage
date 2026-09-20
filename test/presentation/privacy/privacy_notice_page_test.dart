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

  testWidgets('return control navigates from privacy to the landing route', (
    tester,
  ) async {
    await _pumpDirectPrivacyRoute(
      tester,
      markdownData: '# Fun App Ltd - Privacy Policy',
    );

    final returnButton = tester.widget<TextButton>(
      find.descendant(
        of: find.byKey(const Key('privacyNoticeReturnLink')),
        matching: find.byType(TextButton),
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('privacyNoticeReturnLink')),
        matching: find.byIcon(Icons.arrow_back),
      ),
      findsOneWidget,
    );
    returnButton.onPressed!();
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyNoticePage), findsNothing);
    expect(find.byKey(const Key('landingRoute')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('privacy page exposes heading and navigation semantics', (
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

    final returnLink = tester
        .getSemantics(find.byKey(const Key('privacyNoticeReturnLink')))
        .getSemanticsData();
    expect(returnLink.label, 'Back to Fun App');
    expect(returnLink.flagsCollection.isLink, isTrue);
    expect(returnLink.flagsCollection.isButton, isFalse);
    expect(returnLink.hasAction(SemanticsAction.tap), isTrue);
    semantics.dispose();
  });

  testWidgets('approved email links have keyboard focus and link semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpPrivacyPage(tester);

    final emailButtons = find.descendant(
      of: find.byKey(const Key('privacyNoticeMarkdown')),
      matching: find.byType(TextButton),
    );
    expect(emailButtons, findsWidgets);
    final firstEmail = emailButtons.first;
    await tester.ensureVisible(firstEmail);
    await tester.pumpAndSettle();

    final button = tester.widget<TextButton>(firstEmail);
    expect(button.onPressed, isNotNull);
    final emailSemantics = tester.getSemantics(firstEmail).getSemanticsData();
    expect(emailSemantics.label, 'info@funapp.world');
    expect(emailSemantics.flagsCollection.isLink, isTrue);
    expect(emailSemantics.hasAction(SemanticsAction.tap), isTrue);

    final emailText = find.descendant(
      of: firstEmail,
      matching: find.text('info@funapp.world'),
    );
    final focusNode = Focus.of(tester.element(emailText));
    expect(focusNode.canRequestFocus, isTrue);
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasPrimaryFocus, isTrue);
    semantics.dispose();
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
