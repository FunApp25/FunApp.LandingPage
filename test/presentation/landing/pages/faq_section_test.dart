import 'dart:ui' show PointerDeviceKind, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/content/faq_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/faq/faq_section.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';

import '../landing_test_helpers.dart';

const _freeAnswerFirst =
    'Yes. The core Fun App experience is free because finding someone to grab '
    'coffee with should not require a financial strategy.';

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
    final semantics = tester.ensureSemantics();
    await _pumpFaq(tester);

    expect(find.text('FAQ'), findsOneWidget);
    expect(find.text('Everything You Need To Know'), findsOneWidget);
    for (final question in englishQuestions) {
      expect(find.text(question), findsOneWidget);
    }
    expect(_questionControls(), findsNWidgets(englishQuestions.length));
    expect(_answerState(tester, 0), CrossFadeState.showSecond);
    expect(
      find.bySemanticsLabel(RegExp(RegExp.escape(_freeAnswerFirst))),
      findsOneWidget,
    );
    for (var index = 1; index < englishQuestions.length; index++) {
      expect(_answerState(tester, index), CrossFadeState.showFirst);
    }
    expect(_faqIconAsset(tester, 0), AppAssets.faqMinus);
    for (var index = 1; index < englishQuestions.length; index++) {
      expect(_faqIconAsset(tester, index), AppAssets.faqPlus);
    }
    semantics.dispose();
  });

  testWidgets('builds the ordered FAQ collection and emphasis metadata', (
    tester,
  ) async {
    await _pumpFaq(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(FaqSection)));
    final items = buildFaqItems(l10n);

    expect(items.map((item) => item.question), orderedEquals(englishQuestions));
    expect(
      items[6].paragraphs[1].emphasizedTerms,
      [l10n.landingFaqSharedIntentTerm],
    );
    expect(
      items[8].paragraphs[1].emphasizedTerms,
      ['Safe Guard', 'Footprint'],
    );
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
    expect(_answerState(tester, 0), CrossFadeState.showSecond);
    expect(_answerState(tester, 1), CrossFadeState.showSecond);

    final control = tester.widget<FocusableActionDetector>(
      find.byKey(const Key('faqQuestionControl1')),
    );
    control.focusNode!.requestFocus();
    await tester.pump();
    await tester.pump();
    expect(control.focusNode!.hasFocus, isTrue);
    final visualFinder = find.byKey(const Key('faqItemVisualSurface1'));
    final focusSurface = tester.widget<DecoratedBox>(visualFinder);
    final focusDecoration = focusSurface.decoration as BoxDecoration;
    final focusBackground = tester.widget<AnimatedContainer>(
      find.byKey(const Key('faqItemStateBackground1')),
    );
    expect(
      (focusBackground.decoration! as BoxDecoration).color,
      AppColors.energeticPlum.withValues(alpha: 0.08),
    );
    final focusBorder = focusDecoration.border! as Border;
    expect(focusBorder.top.color, AppColors.energeticPlum);
    expect(focusBorder.top.width, 2);
    expect(
      tester.getRect(visualFinder),
      tester.getRect(find.byKey(const Key('faqItemSurface1'))),
    );
    expect(
      tester
          .getRect(visualFinder)
          .contains(
            tester.getCenter(find.byKey(const Key('faqAnswer1'))),
          ),
      isTrue,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_answerState(tester, 1), CrossFadeState.showFirst);
    expect(control.focusNode!.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(_answerState(tester, 1), CrossFadeState.showSecond);
    expect(_answerState(tester, 0), CrossFadeState.showSecond);
    expect(control.focusNode!.hasFocus, isTrue);

    await tester.tap(find.byKey(const Key('faqQuestionControl1')));
    await tester.pump();
    expect(_answerState(tester, 1), CrossFadeState.showFirst);
  });

  testWidgets('hover treatment covers the complete FAQ item surface', (
    tester,
  ) async {
    await _pumpFaq(tester);

    final surfaceFinder = find.byKey(const Key('faqItemSurface0'));
    final visualFinder = find.byKey(const Key('faqItemVisualSurface0'));
    await tester.ensureVisible(surfaceFinder);
    await tester.pump();

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(surfaceFinder));
    await tester.pumpAndSettle();

    final decoration =
        tester
                .widget<AnimatedContainer>(
                  find.byKey(const Key('faqItemStateBackground0')),
                )
                .decoration!
            as BoxDecoration;
    expect(
      decoration.color,
      AppColors.energeticPlum.withValues(alpha: 0.06),
    );
    expect(tester.getRect(visualFinder), tester.getRect(surfaceFinder));
    expect(
      tester
          .getRect(visualFinder)
          .contains(
            tester.getCenter(find.byKey(const Key('faqAnswer0'))),
          ),
      isTrue,
    );

    final firstControl = tester.widget<FocusableActionDetector>(
      find.byKey(const Key('faqQuestionControl0')),
    );
    firstControl.focusNode!.requestFocus();
    await tester.pump();
    await tester.pump();
    final focusedDecoration =
        tester
                .widget<AnimatedContainer>(
                  find.byKey(const Key('faqItemStateBackground0')),
                )
                .decoration!
            as BoxDecoration;
    expect(
      focusedDecoration.color,
      AppColors.energeticPlum.withValues(alpha: 0.08),
    );

    await mouse.removePointer();
  });

  testWidgets('toggles once from answer and padded item regions', (
    tester,
  ) async {
    await _pumpFaq(tester);

    await tester.tap(find.byKey(const Key('faqAnswer0')));
    await tester.pump();
    expect(_answerState(tester, 0), CrossFadeState.showFirst);

    await tester.tap(find.byKey(const Key('faqQuestionControl0')));
    await tester.pumpAndSettle();
    final surfaceRect = tester.getRect(
      find.byKey(const Key('faqItemSurface0')),
    );
    await tester.tapAt(Offset(surfaceRect.left + 4, surfaceRect.top + 4));
    await tester.pumpAndSettle();
    expect(_answerState(tester, 0), CrossFadeState.showFirst);
    expect(_faqIconAsset(tester, 0), AppAssets.faqPlus);
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
      setTestSurface(tester, const Size(320, 568));
      await _pumpFaq(tester, locale: example.locale);

      expect(find.text(example.question), findsOneWidget);
      expect(find.text(example.answer), findsOneWidget);
      expect(_questionControls(), findsNWidgets(englishQuestions.length));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses exact local Figma assets without runtime URLs', (
    tester,
  ) async {
    await _pumpFaq(tester);

    expect(
      svgAssetName(tester, const Key('faqEyebrowGlyph')),
      AppAssets.faqGlyph,
    );
    expect(_faqIconAsset(tester, 0), AppAssets.faqMinus);
    expect(_faqIconAsset(tester, 1), AppAssets.faqPlus);
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
          .widget<SvgPicture>(find.byKey(const Key('faqMinus0')))
          .excludeFromSemantics,
      isTrue,
    );
  });

  testWidgets('adapts safely at narrow, intermediate, and wide widths', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(320, 568), headingSize: 34.0, questionSize: 27.0),
      (size: Size(390, 844), headingSize: 34.0, questionSize: 27.0),
      (size: Size(768, 1024), headingSize: 40.0, questionSize: 30.0),
      (size: Size(1024, 768), headingSize: 40.0, questionSize: 30.0),
      (size: Size(1440, 900), headingSize: 44.0, questionSize: 32.0),
    ]) {
      setTestSurface(tester, example.size);
      await _pumpFaq(tester);
      await _toggle(tester, 1);
      await _toggle(tester, 6);

      expect(
        tester.getSize(find.byType(FaqSection)).width,
        lessThanOrEqualTo(example.size.width),
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('faqHeadingText')))
            .style
            ?.fontSize,
        example.headingSize,
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('faqQuestionText0')))
            .style
            ?.fontSize,
        example.questionSize,
      );
      expect(_answerState(tester, 0), CrossFadeState.showSecond);
      expect(_answerState(tester, 1), CrossFadeState.showSecond);
      expect(_answerState(tester, 6), CrossFadeState.showSecond);

      final surfaceRect = tester.getRect(
        find.byKey(const Key('faqItemSurface0')),
      );
      final questionRect = tester.getRect(
        find.byKey(const Key('faqQuestionText0')),
      );
      final iconRect = tester.getRect(find.byKey(const Key('faqIcon0')));
      final answerRect = tester.getRect(
        find.text(
          'Yes. The core Fun App experience is free because finding someone '
          'to grab coffee with should not require a financial strategy.',
        ),
      );
      final minimumInset = example.size.width < 600 ? 16.0 : 20.0;
      expect(
        questionRect.left - surfaceRect.left,
        greaterThanOrEqualTo(minimumInset),
      );
      expect(
        surfaceRect.right - iconRect.right,
        greaterThanOrEqualTo(minimumInset),
      );
      expect(answerRect.left, closeTo(questionRect.left, 1));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('updates answer semantics immediately with expansion state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpFaq(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(FaqSection)));
    final answerText = buildFaqItems(l10n)[1].paragraphs.first.text;
    final controlFinder = find.byKey(const Key('faqQuestionControl1'));
    await tester.ensureVisible(controlFinder);
    await tester.pump();

    await tester.tap(controlFinder);
    await tester.pump();

    expect(_answerState(tester, 1), CrossFadeState.showSecond);
    expect(
      tester
          .getSemantics(find.byKey(const Key('faqQuestionSemantics1')))
          .getSemanticsData()
          .flagsCollection
          .isExpanded,
      Tristate.isTrue,
    );
    final answerSemantics = tester
        .getSemantics(find.byKey(const Key('faqAnswerSemantics1')))
        .getSemanticsData();
    expect(answerSemantics.label, contains(answerText));
    expect(
      answerSemantics.flagsCollection.isButton,
      isFalse,
    );

    await tester.tap(controlFinder);
    await tester.pump();

    expect(_answerState(tester, 1), CrossFadeState.showFirst);
    expect(
      tester
          .getSemantics(find.byKey(const Key('faqQuestionSemantics1')))
          .getSemanticsData()
          .flagsCollection
          .isExpanded,
      Tristate.isFalse,
    );
    expect(
      find.bySemanticsLabel(RegExp(RegExp.escape(answerText))),
      findsNothing,
    );
    semantics.dispose();
  });

  testWidgets('rapid toggles settle in the final requested state', (
    tester,
  ) async {
    await _pumpFaq(tester);

    final controlFinder = find.byKey(const Key('faqQuestionControl1'));
    await tester.ensureVisible(controlFinder);
    await tester.pump();
    await tester.tap(controlFinder);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(controlFinder);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(controlFinder);
    await tester.pumpAndSettle();

    expect(_answerState(tester, 1), CrossFadeState.showSecond);
    expect(_faqIconAsset(tester, 1), AppAssets.faqMinus);
  });

  testWidgets('multiple FAQ transitions remain independent', (tester) async {
    await _pumpFaq(tester);

    final secondControl = find.byKey(const Key('faqQuestionControl1'));
    final thirdControl = find.byKey(const Key('faqQuestionControl2'));
    await tester.ensureVisible(secondControl);
    await tester.pump();
    await tester.tap(secondControl);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.ensureVisible(thirdControl);
    await tester.pump();
    await tester.tap(thirdControl);
    await tester.pumpAndSettle();

    expect(_answerState(tester, 0), CrossFadeState.showSecond);
    expect(_answerState(tester, 1), CrossFadeState.showSecond);
    expect(_answerState(tester, 2), CrossFadeState.showSecond);
  });

  testWidgets('reduced motion reaches FAQ final states immediately', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpFaq(tester, disableAnimations: true);

    final iconSwitcher = tester.widget<AnimatedSwitcher>(
      find.byKey(const Key('faqIconSwitcher1')),
    );
    final hoverSurface = tester.widget<AnimatedContainer>(
      find.byKey(const Key('faqItemStateBackground1')),
    );
    expect(find.byKey(const Key('faqAnswerTransition1')), findsNothing);
    expect(iconSwitcher.duration, Duration.zero);
    expect(hoverSurface.duration, Duration.zero);

    final controlFinder = find.byKey(const Key('faqQuestionControl1'));
    await tester.ensureVisible(controlFinder);
    await tester.pump();
    await tester.tap(controlFinder);
    await tester.pump();

    final l10n = AppLocalizations.of(tester.element(find.byType(FaqSection)));
    final answerText = buildFaqItems(l10n)[1].paragraphs.first.text;
    expect(_answerState(tester, 1), CrossFadeState.showSecond);
    expect(_faqIconAsset(tester, 1), AppAssets.faqMinus);
    expect(
      tester
          .getSemantics(find.byKey(const Key('faqAnswerSemantics1')))
          .getSemanticsData()
          .label,
      contains(answerText),
    );
    semantics.dispose();
  });

  testWidgets('FAQ icon transition is a brief fade only', (tester) async {
    await _pumpFaq(tester);

    final switcher = tester.widget<AnimatedSwitcher>(
      find.byKey(const Key('faqIconSwitcher1')),
    );
    final transition = switcher.transitionBuilder(
      const SizedBox.shrink(),
      const AlwaysStoppedAnimation<double>(1),
    );
    expect(switcher.duration, LandingMotion.fastDuration);
    expect(transition, isA<FadeTransition>());
    final iconBoundary = find.byKey(const Key('faqIcon1'));
    expect(
      find.descendant(
        of: iconBoundary,
        matching: find.byType(RotationTransition),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: iconBoundary,
        matching: find.byType(ScaleTransition),
      ),
      findsNothing,
    );

    await _toggle(tester, 1);
    expect(_faqIconAsset(tester, 1), AppAssets.faqMinus);
    expect(
      tester
          .widget<SvgPicture>(find.byKey(const Key('faqMinus1')))
          .excludeFromSemantics,
      isTrue,
    );
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
    final answer = tester
        .getSemantics(
          find.text(
            'Yes. The core Fun App experience is free because '
            'finding someone to grab coffee with should not require a '
            'financial strategy.',
          ),
        )
        .getSemanticsData();
    expect(
      answer.label,
      contains(
        'Yes. The core Fun App experience is free because finding someone to '
        'grab coffee with should not require a financial strategy.',
      ),
    );
    expect(answer.flagsCollection.isButton, isFalse);
    final firstControl = tester.widget<FocusableActionDetector>(
      find.byKey(const Key('faqQuestionControl0')),
    );
    expect(firstControl.mouseCursor, SystemMouseCursors.click);
    semantics.dispose();
  });
}

