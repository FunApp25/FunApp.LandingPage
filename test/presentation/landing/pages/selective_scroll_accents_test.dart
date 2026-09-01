import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/hero_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_scroll_reveal.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/membership_card.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/research_stat_card.dart';

import '../landing_test_helpers.dart';

void main() {
  testWidgets(
    'Hero is static with identical normal and reduced-motion geometry',
    (
      tester,
    ) async {
      setTestSurface(tester, const Size(1440, 900));
      await _pumpLandingPage(tester);

      final normalCardRect = tester.getRect(find.byKey(const Key('heroCard')));
      final normalArtworkRect = tester.getRect(
        find.byKey(const Key('heroPeopleImage')),
      );

      expect(
        find.descendant(
          of: find.byType(HeroSection),
          matching: find.byType(TweenAnimationBuilder<double>),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(HeroSection),
          matching: find.byType(FadeTransition),
        ),
        findsNothing,
      );
      expect(find.byKey(const Key('heroPeopleImage')), findsOneWidget);

      await _pumpLandingPage(tester, disableAnimations: true);

      expect(tester.getRect(find.byKey(const Key('heroCard'))), normalCardRect);
      expect(
        tester.getRect(find.byKey(const Key('heroPeopleImage'))),
        normalArtworkRect,
      );
      expect(find.byKey(const Key('heroPeopleImage')), findsOneWidget);
    },
  );

  testWidgets('only the four approved landing surfaces observe scroll entry', (
    tester,
  ) async {
    await _pumpLandingPage(tester);

    expect(find.byType(LandingScrollReveal), findsNWidgets(4));
    expect(find.byKey(const Key('researchStatsReveal')), findsOneWidget);
    expect(find.byKey(const Key('membershipCardsReveal')), findsOneWidget);
    expect(find.byKey(const Key('foundingFriendsReveal')), findsOneWidget);
    expect(find.byKey(const Key('venueCardReveal')), findsOneWidget);
  });

  testWidgets('Research cards rise and fade once with a restrained stagger', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 900));
    final semantics = tester.ensureSemantics();
    await _pumpLandingPage(tester);

    final reveal = find.byKey(const Key('researchStatsReveal'));
    final initialSize = tester.getSize(reveal);
    final revealWidget = tester.widget<LandingScrollReveal>(reveal);
    expect(revealWidget.triggerViewportFraction, 0.7);
    expect(revealWidget.duration, const Duration(milliseconds: 670));
    expect(find.byType(ResearchStatCard), findsNWidgets(4));
    for (var index = 0; index < 4; index++) {
      expect(_opacity(tester, 'researchStatRevealOpacity$index'), 0.08);
      expect(_translation(tester, 'researchStatRevealTransform$index').dy, 16);
      expect(
        tester
            .widget<Opacity>(
              find.byKey(Key('researchStatRevealOpacity$index')),
            )
            .alwaysIncludeSemantics,
        isTrue,
      );
    }
    expect(find.bySemanticsLabel('49%'), findsOneWidget);

    await _bringIntoView(tester, reveal);
    await tester.pump(const Duration(milliseconds: 110));

    final staggeredOpacities = [
      for (var index = 0; index < 4; index++)
        _opacity(tester, 'researchStatRevealOpacity$index'),
    ];
    expect(staggeredOpacities[0], greaterThan(staggeredOpacities[1]));
    expect(staggeredOpacities[1], greaterThan(staggeredOpacities[2]));
    expect(staggeredOpacities[2], greaterThan(staggeredOpacities[3]));

    await tester.pumpAndSettle();
    expect(tester.getSize(reveal), initialSize);
    _expectResearchFinalState(tester);

    final controller = _scrollController(tester);
    controller.jumpTo(controller.position.minScrollExtent);
    await tester.pump();
    await _bringIntoView(tester, reveal);
    _expectResearchFinalState(tester);
    semantics.dispose();
  });

  testWidgets('Research uses smaller movement and stagger on narrow layouts', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpLandingPage(tester);

    expect(find.byKey(const Key('researchStatsColumns1')), findsOneWidget);
    expect(
      tester
          .widget<LandingScrollReveal>(
            find.byKey(const Key('researchStatsReveal')),
          )
          .duration,
      const Duration(milliseconds: 580),
    );
    for (var index = 0; index < 4; index++) {
      expect(_opacity(tester, 'researchStatRevealOpacity$index'), 0.1);
      expect(_translation(tester, 'researchStatRevealTransform$index').dy, 10);
    }

    await _bringIntoView(
      tester,
      find.byKey(const Key('researchStatsReveal')),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      _opacity(tester, 'researchStatRevealOpacity0'),
      greaterThan(_opacity(tester, 'researchStatRevealOpacity3')),
    );
    await tester.pumpAndSettle();
    _expectResearchFinalState(tester);
  });

  testWidgets('Membership cards fade from the right once as one group', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 900));
    final semantics = tester.ensureSemantics();
    await _pumpLandingPage(tester);

    final reveal = find.byKey(const Key('membershipCardsReveal'));
    final initialSize = tester.getSize(reveal);
    expect(
      tester.widget<LandingScrollReveal>(reveal).triggerViewportFraction,
      0.825,
    );
    expect(
      tester.widget<LandingScrollReveal>(reveal).duration,
      const Duration(milliseconds: 510),
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('membershipHeadingText')),
        matching: reveal,
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: reveal, matching: find.byType(MembershipCard)),
      findsNWidgets(3),
    );
    expect(
      tester
          .widgetList<MembershipCard>(find.byType(MembershipCard))
          .map((card) => card.semanticId),
      orderedEquals(['free', 'hereNow', 'lifetime']),
    );
    for (final id in ['free', 'hereNow', 'lifetime']) {
      expect(_opacity(tester, 'membershipCardRevealOpacity-$id'), 0.12);
      expect(
        _translation(tester, 'membershipCardRevealTransform-$id'),
        const Offset(16, 0),
      );
      expect(
        tester
            .widget<Opacity>(
              find.byKey(Key('membershipCardRevealOpacity-$id')),
            )
            .alwaysIncludeSemantics,
        isTrue,
      );
    }
    expect(find.bySemanticsLabel('FREE MEMBERSHIP'), findsOneWidget);

    await _bringIntoView(tester, reveal);
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      _opacity(tester, 'membershipCardRevealOpacity-free'),
      greaterThan(_opacity(tester, 'membershipCardRevealOpacity-hereNow')),
    );
    expect(
      _opacity(tester, 'membershipCardRevealOpacity-hereNow'),
      greaterThan(_opacity(tester, 'membershipCardRevealOpacity-lifetime')),
    );

    await tester.pumpAndSettle();
    expect(tester.getSize(reveal), initialSize);
    _expectMembershipFinalState(tester);

    _scrollController(tester).jumpTo(0);
    await tester.pump();
    await _bringIntoView(tester, reveal);
    _expectMembershipFinalState(tester);
    semantics.dispose();
  });

  testWidgets('Membership movement follows responsive card layouts', (
    tester,
  ) async {
    setTestSurface(tester, const Size(768, 1024));

    for (final example in const [
      (
        size: Size(768, 1024),
        columns: 2,
        distance: 16.0,
        duration: Duration(milliseconds: 510),
      ),
      (
        size: Size(390, 844),
        columns: 1,
        distance: 10.0,
        duration: Duration(milliseconds: 460),
      ),
    ]) {
      tester.view.physicalSize = example.size;
      await _pumpLandingPage(tester);

      expect(
        find.byKey(Key('membershipCardsColumns${example.columns}')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<LandingScrollReveal>(
              find.byKey(const Key('membershipCardsReveal')),
            )
            .duration,
        example.duration,
      );
      for (final id in ['free', 'hereNow', 'lifetime']) {
        expect(
          _translation(tester, 'membershipCardRevealTransform-$id'),
          Offset(example.distance, 0),
        );
      }
    }
  });

  testWidgets('promotional cards enter once from their approved directions', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 900));
    await _pumpLandingPage(tester);

    expect(_opacity(tester, 'foundingFriendsRevealOpacity'), 0.2);
    expect(
      _translation(tester, 'foundingFriendsRevealTransform'),
      const Offset(20, 0),
    );
    expect(_opacity(tester, 'venueCardRevealOpacity'), 0.2);
    expect(
      _translation(tester, 'venueCardRevealTransform'),
      const Offset(-20, 0),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('venueCardReveal')),
        matching: find.byKey(const Key('venueIntroductionBounds')),
      ),
      findsNothing,
    );

    for (final example in const [
      (
        revealKey: 'foundingFriendsReveal',
        opacityKey: 'foundingFriendsRevealOpacity',
        transformKey: 'foundingFriendsRevealTransform',
      ),
      (
        revealKey: 'venueCardReveal',
        opacityKey: 'venueCardRevealOpacity',
        transformKey: 'venueCardRevealTransform',
      ),
    ]) {
      final reveal = find.byKey(Key(example.revealKey));
      final initialSize = tester.getSize(reveal);
      await _bringIntoView(tester, reveal);
      await tester.pumpAndSettle();

      expect(_opacity(tester, example.opacityKey), 1);
      expect(_translation(tester, example.transformKey), Offset.zero);
      expect(tester.getSize(reveal), initialSize);

      _scrollController(tester).jumpTo(0);
      await tester.pump();
      await _bringIntoView(tester, reveal);
      expect(_opacity(tester, example.opacityKey), 1);
      expect(_translation(tester, example.transformKey), Offset.zero);
    }
  });

  testWidgets('narrow promotional movement is reduced to twelve pixels', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpLandingPage(tester);

    expect(
      _translation(tester, 'foundingFriendsRevealTransform'),
      const Offset(12, 0),
    );
    expect(
      _translation(tester, 'venueCardRevealTransform'),
      const Offset(-12, 0),
    );
  });

  testWidgets('reduced motion renders every reveal in its final state', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 900));
    await _pumpLandingPage(tester, disableAnimations: true);

    _expectResearchFinalState(tester);
    _expectMembershipFinalState(tester);
    expect(_opacity(tester, 'foundingFriendsRevealOpacity'), 1);
    expect(
      _translation(tester, 'foundingFriendsRevealTransform'),
      Offset.zero,
    );
    expect(_opacity(tester, 'venueCardRevealOpacity'), 1);
    expect(_translation(tester, 'venueCardRevealTransform'), Offset.zero);
    expect(
      find.descendant(
        of: find.byType(LandingScrollReveal),
        matching: find.byType(TweenAnimationBuilder<double>),
      ),
      findsNothing,
    );
  });
}

