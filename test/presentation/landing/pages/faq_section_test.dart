import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/faq_section.dart';

void main() {
  const englishQuestions = [
    'Is Fun App free?',
    'Is a Founding Friend subscription really lifetime?',
    'Can I change my mind and cancel my subscription?',
    'What photo should I use?',
    'What should I put in my bio?',
    'Can regular users create events?',
    'How does matching work?',
    'Can I find love on Fun App?',
    'Is Fun App safe?',
    'What is Safe Guard?',
    'What is Footprint?',
    'Isn’t saving people into groups a little weird?',
    'What happens if someone harasses me or uses hate speech?',
  ];

  testWidgets('renders all approved questions with only the first expanded', (
    tester,
  ) async {
    await _pumpFaq(tester);

    expect(find.text('FAQ'), findsOneWidget);
    expect(find.text('Everything You Need To Know'), findsOneWidget);
    for (final question in englishQuestions) {
      expect(find.text(question), findsOneWidget);
    }
    expect(_questionControls(), findsNWidgets(13));
    expect(find.byKey(const Key('faqAnswer0')), findsOneWidget);
    for (var index = 1; index < 13; index++) {
      expect(find.byKey(Key('faqAnswer$index')), findsNothing);
    }
    expect(
      _svgAsset(tester, const Key('faqIcon0')),
      AppAssets.faqMinus,
    );
    for (var index = 1; index < 13; index++) {
      expect(_svgAsset(tester, Key('faqIcon$index')), AppAssets.faqPlus);
    }
  });

  testWidgets('uses the complete approved representative English answers', (
    tester,
  ) async {
    await _pumpFaq(tester);

    expect(
      find.text(
        'We offer an optional subscription for extra features, higher limits, '
        'and additional storage. Nice to have, not required to enjoy using the '
        'app. However, join early as a Founding Friend and the subscription is '
        'included for free.',
      ),
      findsOneWidget,
    );

    for (final index in [1, 6, 8, 9, 10, 12]) {
      await _toggle(tester, index);
    }

    const lifetimeAnswer =
        'The one obvious exception: if your account is banned for violating '
        'our '
        'rules or misconduct reported by other users, the subscription does '
        'not come with diplomatic immunity.';
    const matchingAnswer =
        'Fun App gives you plenty of ways to search for the right person, but '
        'we '
        'care more about shared intent than algorithmic destiny.';
    const safetyAnswer =
        'Features like Safe Guard and Footprint are designed to add an extra '
        'layer of safety, not replace your judgment.';
    const safeGuardAnswer =
        'Safe Guard lets you tell a trusted person where you are going, who '
        'you '
        'are meeting, and when they should expect to hear from you, even if '
        'they don’t use Fun App.';
    const footprintAnswer =
        'With both users’ consent, Footprint can temporarily share or track '
        'your '
        'location during a meeting.';
    const harassmentAnswer =
        'Fun App has no tolerance for harassment, threats, discriminatory '
        'abuse, '
        'or hate speech targeting people based on identity or protected '
        'characteristics.';
    for (final answer in [
      lifetimeAnswer,
      matchingAnswer,
      safetyAnswer,
      safeGuardAnswer,
      footprintAnswer,
      harassmentAnswer,
    ]) {
      expect(find.text(answer), findsOneWidget);
    }
  });

  testWidgets('toggles independently and retains question focus', (
    tester,
  ) async {
    await _pumpFaq(tester);

    await _toggle(tester, 1);
    expect(find.byKey(const Key('faqAnswer0')), findsOneWidget);
    expect(find.byKey(const Key('faqAnswer1')), findsOneWidget);

    final control = tester.widget<InkWell>(
      find.byKey(const Key('faqQuestionControl1')),
    );
    control.focusNode!.requestFocus();
    await tester.pump();
    expect(control.focusNode!.hasFocus, isTrue);
    expect(control.focusColor, isNot(Colors.transparent));

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.byKey(const Key('faqAnswer1')), findsNothing);
    expect(control.focusNode!.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(find.byKey(const Key('faqAnswer1')), findsOneWidget);
    expect(find.byKey(const Key('faqAnswer0')), findsOneWidget);
    expect(control.focusNode!.hasFocus, isTrue);

    await tester.tap(find.byKey(const Key('faqQuestionControl1')));
    await tester.pump();
    expect(find.byKey(const Key('faqAnswer1')), findsNothing);
  });

  for (final example in const [
    (
      locale: Locale('es'),
      question: '¿Fun App es gratis?',
      answer:
          'Sí. La experiencia principal de Fun App es gratuita porque '
          'encontrar a alguien con quien tomar un café no debería requerir una '
          'estrategia financiera.',
    ),
    (
      locale: Locale('cy'),
      question: 'Ydy Fun App am ddim?',
      answer:
          'Ydy. Mae profiad craidd Fun App am ddim oherwydd ni ddylai dod o '
          'hyd i rywun i gael coffi gyda nhw olygu bod angen strategaeth '
          'ariannol.',
    ),
    (
      locale: Locale('be'),
      question: 'Fun App бясплатны?',
      answer:
          'Так. Асноўныя магчымасці Fun App бясплатныя, бо пошук чалавека, з '
          'якім можна выпіць кавы, не павінен патрабаваць фінансавай '
          'стратэгіі.',
    ),
  ]) {
    testWidgets('renders complete ${example.locale.languageCode} FAQ copy', (
      tester,
    ) async {
      _setTestSurface(tester, const Size(320, 568));
      await _pumpFaq(tester, locale: example.locale);

      expect(find.text(example.question), findsOneWidget);
      expect(find.text(example.answer), findsOneWidget);
      expect(_questionControls(), findsNWidgets(13));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses exact local Figma assets without runtime URLs', (
    tester,
  ) async {
    await _pumpFaq(tester);

    expect(
      _svgAsset(tester, const Key('faqEyebrowGlyph')),
      AppAssets.faqGlyph,
    );
    expect(
      _svgAsset(tester, const Key('faqIcon0')),
      AppAssets.faqMinus,
    );
    expect(
      _svgAsset(tester, const Key('faqIcon1')),
      AppAssets.faqPlus,
    );
    for (final asset in [
      AppAssets.faqGlyph,
      AppAssets.faqPlus,
      AppAssets.faqMinus,
    ]) {
      expect(asset, startsWith('assets/landing/faq/'));
      expect(asset, isNot(contains('figma.com')));
    }
    expect(
      tester
          .widget<SvgPicture>(find.byKey(const Key('faqEyebrowGlyph')))
          .excludeFromSemantics,
      isTrue,
    );
    expect(
      tester
          .widget<SvgPicture>(find.byKey(const Key('faqIcon0')))
          .excludeFromSemantics,
      isTrue,
    );
  });

  testWidgets('adapts safely at narrow, intermediate, and wide widths', (
    tester,
  ) async {
    for (final size in const [
      Size(320, 568),
      Size(768, 1024),
      Size(1440, 900),
    ]) {
      _setTestSurface(tester, size);
      await _pumpFaq(tester);
      await _toggle(tester, 1);
      await _toggle(tester, 6);

      expect(
        tester.getSize(find.byType(FaqSection)).width,
        lessThanOrEqualTo(size.width),
      );
      expect(find.byKey(const Key('faqAnswer0')), findsOneWidget);
      expect(find.byKey(const Key('faqAnswer1')), findsOneWidget);
      expect(find.byKey(const Key('faqAnswer6')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('exposes heading and independent expanded control semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpFaq(tester);

    final heading = tester
        .getSemantics(find.byKey(const Key('faqHeadingSemantics')))
        .getSemanticsData();
    expect(heading.label, 'Everything You Need To Know');
    expect(heading.flagsCollection.isHeader, isTrue);

    final first = tester
        .getSemantics(find.byKey(const Key('faqQuestionSemantics0')))
        .getSemanticsData();
    final second = tester
        .getSemantics(find.byKey(const Key('faqQuestionSemantics1')))
        .getSemanticsData();
    expect(first.label, 'Is Fun App free?');
    expect(first.flagsCollection.isButton, isTrue);
    expect(first.flagsCollection.isExpanded, Tristate.isTrue);
    expect(second.flagsCollection.isButton, isTrue);
    expect(second.flagsCollection.isExpanded, Tristate.isFalse);
    expect(
      find.text(
        'Yes. The core Fun App experience is free because '
        'finding someone to grab coffee with should not require a financial '
        'strategy.',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });
}

Finder _questionControls() => find.byWidgetPredicate(
  (widget) =>
      widget.key is ValueKey<String> &&
      (widget.key! as ValueKey<String>).value.startsWith('faqQuestionControl'),
);

Future<void> _toggle(WidgetTester tester, int index) async {
  final finder = find.byKey(Key('faqQuestionControl$index'));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _pumpFaq(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: SingleChildScrollView(child: FaqSection()),
      ),
    ),
  );
  await tester.pump();
}

void _setTestSurface(WidgetTester tester, Size size) {
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
}

String _svgAsset(WidgetTester tester, Key key) {
  final picture = tester.widget<SvgPicture>(find.byKey(key));
  expect(picture.bytesLoader, isA<SvgAssetLoader>());
  return (picture.bytesLoader as SvgAssetLoader).assetName;
}