Finder _questionControls() => find.byWidgetPredicate(
  (widget) =>
      widget.key is ValueKey<String> &&
      (widget.key! as ValueKey<String>).value.startsWith('faqQuestionControl'),
);

CrossFadeState _answerState(WidgetTester tester, int index) {
  final transitionFinder = find.byKey(Key('faqAnswerTransition$index'));
  if (transitionFinder.evaluate().isNotEmpty) {
    return tester.widget<AnimatedCrossFade>(transitionFinder).crossFadeState;
  } else if (find.byKey(Key('faqAnswer$index')).evaluate().isNotEmpty) {
    return CrossFadeState.showSecond;
  } else {
    return CrossFadeState.showFirst;
  }
}

String _faqIconAsset(WidgetTester tester, int index) {
  final iconFinder = find.descendant(
    of: find.byKey(Key('faqIcon$index')),
    matching: find.byType(SvgPicture),
  );
  final visibleIcons = tester
      .widgetList<SvgPicture>(iconFinder)
      .where(
        (icon) =>
            icon.key == Key('faqMinus$index') ||
            icon.key == Key('faqPlus$index'),
      )
      .toList();
  expect(visibleIcons, hasLength(1));
  final loader = visibleIcons.single.bytesLoader;
  expect(loader, isA<SvgAssetLoader>());
  return (loader as SvgAssetLoader).assetName;
}

Future<void> _toggle(WidgetTester tester, int index) async {
  final finder = find.byKey(Key('faqQuestionControl$index'));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _pumpFaq(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const Scaffold(
          body: SingleChildScrollView(child: FaqSection()),
        ),
      ),
    ),
  );
  await tester.pump();
}