Future<void> _pumpLandingPage(
  WidgetTester tester, {
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: const LandingPage(),
    ),
  );
  await tester.pump();
}

Future<void> _bringIntoView(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.pump();
}

ScrollController _scrollController(WidgetTester tester) => tester
    .widget<SingleChildScrollView>(
      find.byKey(const Key('landingPageScrollView')),
    )
    .controller!;

double _opacity(WidgetTester tester, String key) =>
    tester.widget<Opacity>(find.byKey(Key(key))).opacity;

Offset _translation(WidgetTester tester, String key) {
  final translation = tester
      .widget<Transform>(find.byKey(Key(key)))
      .transform
      .getTranslation();
  return Offset(translation.x, translation.y);
}

void _expectResearchFinalState(WidgetTester tester) {
  for (var index = 0; index < 4; index++) {
    expect(_opacity(tester, 'researchStatRevealOpacity$index'), 1);
    expect(
      _translation(tester, 'researchStatRevealTransform$index'),
      Offset.zero,
    );
  }
}

void _expectMembershipFinalState(WidgetTester tester) {
  for (final id in ['free', 'hereNow', 'lifetime']) {
    expect(_opacity(tester, 'membershipCardRevealOpacity-$id'), 1);
    expect(
      _translation(tester, 'membershipCardRevealTransform-$id'),
      Offset.zero,
    );
  }
}
