import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/hero_section.dart';

import '../landing_test_helpers.dart';

void main() {
  testWidgets('Hero copy and artwork remain readable throughout entrance', (
    tester,
  ) async {
    await _pumpHero(tester, size: const Size(1440, 900));

    expect(find.byKey(const Key('heroContentBounds')), findsOneWidget);
    expect(find.byKey(const Key('heroPeopleImage')), findsOneWidget);
    expect(_opacity(tester, 'heroCopyOpacity'), 0.84);
    expect(_opacity(tester, 'heroArtworkOpacity'), 0.80);
    expect(_translation(tester, 'heroCopyTransform'), const Offset(0, 6));
    expect(_translation(tester, 'heroArtworkTransform'), const Offset(8, 0));

    await tester.pump(const Duration(milliseconds: 1));

    expect(_opacity(tester, 'heroCopyOpacity'), greaterThan(0.84));
    expect(_opacity(tester, 'heroArtworkOpacity'), 0.80);
    expect(_translation(tester, 'heroArtworkTransform'), const Offset(8, 0));

    await tester.pump(const Duration(milliseconds: 39));

    expect(_opacity(tester, 'heroArtworkOpacity'), 0.80);
    expect(_translation(tester, 'heroArtworkTransform'), const Offset(8, 0));

    await tester.pump(const Duration(milliseconds: 280));

    expect(_opacity(tester, 'heroCopyOpacity'), closeTo(1, 0.0001));
    expect(
      _translation(tester, 'heroCopyTransform').distance,
      closeTo(0, 0.0001),
    );
    expect(_opacity(tester, 'heroArtworkOpacity'), lessThan(1));

    await tester.pump(const Duration(milliseconds: 80));
    await tester.pump(const Duration(milliseconds: 1));

    _expectFinalPaintState(tester);
    expect(find.byKey(const Key('heroEntranceSequence')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hero motion uses restrained responsive distances', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(1440, 900), copyDistance: 6.0, artworkDistance: 8.0),
      (size: Size(1024, 768), copyDistance: 6.0, artworkDistance: 8.0),
      (size: Size(768, 1024), copyDistance: 6.0, artworkDistance: 8.0),
      (size: Size(390, 844), copyDistance: 4.0, artworkDistance: 5.0),
      (size: Size(320, 568), copyDistance: 4.0, artworkDistance: 5.0),
    ]) {
      await _pumpHero(tester, size: example.size);

      expect(
        _translation(tester, 'heroCopyTransform'),
        Offset(0, example.copyDistance),
      );
      expect(
        _translation(tester, 'heroArtworkTransform'),
        Offset(example.artworkDistance, 0),
      );
      expect(find.byKey(const Key('heroPeopleImage')), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 400));

      _expectFinalPaintState(tester);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('final Hero geometry preserves established layout contracts', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(1440, 900), artworkWidth: 706.0),
      (size: Size(1024, 768), artworkWidth: 520.0),
      (size: Size(768, 1024), artworkWidth: 440.0),
      (size: Size(390, 844), artworkWidth: 340.0),
      (size: Size(320, 568), artworkWidth: 311.04),
    ]) {
      await _pumpHero(tester, size: example.size);
      await tester.pump(const Duration(milliseconds: 400));

      final cardRect = tester.getRect(find.byKey(const Key('heroCard')));
      final artworkRect = tester.getRect(
        find.byKey(const Key('heroPeopleImage')),
      );
      final contentRect = tester.getRect(
        find.byKey(const Key('heroContentBounds')),
      );

      expect(artworkRect.width, closeTo(example.artworkWidth, 0.01));
      expect(artworkRect.top, lessThan(cardRect.top));
      expect(artworkRect.right, greaterThan(cardRect.right));
      expect(artworkRect.size.aspectRatio, closeTo(706 / 717, 0.001));
      if (example.size.width == 1440) {
        expect(cardRect.width, 1360);
        expect(contentRect.left - cardRect.left, 80);
      } else {
        expect(contentRect.top, greaterThan(artworkRect.top));
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('reduced motion renders final Hero and semantics immediately', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpHero(
      tester,
      size: const Size(390, 844),
      disableAnimations: true,
    );

    _expectFinalPaintState(tester);
    expect(find.byKey(const Key('heroEntranceSequence')), findsNothing);
    expect(
      tester
          .getSemantics(find.byKey(const Key('heroHeadlineSemantics')))
          .getSemanticsData()
          .flagsCollection
          .isHeader,
      isTrue,
    );
    expect(
      tester
          .getSemantics(find.byKey(const Key('heroImageSemantics')))
          .getSemanticsData()
          .flagsCollection
          .isImage,
      isTrue,
    );
    expect(find.byKey(const Key('heroPeopleImage')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('ordinary Hero rebuild does not restart entrance', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1024, 768));
    late StateSetter rebuild;

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return const Scaffold(
              body: SingleChildScrollView(child: HeroSection()),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    final opacityBeforeRebuild = _opacity(tester, 'heroCopyOpacity');

    rebuild(() {});
    await tester.pump();

    expect(
      _opacity(tester, 'heroCopyOpacity'),
      closeTo(opacityBeforeRebuild, 0.0001),
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 1));

    _expectFinalPaintState(tester);
    expect(find.byKey(const Key('heroEntranceSequence')), findsNothing);
  });
}

Future<void> _pumpHero(
  WidgetTester tester, {
  required Size size,
  bool disableAnimations = false,
}) async {
  setTestSurface(tester, size);
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const Scaffold(
          body: SingleChildScrollView(child: HeroSection()),
        ),
      ),
    ),
  );
}

double _opacity(WidgetTester tester, String key) =>
    tester.widget<Opacity>(find.byKey(Key(key))).opacity;

Offset _translation(WidgetTester tester, String key) {
  final transform = tester.widget<Transform>(find.byKey(Key(key))).transform;
  return Offset(transform.storage[12], transform.storage[13]);
}

void _expectFinalPaintState(WidgetTester tester) {
  expect(_opacity(tester, 'heroCopyOpacity'), closeTo(1, 0.0001));
  expect(_opacity(tester, 'heroArtworkOpacity'), closeTo(1, 0.0001));
  expect(
    _translation(tester, 'heroCopyTransform').distance,
    closeTo(0, 0.0001),
  );
  expect(
    _translation(tester, 'heroArtworkTransform').distance,
    closeTo(0, 0.0001),
  );
}
