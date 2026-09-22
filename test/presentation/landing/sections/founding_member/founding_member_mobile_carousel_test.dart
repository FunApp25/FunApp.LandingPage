import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_mobile_carousel.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_section.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_carousel_navigation.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_mobile_carousel.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_scroll_reveal.dart';

import '../../landing_test_helpers.dart';

void main() {
  testWidgets('switches from carousel to established cards at 600px', (
    tester,
  ) async {
    setTestSurface(tester, const Size(320, 900));

    for (final example in const [
      (width: 320.0, carousel: true, columns: 0),
      (width: 390.0, carousel: true, columns: 0),
      (width: 599.0, carousel: true, columns: 0),
      (width: 600.0, carousel: false, columns: 1),
      (width: 768.0, carousel: false, columns: 2),
      (width: 900.0, carousel: false, columns: 2),
      (width: 1024.0, carousel: false, columns: 2),
      (width: 1200.0, carousel: false, columns: 3),
      (width: 1440.0, carousel: false, columns: 3),
    ]) {
      tester.view.physicalSize = Size(example.width, 900);
      await _pumpFoundingMember(tester);

      expect(
        find.byType(FoundingMemberMobileCarousel),
        example.carousel ? findsOneWidget : findsNothing,
      );
      if (!example.carousel) {
        expect(
          find.byKey(Key('foundingMemberCardsColumns${example.columns}')),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('matches the 390px introduction and carousel geometry', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpFoundingMember(tester);

    final mobileLayout = tester.widget<Padding>(
      find.byKey(const Key('foundingMemberMobileLayout')),
    );
    final heading = tester.widget<Text>(
      find.byKey(const Key('foundingMemberHeadingText')),
    );
    final body = tester.widget<Text>(
      find.byKey(const Key('foundingMemberBodyText')),
    );
    final bounds = find.byKey(
      const Key('foundingMemberMobileCarouselBounds'),
    );
    final viewport = find.byKey(const Key('landingMobileCarouselViewport'));
    final firstCard = find.byKey(
      const Key('foundingMemberCardSurface-recognised'),
    );
    final secondCard = find.byKey(
      const Key('foundingMemberCardSurface-access'),
    );

    expect(mobileLayout.padding, const EdgeInsets.symmetric(vertical: 80));
    expect(heading.textAlign, TextAlign.center);
    expect(heading.style?.fontSize, 32);
    expect(heading.style?.height, 42 / 32);
    expect(body.textAlign, TextAlign.center);
    expect(body.style?.fontSize, 16);
    expect(body.style?.height, 26 / 16);
    expect(
      tester
          .getSize(find.byKey(const Key('foundingMemberMobileIntroGap')))
          .height,
      40,
    );
    expect(tester.getRect(bounds).left, 16);
    expect(tester.getSize(bounds).width, 374);
    expect(tester.getRect(viewport).right, 390);
    expect(tester.getRect(firstCard).left, 16);
    expect(tester.getSize(firstCard), const Size(358, 360));
    expect(
      tester
          .widget<Padding>(
            find
                .descendant(of: firstCard, matching: find.byType(Padding))
                .first,
          )
          .padding,
      const EdgeInsets.all(32),
    );
    expect(
      (tester.widget<DecoratedBox>(firstCard).decoration as BoxDecoration)
          .borderRadius,
      const BorderRadius.all(Radius.circular(20)),
    );
    expect(
      tester.getSize(
        find.byKey(const Key('foundingMemberIcon-recognised')),
      ),
      const Size.square(28),
    );
    expect(tester.getRect(secondCard).left, 382);
    expect(tester.getRect(viewport).right - tester.getRect(secondCard).left, 8);
    expect(
      tester
          .widget<PageView>(
            find.byKey(const Key('landingMobileCarouselPageView')),
          )
          .controller
          ?.viewportFraction,
      closeTo(366 / 374, 0.0001),
    );
    expect(
      tester.getRect(find.byType(LandingCarouselNavigation)).top -
          tester.getRect(firstCard).bottom,
      16,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('adapts the card and local peek safely at 320px', (tester) async {
    setTestSurface(tester, const Size(320, 568));
    await _pumpFoundingMember(tester);

    final viewport = find.byKey(const Key('landingMobileCarouselViewport'));
    final firstCard = find.byKey(
      const Key('foundingMemberCardSurface-recognised'),
    );
    final secondCard = find.byKey(
      const Key('foundingMemberCardSurface-access'),
    );

    expect(tester.getRect(firstCard).left, 16);
    expect(tester.getSize(firstCard).width, 288);
    expect(tester.getSize(firstCard).height, greaterThanOrEqualTo(360));
    expect(tester.getRect(viewport).right, 320);
    expect(tester.getRect(secondCard).left, 312);
    expect(tester.getRect(viewport).right - tester.getRect(secondCard).left, 8);
    expect(tester.getSize(find.byType(FoundingMemberSection)).width, 320);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps three decorative dots and clamps three pages', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    setTestSurface(tester, const Size(390, 844));
    await _pumpFoundingMember(tester);

    final previous = find.byKey(const Key('landingCarouselPrevious'));
    final next = find.byKey(const Key('landingCarouselNext'));
    final dots = _dots();

    expect(_pageLabel(tester), 'Founding Member benefit 1 of 3');
    expect(dots, findsNWidgets(3));
    expect(_hasTapAction(tester, previous), isFalse);
    expect(_hasTapAction(tester, next), isTrue);
    expect(_dotColor(tester, 0), AppColors.textPrimary);

    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 2 of 3');
    expect(_dotColor(tester, 1), AppColors.textPrimary);

    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 3 of 3');
    expect(_hasTapAction(tester, previous), isTrue);
    expect(_hasTapAction(tester, next), isFalse);

    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 3 of 3');

    await tester.tap(previous);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 2 of 3');

    await tester.tap(previous);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 2 of 3');
    expect(
      find.descendant(
        of: find.byKey(const Key('landingCarouselPagination')),
        matching: find.byType(Semantics),
      ),
      findsNothing,
    );
    semantics.dispose();
  });

  testWidgets('supports swipe, scoped keyboard paging, and retained focus', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpFoundingMember(tester);

    final pageView = find.byKey(const Key('landingMobileCarouselPageView'));
    final next = find.byKey(const Key('landingCarouselNext'));

    await tester.drag(pageView, const Offset(-320, 0));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 2 of 3');

    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 3 of 3');
    expect(_controlFocusNode(tester, next).hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 2 of 3');
    expect(_controlFocusNode(tester, next).hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 3 of 3');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 3 of 3');
  });

  testWidgets('localizes semantics and fits every card at 320 and 390', (
    tester,
  ) async {
    setTestSurface(tester, const Size(320, 568));

    for (final example in const [
      (
        locale: Locale('en'),
        previous: 'Previous Founding Member benefit',
        next: 'Next Founding Member benefit',
        position: 'Founding Member benefit 1 of 3',
      ),
      (
        locale: Locale('es'),
        previous: 'Beneficio anterior de Founding Member',
        next: 'Siguiente beneficio de Founding Member',
        position: 'Beneficio de Founding Member 1 de 3',
      ),
      (
        locale: Locale('cy'),
        previous: 'Budd Founding Member blaenorol',
        next: 'Budd Founding Member nesaf',
        position: 'Budd Founding Member 1 o 3',
      ),
      (
        locale: Locale('be'),
        previous: 'Папярэдняя перавага Founding Member',
        next: 'Наступная перавага Founding Member',
        position: 'Перавага Founding Member 1 з 3',
      ),
    ]) {
      for (final size in const [Size(320, 568), Size(390, 844)]) {
        tester.view.physicalSize = size;
        await _pumpFoundingMember(tester, locale: example.locale);
        final semantics = tester.ensureSemantics();

        expect(find.bySemanticsLabel(example.previous), findsOneWidget);
        expect(find.bySemanticsLabel(example.next), findsOneWidget);
        expect(_pageLabel(tester), example.position);
        expect(
          find.bySemanticsLabel(
            tester
                .widget<Text>(
                  find.byKey(
                    const Key('foundingMemberCardTitle-recognised'),
                  ),
                )
                .data!,
          ),
          findsOneWidget,
        );
        final stableHeight = tester
            .getSize(find.byKey(const Key('landingMobileCarouselViewport')))
            .height;
        if (example.locale == const Locale('en') && size.width == 390) {
          expect(stableHeight, 360);
        } else {
          expect(stableHeight, greaterThanOrEqualTo(360));
        }

        for (final id in ['recognised', 'access', 'voice']) {
          if (id != 'recognised') {
            await tester.tap(find.byKey(const Key('landingCarouselNext')));
            await tester.pumpAndSettle();
          }
          expect(
            find.byKey(Key('foundingMemberCardTitle-$id')).hitTestable(),
            findsOneWidget,
          );
          expect(
            find.byKey(Key('foundingMemberCardBody-$id')).hitTestable(),
            findsOneWidget,
          );
          expect(
            tester
                .getSize(
                  find.byKey(const Key('landingMobileCarouselViewport')),
                )
                .height,
            stableHeight,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${example.locale.languageCode} ${size.width}px card $id',
          );
        }
        semantics.dispose();
      }
    }
  });

  testWidgets('uses immediate reduced-motion paging without entry reveal', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpFoundingMember(tester, disableAnimations: true);

    expect(
      find.descendant(
        of: find.byType(FoundingMemberSection),
        matching: find.byType(LandingScrollReveal),
      ),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('landingCarouselNext')));
    await tester.pump();
    expect(_pageLabel(tester), 'Founding Member benefit 2 of 3');

    await tester.drag(
      find.byKey(const Key('landingMobileCarouselPageView')),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 3 of 3');
  });

  testWidgets('preserves page within mobile and resets across 600px', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpFoundingMember(tester);

    await tester.tap(find.byKey(const Key('landingCarouselNext')));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Founding Member benefit 2 of 3');

    tester.view.physicalSize = const Size(320, 568);
    await _pumpFoundingMember(tester, resetState: false);
    expect(_pageLabel(tester), 'Founding Member benefit 2 of 3');

    tester.view.physicalSize = const Size(600, 844);
    await _pumpFoundingMember(tester, resetState: false);
    expect(find.byType(LandingMobileCarousel), findsNothing);
    expect(
      find.byKey(const Key('foundingMemberCardsColumns1')),
      findsOneWidget,
    );

    tester.view.physicalSize = const Size(390, 844);
    await _pumpFoundingMember(tester, resetState: false);
    expect(_pageLabel(tester), 'Founding Member benefit 1 of 3');
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpFoundingMember(
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
        body: SingleChildScrollView(child: FoundingMemberSection()),
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

Finder _dots() => find.descendant(
  of: find.byKey(const Key('landingCarouselPagination')),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith(
          'landingCarouselDot',
        ),
  ),
);

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
