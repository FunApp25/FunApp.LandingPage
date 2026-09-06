import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_stats_section.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_carousel_navigation.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_mobile_carousel.dart';

import '../../landing_test_helpers.dart';

void main() {
  testWidgets('switches from carousel to the established grid at 600px', (
    tester,
  ) async {
    setTestSurface(tester, const Size(599, 900));

    for (final example in const [
      (width: 599.0, carousel: true, columns: 0),
      (width: 600.0, carousel: false, columns: 1),
      (width: 768.0, carousel: false, columns: 2),
      (width: 1440.0, carousel: false, columns: 4),
    ]) {
      tester.view.physicalSize = Size(example.width, 900);
      await _pumpResearch(tester);

      expect(
        find.byType(LandingMobileCarousel),
        example.carousel ? findsOneWidget : findsNothing,
      );
      if (!example.carousel) {
        expect(
          find.byKey(Key('researchStatsColumns${example.columns}')),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('matches the 390px Research carousel geometry and assets', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpResearch(tester);

    final section = find.byType(ResearchStatsSection);
    final bounds = find.byKey(const Key('researchMobileCarouselBounds'));
    final viewport = find.byKey(const Key('landingMobileCarouselViewport'));
    final firstCard = find.byKey(const Key('researchStatCardBounds-49%'));
    final secondCard = find.byKey(const Key('researchStatCardBounds-67%'));
    final navigation = find.byType(LandingCarouselNavigation);
    final mobileLayout = tester.widget<Padding>(
      find.byKey(const Key('researchStatsMobileLayout')),
    );
    final heading = tester.widget<Text>(
      find.byKey(const Key('researchStatsHeadingText')),
    );
    final firstDot = find.byKey(const Key('landingCarouselDot0'));
    final secondDot = find.byKey(const Key('landingCarouselDot1'));

    expect(tester.getSize(section).width, 390);
    expect(mobileLayout.padding, const EdgeInsets.symmetric(vertical: 80));
    expect(heading.style?.fontSize, 32);
    expect(heading.style?.height, 42 / 32);
    expect(
      tester
          .getSize(find.byKey(const Key('researchStatsMobileIntroGap')))
          .height,
      40,
    );
    expect(tester.getRect(bounds).left, 16);
    expect(tester.getSize(bounds).width, 374);
    expect(tester.getRect(viewport).right, 390);
    expect(tester.widget<PageView>(find.byType(PageView)).padEnds, isFalse);
    expect(tester.widget<PageView>(find.byType(PageView)).pageSnapping, isTrue);
    expect(
      tester.widget<PageView>(find.byType(PageView)).clipBehavior,
      Clip.hardEdge,
    );
    expect(tester.getRect(firstCard).left, 16);
    expect(tester.getSize(firstCard), const Size(358, 404));
    expect(
      tester
          .widget<PageView>(find.byType(PageView))
          .controller
          ?.viewportFraction,
      closeTo(366 / 374, 0.0001),
    );
    expect(
      tester.getSize(find.byKey(const Key('landingMobileCarouselPage0'))).width,
      366,
    );
    expect(tester.getRect(secondCard).left, 382);
    expect(tester.getRect(viewport).right - tester.getRect(secondCard).left, 8);
    expect(tester.getRect(navigation).left, 16);
    expect(tester.getSize(navigation), const Size(358, 44));
    expect(
      tester.getRect(navigation).top - tester.getRect(firstCard).bottom,
      16,
    );
    expect(tester.getSize(firstDot), const Size.square(10));
    expect(tester.getRect(secondDot).left - tester.getRect(firstDot).right, 8);
    final controlVisuals = find.descendant(
      of: navigation,
      matching: find.byKey(const Key('landingCarouselControlVisual')),
    );
    expect(controlVisuals, findsNWidgets(2));
    for (var index = 0; index < 2; index++) {
      expect(tester.getSize(controlVisuals.at(index)), const Size.square(40));
    }

    for (final picture in tester.widgetList<SvgPicture>(
      find.descendant(
        of: navigation,
        matching: find.byKey(const Key('landingCarouselControlIcon')),
      ),
    )) {
      expect(
        (picture.bytesLoader as SvgAssetLoader).assetName,
        AppAssets.carouselArrowRight,
      );
      expect(picture.excludeFromSemantics, isTrue);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('adapts the card and local peek safely at 320px', (tester) async {
    setTestSurface(tester, const Size(320, 568));
    await _pumpResearch(tester);

    final viewport = find.byKey(const Key('landingMobileCarouselViewport'));
    final firstCard = find.byKey(const Key('researchStatCardBounds-49%'));
    final secondCard = find.byKey(const Key('researchStatCardBounds-67%'));

    expect(tester.getRect(firstCard).left, 16);
    expect(tester.getSize(firstCard), const Size(288, 474));
    expect(tester.getRect(viewport).right, 320);
    expect(tester.getRect(secondCard).left, 312);
    expect(tester.getRect(viewport).right - tester.getRect(secondCard).left, 8);
    expect(tester.getSize(find.byType(ResearchStatsSection)).width, 320);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pages by controls, clamps, and keeps four decorative dots', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    setTestSurface(tester, const Size(390, 844));
    await _pumpResearch(tester);

    final previous = find.byKey(const Key('landingCarouselPrevious'));
    final next = find.byKey(const Key('landingCarouselNext'));
    final dots = find.descendant(
      of: find.byKey(const Key('landingCarouselPagination')),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'landingCarouselDot',
            ),
      ),
    );

    expect(_pageLabel(tester), 'Research statistic 1 of 4');
    expect(_hasTapAction(tester, previous), isFalse);
    expect(_hasTapAction(tester, next), isTrue);
    expect(_enabledState(tester, previous), isFalse);
    expect(_enabledState(tester, next), isTrue);
    expect(
      tester
          .widget<Semantics>(
            find.byKey(const Key('landingCarouselCurrentPageSemantics')),
          )
          .properties
          .liveRegion,
      isTrue,
    );
    expect(dots, findsNWidgets(4));
    expect(_dotColor(tester, 0), AppColors.textPrimary);
    expect(_dotColor(tester, 1), AppColors.textPrimary.withValues(alpha: 0.2));
    expect(
      find.descendant(
        of: find.byKey(const Key('landingCarouselPagination')),
        matching: find.byType(Semantics),
      ),
      findsNothing,
    );

    for (var page = 2; page <= 4; page++) {
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(_pageLabel(tester), 'Research statistic $page of 4');
      expect(_dotColor(tester, page - 1), AppColors.textPrimary);
    }

    expect(_hasTapAction(tester, previous), isTrue);
    expect(_hasTapAction(tester, next), isFalse);
    expect(_enabledState(tester, previous), isTrue);
    expect(_enabledState(tester, next), isFalse);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 4 of 4');

    await tester.tap(previous);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 3 of 4');
    semantics.dispose();
  });

  testWidgets('supports swipe, scoped arrow keys, and retained arrow focus', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpResearch(tester);

    final pageView = find.byKey(const Key('landingMobileCarouselPageView'));
    final next = find.byKey(const Key('landingCarouselNext'));

    await tester.drag(pageView, const Offset(-320, 0));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 2 of 4');

    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 3 of 4');
    expect(_controlFocusNode(tester, next).hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 2 of 4');
    expect(_controlFocusNode(tester, next).hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 3 of 4');

    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(_controlFocusNode(tester, next).hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 4 of 4');
  });

  testWidgets('serializes rapid arrow activation without looping', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpResearch(tester);

    final next = find.byKey(const Key('landingCarouselNext'));
    await tester.tap(next);
    await tester.tap(next);
    await tester.pumpAndSettle();

    expect(_pageLabel(tester), 'Research statistic 2 of 4');
  });

  testWidgets('arrow controls support Enter and Space activation', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpResearch(tester);

    final next = find.byKey(const Key('landingCarouselNext'));
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 2 of 4');

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 3 of 4');

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 4 of 4');
  });

  testWidgets('localizes controls and keeps every card readable', (
    tester,
  ) async {
    setTestSurface(tester, const Size(320, 568));

    for (final example in const [
      (
        locale: Locale('en'),
        previous: 'Previous Research statistic',
        next: 'Next Research statistic',
        position: 'Research statistic 1 of 4',
      ),
      (
        locale: Locale('es'),
        previous: 'Estadística de investigación anterior',
        next: 'Siguiente estadística de investigación',
        position: 'Estadística de investigación 1 de 4',
      ),
      (
        locale: Locale('cy'),
        previous: 'Ystadegyn ymchwil blaenorol',
        next: 'Ystadegyn ymchwil nesaf',
        position: 'Ystadegyn ymchwil 1 o 4',
      ),
      (
        locale: Locale('be'),
        previous: 'Папярэдняя статыстыка даследавання',
        next: 'Наступная статыстыка даследавання',
        position: 'Статыстыка даследавання 1 з 4',
      ),
    ]) {
      for (final size in const [Size(320, 568), Size(390, 844)]) {
        tester.view.physicalSize = size;
        await _pumpResearch(tester, locale: example.locale);
        final semantics = tester.ensureSemantics();

        expect(find.bySemanticsLabel(example.previous), findsOneWidget);
        expect(find.bySemanticsLabel(example.next), findsOneWidget);
        expect(_pageLabel(tester), example.position);

        for (final value in ['49%', '67%', '70%', '44%']) {
          final currentValue = find.byKey(Key('researchStatValue-$value'));
          if (value != '49%') {
            await tester.tap(find.byKey(const Key('landingCarouselNext')));
            await tester.pumpAndSettle();
          }
          expect(currentValue, findsOneWidget);
          expect(currentValue.hitTestable(), findsOneWidget);
          expect(find.bySemanticsLabel(value), findsOneWidget);
          expect(
            tester.takeException(),
            isNull,
            reason:
                '${example.locale.languageCode} ${size.width}px card $value',
          );
        }
        semantics.dispose();
      }
    }
  });

  testWidgets('uses immediate programmatic paging with reduced motion', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpResearch(tester, disableAnimations: true);

    expect(
      tester
          .widget<Opacity>(
            find.byKey(const Key('researchMobileCarouselRevealOpacity')),
          )
          .opacity,
      1,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('researchStatsReveal')),
        matching: find.byType(TweenAnimationBuilder<double>),
      ),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('landingCarouselNext')));
    await tester.pump();
    expect(_pageLabel(tester), 'Research statistic 2 of 4');

    await tester.drag(
      find.byKey(const Key('landingMobileCarouselPageView')),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 3 of 4');
  });

  testWidgets('preserves a page while resizing within mobile constraints', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpResearch(tester);

    await tester.tap(find.byKey(const Key('landingCarouselNext')));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 2 of 4');

    tester.view.physicalSize = const Size(320, 568);
    await _pumpResearch(tester, resetState: false);
    expect(_pageLabel(tester), 'Research statistic 2 of 4');
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposes mobile paging across the 600px branch boundary', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpResearch(tester);

    await tester.tap(find.byKey(const Key('landingCarouselNext')));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Research statistic 2 of 4');

    tester.view.physicalSize = const Size(600, 844);
    await _pumpResearch(tester, resetState: false);
    expect(find.byType(LandingMobileCarousel), findsNothing);
    expect(find.byKey(const Key('researchStatsColumns1')), findsOneWidget);

    tester.view.physicalSize = const Size(390, 844);
    await _pumpResearch(tester, resetState: false);
    expect(find.byType(LandingMobileCarousel), findsOneWidget);
    expect(_pageLabel(tester), 'Research statistic 1 of 4');
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpResearch(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  bool disableAnimations = false,
  bool resetState = true,
}) async {
  if (resetState) {
    await tester.pumpWidget(const SizedBox.shrink());
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQueryData.fromView(
          tester.view,
        ).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: const Scaffold(
        body: SingleChildScrollView(child: ResearchStatsSection()),
      ),
    ),
  );
  await tester.pump();
  final navigation = find.byKey(const Key('landingCarouselNavigation'));
  if (navigation.evaluate().isNotEmpty) {
    await tester.ensureVisible(navigation);
    await tester.pump();
  }
}

String _pageLabel(WidgetTester tester) => tester
    .getSemantics(
      find.byKey(const Key('landingCarouselCurrentPageSemantics')),
    )
    .getSemanticsData()
    .label;

bool _hasTapAction(WidgetTester tester, Finder finder) => tester
    .getSemantics(finder)
    .getSemanticsData()
    .hasAction(SemanticsAction.tap);

bool? _enabledState(WidgetTester tester, Finder control) => tester
    .widget<Semantics>(
      find.descendant(of: control, matching: find.byType(Semantics)).first,
    )
    .properties
    .enabled;

FocusNode _controlFocusNode(WidgetTester tester, Finder control) => tester
    .widget<Focus>(
      find.descendant(of: control, matching: find.byType(Focus)).first,
    )
    .focusNode!;

Color? _dotColor(WidgetTester tester, int index) =>
    (tester
                .widget<DecoratedBox>(
                  find.byKey(Key('landingCarouselDot$index')),
                )
                .decoration
            as BoxDecoration)
        .color;
