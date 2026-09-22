import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_friends/founding_friends_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_section.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_cta_button.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card.dart';

import '../landing_test_helpers.dart';

const _foundingFriendsBodyFirst =
    'Thank you for being an early bird and joining Fun App as a Founding '
    'Friend. You can keep this status forever, helping change the way the '
    'world makes friends.';
const _foundingFriendsBodySecond =
    'Welcome aboard, this is going to be an exciting journey.';
const _venueIntroductionFirst =
    'Venues and events of every shape, size, type and location will be central '
    'to Fun App’s mission to make the world a friendlier place.';
const _venueIntroductionSecond =
    'Venues love what Fun App is doing. Fun App loves talking to venues.';

void main() {
  testWidgets('renders authoritative English founding and venue copy', (
    tester,
  ) async {
    await pumpLandingApp(tester);

    expect(find.text('Founding Friends are Besties'), findsOneWidget);
    expect(find.text(_foundingFriendsBodyFirst), findsOneWidget);
    expect(find.text(_foundingFriendsBodySecond), findsOneWidget);
    expect(find.text('Become a Founding Friend'), findsOneWidget);

    final venueIntroductionHeading = tester.widget<Text>(
      find.byKey(const Key('venueIntroductionHeadingText')),
    );
    expect(
      venueIntroductionHeading.textSpan?.toPlainText(),
      'I Run a Venue',
    );
    expect(find.text(_venueIntroductionFirst), findsOneWidget);
    expect(find.text(_venueIntroductionSecond), findsOneWidget);
    expect(find.text('I Run a Venue...'), findsOneWidget);
    expect(find.text('How can I help change the world?'), findsOneWidget);
    expect(find.text('Let’s Start a Conversation'), findsOneWidget);
  });

  for (final example in const [
    (
      locale: Locale('es'),
      foundingHeading: 'Los Founding Friends son los mejores amigos',
      foundingCta: 'Hazte Founding Friend',
      venueIntro: 'Gestiono un espacio',
      venueCard: 'Gestiono un espacio...',
      venueCta: 'Empecemos una conversación',
    ),
    (
      locale: Locale('cy'),
      foundingHeading: 'Founding Friends yw’r Ffrindiau Gorau',
      foundingCta: 'Dewch yn Founding Friend',
      venueIntro: 'Rwy’n Rhedeg Lleoliad',
      venueCard: 'Rwy’n Rhedeg Lleoliad...',
      venueCta: 'Dewch i Ni Ddechrau Sgwrs',
    ),
    (
      locale: Locale('be'),
      foundingHeading: 'Founding Friends — найлепшыя сябры',
      foundingCta: 'Станьце Founding Friend',
      venueIntro: 'Я кірую пляцоўкай',
      venueCard: 'Я кірую пляцоўкай...',
      venueCta: 'Пачнём размову',
    ),
  ]) {
    testWidgets('renders responsive ${example.locale.languageCode} content', (
      tester,
    ) async {
      setTestSurface(tester, const Size(320, 568));
      await pumpLandingApp(tester, locale: example.locale);

      expect(find.text(example.foundingHeading), findsOneWidget);
      expect(find.text(example.foundingCta), findsOneWidget);
      expect(
        find.bySemanticsLabel(example.venueIntro),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(example.venueCard), findsOneWidget);
      expect(find.text(example.venueCta), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses exact committed Figma image compositions', (tester) async {
    await pumpLandingApp(tester);

    _expectImageAsset(
      tester,
      const Key('foundingFriendsImage'),
      AppAssets.foundingFriendsGroup,
    );
    _expectImageAsset(
      tester,
      const Key('venueCardImage'),
      AppAssets.venueGroup,
    );
    expect(
      tester.getSize(
        find.byKey(const Key('foundingFriendsIntrinsicArtworkBounds')),
      ),
      const Size(673, 410),
    );
    expect(
      tester.getSize(
        find.byKey(const Key('venueCardIntrinsicArtworkBounds')),
      ),
      const Size(673, 410),
    );
    for (final key in const [
      Key('foundingFriendsImage'),
      Key('venueCardImage'),
    ]) {
      expect(tester.widget<Image>(find.byKey(key)).fit, BoxFit.contain);
    }
    for (final key in const [
      Key('foundingFriendsArtworkFit'),
      Key('venueCardArtworkFit'),
    ]) {
      expect(tester.widget<FittedBox>(find.byKey(key)).fit, BoxFit.contain);
    }
    expectSvgAsset(
      tester,
      const Key('foundingFriendsCtaArrow'),
      AppAssets.arrowUpRight,
    );
    expectSvgAsset(
      tester,
      const Key('venueCardCtaArrow'),
      AppAssets.arrowUpRight,
    );

    for (final asset in [
      AppAssets.foundingFriendsGroup,
      AppAssets.venueGroup,
      AppAssets.arrowUpRight,
    ]) {
      expect(asset, startsWith('assets/'));
      expect(asset, isNot(contains('figma.com')));
    }
  });

  testWidgets('uses intentional wide, intermediate, and narrow cards', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(320, 568), layout: 'Narrow'),
      (size: Size(390, 844), layout: 'Narrow'),
      (size: Size(599, 844), layout: 'Narrow'),
      (size: Size(600, 844), layout: 'Narrow'),
      (size: Size(768, 1024), layout: 'Narrow'),
      (size: Size(900, 900), layout: 'Intermediate'),
      (size: Size(1024, 768), layout: 'Intermediate'),
      (size: Size(1200, 900), layout: 'Intermediate'),
      (size: Size(1440, 900), layout: 'Wide'),
    ]) {
      setTestSurface(tester, example.size);
      await pumpLandingApp(tester);

      expect(find.byType(LandingPromotionalCard), findsNWidgets(2));
      for (final prefix in ['foundingFriends', 'venueCard']) {
        expect(
          find.byKey(Key('$prefix${example.layout}Layout')),
          findsOneWidget,
        );
        final image = find.byKey(Key('${prefix}Image'));
        expect(image, findsOneWidget);
        expect(tester.getSize(image).width, greaterThan(0));
        expect(tester.getSize(image).height, greaterThan(0));

        final cardRect = tester.getRect(
          find.byKey(Key('${prefix}CardClip')),
        );
        final contentRect = tester.getRect(
          find.byKey(Key('${prefix}ContentBounds')),
        );
        final artworkRect = tester.getRect(
          find.byKey(Key('${prefix}ArtworkViewport')),
        );
        final ctaRect = tester.getRect(find.byKey(Key('${prefix}Cta')));
        expect(ctaRect.left, greaterThanOrEqualTo(cardRect.left));
        expect(ctaRect.right, lessThanOrEqualTo(cardRect.right));

        if (example.layout == 'Narrow') {
          expect(contentRect.bottom, lessThan(artworkRect.top));
        } else if (prefix == 'foundingFriends') {
          expect(contentRect.left, lessThan(artworkRect.left));
        } else {
          expect(artworkRect.left, lessThan(contentRect.left));
        }

        if (example.layout == 'Wide') {
          final wideLayout = tester.widget<ConstrainedBox>(
            find.byKey(Key('${prefix}WideLayout')),
          );
          expect(cardRect.width, 1360);
          expect(artworkRect.size, const Size(673, 410));
          expect(
            wideLayout.constraints.minHeight,
            prefix == 'foundingFriends' ? 534 : 444,
          );
          if (prefix == 'foundingFriends') {
            expect(contentRect.left - cardRect.left, 128);
            expect(artworkRect.left - cardRect.left, 716);
            expect(
              tester
                  .widget<FittedBox>(
                    find.byKey(const Key('foundingFriendsArtworkFit')),
                  )
                  .alignment,
              Alignment.centerLeft,
            );
          } else {
            expect(cardRect.right - contentRect.right, 140);
            expect(artworkRect.left - cardRect.left, -7);
            expect(
              tester
                  .widget<FittedBox>(
                    find.byKey(const Key('venueCardArtworkFit')),
                  )
                  .alignment,
              Alignment.centerRight,
            );
          }
        } else if (example.size.width < 600) {
          expect(artworkRect.size, const Size(382, 233));
          final overscan = (382 - cardRect.width) / 2;
          expect(artworkRect.left - cardRect.left, -overscan);
          expect(artworkRect.right - cardRect.right, overscan);
        } else {
          const expectedRatio = 673 / 410;
          expect(artworkRect.size.aspectRatio, closeTo(expectedRatio, 0.001));
          if (prefix == 'foundingFriends') {
            expect(artworkRect.right, closeTo(cardRect.right, 0.01));
          } else {
            expect(artworkRect.left, closeTo(cardRect.left, 0.01));
          }
        }
      }
      expect(
        tester.getSize(find.byType(FoundingFriendsSection)).width,
        lessThanOrEqualTo(example.size.width),
      );
      expect(
        tester.getSize(find.byType(VenueSection)).width,
        lessThanOrEqualTo(example.size.width),
      );
      if (example.size.width == 1440) {
        expect(
          tester
              .getSize(find.byKey(const Key('venueIntroductionBounds')))
              .width,
          522,
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('matches the vertical mobile promotional-card composition', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await pumpLandingApp(tester);

    await tester.ensureVisible(
      find.byKey(const Key('foundingFriendsReveal')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('venueCardReveal')));
    await tester.pumpAndSettle();

    Rect? venueCardRect;
    for (final prefix in ['foundingFriends', 'venueCard']) {
      final cardRect = tester.getRect(find.byKey(Key('${prefix}CardClip')));
      final contentRect = tester.getRect(
        find.byKey(Key('${prefix}ContentBounds')),
      );
      final artworkRect = tester.getRect(
        find.byKey(Key('${prefix}ArtworkViewport')),
      );
      final ctaRect = tester.getRect(find.byKey(Key('${prefix}Cta')));
      final contentPadding = tester.widget<Padding>(
        find.byKey(Key('${prefix}NarrowContentPadding')),
      );
      final heading = tester.widget<Text>(
        find.byKey(Key('${prefix}HeadingText')),
      );
      final body = tester.widget<Text>(find.byKey(Key('${prefix}Body0')));

      expect(cardRect.left, 16);
      expect(cardRect.width, 358);
      expect(
        contentPadding.padding,
        const EdgeInsets.symmetric(horizontal: 16),
      );
      expect(contentRect.top - cardRect.top, 80);
      expect(contentRect.left - cardRect.left, 16);
      expect(contentRect.width, 326);
      expect(heading.style?.fontSize, 32);
      expect(heading.style?.height, closeTo(40 / 32, 0.0001));
      expect(body.style?.fontSize, 16);
      expect(body.style?.height, closeTo(24 / 16, 0.0001));
      expect(ctaRect.width, contentRect.width);
      expect(ctaRect.height, greaterThanOrEqualTo(48), reason: prefix);
      expect(artworkRect.size, const Size(382, 233));
      expect(artworkRect.top - contentRect.bottom, 80);
      expect(artworkRect.left - cardRect.left, -12);
      expect(artworkRect.right - cardRect.right, 12);
      if (prefix == 'venueCard') {
        venueCardRect = cardRect;
      }
    }

    final foundingFirstBody = tester.getRect(
      find.byKey(const Key('foundingFriendsBody0')),
    );
    final foundingSecondBody = tester.getRect(
      find.byKey(const Key('foundingFriendsBody1')),
    );
    expect(foundingSecondBody.top - foundingFirstBody.bottom, 12);

    final venueIntro = tester.getRect(
      find.byKey(const Key('venueIntroductionBounds')),
    );
    final venueCard = venueCardRect;
    final venueIntroHeading = tester.widget<Text>(
      find.byKey(const Key('venueIntroductionHeadingText')),
    );
    final venueIntroBody = tester.widget<Text>(
      find.byKey(const Key('venueIntroductionBody0')),
    );
    expect(venueIntro.width, 358);
    expect(venueIntroHeading.textSpan?.style?.fontSize, 32);
    expect(
      venueIntroHeading.textSpan?.style?.height,
      closeTo(42 / 32, 0.0001),
    );
    expect(venueIntroBody.style?.fontSize, 16);
    expect(venueIntroBody.style?.height, closeTo(24 / 16, 0.0001));
    expect(venueCard!.top - venueIntro.bottom, 40);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps promotional CTAs safe at mobile and boundary widths', (
    tester,
  ) async {
    for (final locale in AppLocalizations.supportedLocales) {
      for (final width in [320.0, 390.0, 599.0, 600.0]) {
        setTestSurface(tester, Size(width, 844));
        await pumpLandingApp(tester, locale: locale);

        for (final prefix in ['foundingFriends', 'venueCard']) {
          final cta = find.byKey(Key('${prefix}Cta'));
          final card = find.byKey(Key('${prefix}CardClip'));
          final arrow = find.byKey(Key('${prefix}CtaArrow'));
          final label = find.descendant(of: cta, matching: find.byType(Text));
          final ctaRect = tester.getRect(cta);
          final cardRect = tester.getRect(card);

          expect(label, findsOneWidget);
          expect(tester.widget<Text>(label).data, isNotEmpty);
          expect(arrow, findsOneWidget);
          expect(ctaRect.left, greaterThanOrEqualTo(cardRect.left));
          expect(ctaRect.right, lessThanOrEqualTo(cardRect.right));
          expect(cardRect.left, greaterThanOrEqualTo(0));
          expect(cardRect.right, lessThanOrEqualTo(width));
        }
        expect(
          tester.takeException(),
          isNull,
          reason: '${locale.languageCode} must fit promotional CTAs at $width.',
        );
      }
    }
  });

  testWidgets('promotional layout thresholds are stable on both sides', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1400, 1000));

    for (final example in const [
      (width: 1280.0, layout: 'Wide'),
      (width: 1279.0, layout: 'Intermediate'),
      (width: 780.0, layout: 'Intermediate'),
      (width: 779.0, layout: 'Narrow'),
    ]) {
      await _pumpPromotionalCard(tester, width: example.width);
      expect(
        find.byKey(Key('foundingFriends${example.layout}Layout')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('exposes headings and one semantic node per composition', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpLandingApp(tester);

    expectHeaderSemantics(
      tester,
      const Key('foundingFriendsHeadingSemantics'),
      'Founding Friends are Besties',
    );
    expectHeaderSemantics(
      tester,
      const Key('venueIntroductionHeadingSemantics'),
      'I Run a Venue',
    );
    expectHeaderSemantics(
      tester,
      const Key('venueCardHeadingSemantics'),
      'I Run a Venue...',
    );

    _expectImageSemantics(
      tester,
      const Key('foundingFriendsImageSemantics'),
      'Two people posing closely together outdoors.',
    );
    _expectImageSemantics(
      tester,
      const Key('venueCardImageSemantics'),
      'Five people lying in a circle with their heads together.',
    );

    final foundingCardText = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(LandingPromotionalCard).first,
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data)
        .whereType<String>()
        .toList();
    expect(
      foundingCardText,
      orderedEquals([
        'Founding Friends are Besties',
        _foundingFriendsBodyFirst,
        _foundingFriendsBodySecond,
        'Become a Founding Friend',
      ]),
    );

    for (final key in const [
      Key('foundingFriendsCtaArrow'),
      Key('venueCardCtaArrow'),
    ]) {
      expect(
        tester.widget<SvgPicture>(find.byKey(key)).excludeFromSemantics,
        isTrue,
      );
    }
    for (final section in [
      find.byType(FoundingFriendsSection),
      find.byType(VenueSection),
    ]) {
      expect(
        find.descendant(
          of: section,
          matching: find.byType(ButtonStyleButton),
        ),
        findsNothing,
      );
    }
    expect(
      find.descendant(
        of: find.byType(FoundingFriendsSection),
        matching: find.byType(InkWell),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(VenueSection),
        matching: find.byType(InkWell),
      ),
      findsOneWidget,
    );
    expect(find.byType(LandingCtaButton), findsNWidgets(3));
    semantics.dispose();
  });
}

Future<void> _pumpPromotionalCard(
  WidgetTester tester, {
  required double width,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: const LandingPromotionalCard(
              variant: LandingPromotionalCardVariant.foundingFriends,
              heading: 'Founding Friends are Besties',
              bodyParagraphs: [
                _foundingFriendsBodyFirst,
                _foundingFriendsBodySecond,
              ],
              ctaLabel: 'Become a Founding Friend',
              imageSemanticLabel:
                  'Two people posing closely together outdoors.',
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void _expectImageAsset(
  WidgetTester tester,
  Key key,
  String expectedAsset,
) {
  final image = tester.widget<Image>(find.byKey(key));
  expect(image.image, isA<AssetImage>());
  expect((image.image as AssetImage).assetName, expectedAsset);
}

void _expectImageSemantics(
  WidgetTester tester,
  Key key,
  String expectedLabel,
) {
  final data = tester.getSemantics(find.byKey(key)).getSemanticsData();
  expect(data.label, expectedLabel);
  expect(data.flagsCollection.isImage, isTrue);
}
