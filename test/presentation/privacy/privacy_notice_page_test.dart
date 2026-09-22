import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  testWidgets(
    'approved email links support keyboard focus and link semantics',
    (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final launchedUris = <Uri>[];
      await _pumpPrivacyPage(tester, onLinkLaunch: launchedUris.add);

      final emailButtons = _emailButtons;
      expect(emailButtons, findsNWidgets(3));
      for (final emailButton in emailButtons.evaluate()) {
        final buttonFinder = find.byWidget(emailButton.widget);
        final button = emailButton.widget as TextButton;
        expect(button.onPressed, isNotNull);

        final focusNode = Focus.of(
          tester.element(
            find
                .descendant(
                  of: buttonFinder,
                  matching: find.text('info@funapp.world'),
                )
                .first,
          ),
        );
        expect(focusNode.canRequestFocus, isTrue);
        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasPrimaryFocus, isTrue);
        expect(
          button.style?.side?.resolve({WidgetState.focused})?.width,
          2,
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();

        final emailSemantics = tester
            .getSemantics(
              find
                  .ancestor(
                    of: buttonFinder,
                    matching: find.byType(Semantics),
                  )
                  .first,
            )
            .getSemanticsData();
        expect(emailSemantics.label, 'info@funapp.world');
        expect(emailSemantics.flagsCollection.isLink, isTrue);
        expect(emailSemantics.hasAction(SemanticsAction.tap), isTrue);
      }
      expect(launchedUris, hasLength(6));
      expect(
        launchedUris,
        everyElement(Uri.parse('mailto:info@funapp.world')),
      );
      semantics.dispose();
    },
  );

  testWidgets('contact email links stay in the notice content column', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(320, 568), textScaler: TextScaler.linear(2)),
      (size: Size(390, 844), textScaler: TextScaler.linear(2)),
      (size: Size(768, 1024), textScaler: TextScaler.noScaling),
      (size: Size(768, 1024), textScaler: TextScaler.linear(2)),
      (size: Size(1440, 900), textScaler: TextScaler.noScaling),
      (size: Size(1440, 900), textScaler: TextScaler.linear(2)),
    ]) {
      setTestSurface(tester, example.size);
      await _pumpPrivacyPage(tester, textScaler: example.textScaler);

      final contentRect = tester.getRect(
        find.byKey(const Key('privacyNoticeContent')),
      );
      final emailButtons = _emailButtons;
      expect(emailButtons, findsNWidgets(3));
      for (final emailButton in emailButtons.evaluate()) {
        final emailRect = tester.getRect(find.byWidget(emailButton.widget));
        expect(emailRect.left, greaterThanOrEqualTo(contentRect.left));
        expect(emailRect.right, lessThanOrEqualTo(contentRect.right));
        expect(emailRect.left, closeTo(contentRect.left, 0.5));
      }
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

  testWidgets('contact email links retain compact legal-information spacing', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(320, 568), textScaler: TextScaler.linear(2)),
      (size: Size(390, 844), textScaler: TextScaler.linear(2)),
      (size: Size(768, 1024), textScaler: TextScaler.noScaling),
      (size: Size(768, 1024), textScaler: TextScaler.linear(2)),
      (size: Size(1440, 900), textScaler: TextScaler.noScaling),
      (size: Size(1440, 900), textScaler: TextScaler.linear(2)),
    ]) {
      setTestSurface(tester, example.size);
      await _pumpPrivacyPage(tester, textScaler: example.textScaler);

      final lineHeight = example.textScaler.scale(16) * 1.65;
      final maximumVisualGap = lineHeight * 0.8 + 1;
      final emailButtons = _emailButtons;
      expect(emailButtons, findsNWidgets(3));

      final privacyContactEmail = _emailTextRect(
        tester,
        0,
      );
      final contactEmail = _emailTextRect(tester, 2);
      final privacyContact = _richTextLineRect(
        tester,
        _contactBlock('Privacy Contact:'),
        'Privacy Contact:',
      );
      final emailLabel = _richTextLineRect(
        tester,
        _contactBlock('Email:'),
        'Email:',
      );
      final registeredOffices = _contactBlock('Registered office:');
      expect(registeredOffices, findsNWidgets(2));
      final registeredOffice = _richTextLineRect(
        tester,
        registeredOffices.at(1),
        'Registered office:',
      );
      final privacyContactButton = tester.getRect(emailButtons.at(0));
      final contactButton = tester.getRect(emailButtons.at(2));
      final privacyContactGap = privacyContactEmail.top - privacyContact.bottom;
      final contactEmailGap = contactEmail.top - emailLabel.bottom;
      final registeredOfficeGap = registeredOffice.top - contactEmail.bottom;
      expect(
        privacyContactGap,
        greaterThanOrEqualTo(-1),
      );
      expect(
        privacyContactGap,
        lessThanOrEqualTo(maximumVisualGap),
        reason:
            'Privacy Contact spacing at ${example.size}: '
            'label=$privacyContact email=$privacyContactEmail '
            'button=${tester.getRect(emailButtons.at(0))}',
      );
      expect(
        contactEmailGap,
        greaterThanOrEqualTo(-1),
      );
      expect(
        contactEmailGap,
        lessThanOrEqualTo(maximumVisualGap),
        reason: 'Section 15 Email spacing at ${example.size}',
      );
      expect(
        registeredOfficeGap,
        greaterThanOrEqualTo(-1),
      );
      expect(
        registeredOfficeGap,
        lessThanOrEqualTo(maximumVisualGap),
        reason: 'Registered office spacing at ${example.size}',
      );
      expect(
        privacyContactButton.top,
        greaterThanOrEqualTo(privacyContact.bottom - 1),
      );
      expect(
        contactButton.top,
        greaterThanOrEqualTo(emailLabel.bottom - 1),
      );
      expect(
        contactButton.bottom,
        lessThanOrEqualTo(registeredOffice.top + 1),
      );
      for (final emailButton in emailButtons.evaluate()) {
        expect(
          tester.getRect(find.byWidget(emailButton.widget)).height,
          greaterThanOrEqualTo(44),
        );
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

final Finder _emailButtons = find.byKey(
  const Key('privacyNoticeEmailButton'),
);

Rect _emailTextRect(WidgetTester tester, int emailIndex) {
  final textFinder = find.text('info@funapp.world').at(emailIndex);
  final renderParagraph = tester.renderObject<RenderParagraph>(textFinder);
  return _globalSelectionRect(
    renderParagraph,
    const TextSelection(baseOffset: 0, extentOffset: 17),
  );
}

Rect _richTextLineRect(
  WidgetTester tester,
  Finder richTextFinder,
  String line,
) {
  final richText = tester.widget<RichText>(richTextFinder);
  final start = richText.text.toPlainText().indexOf(line);
  final renderParagraph = tester.renderObject<RenderParagraph>(richTextFinder);
  return _globalSelectionRect(
    renderParagraph,
    TextSelection(baseOffset: start, extentOffset: start + line.length),
  );
}

Rect _globalSelectionRect(
  RenderParagraph renderParagraph,
  TextSelection selection,
) {
  final origin = renderParagraph.localToGlobal(Offset.zero);
  final boxes = renderParagraph.getBoxesForSelection(selection);

  return boxes
      .map(
        (box) => Rect.fromLTRB(
          origin.dx + box.left,
          origin.dy + box.top,
          origin.dx + box.right,
          origin.dy + box.bottom,
        ),
      )
      .reduce(
        (selectionRect, boxRect) => selectionRect.expandToInclude(boxRect),
      );
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
  ValueChanged<Uri>? onLinkLaunch,
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
      home: PrivacyNoticePage(
        markdownData: content,
        onLinkLaunch: onLinkLaunch,
      ),
    ),
  );
  await tester.pump();
}
