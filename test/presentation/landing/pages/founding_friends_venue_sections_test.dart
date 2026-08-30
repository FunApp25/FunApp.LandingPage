import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/founding_friends_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_cta_button.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_promotional_card.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/venue_section.dart';

const _foundingFriendsBodyFirst =
    'Thank you for joining Fun App so early as a Founding Friend. You will '
    'maintain Founding Friend status forever and help Fun App change the way '
    'the world makes friends.';
const _foundingFriendsBodySecond =
    'Welcome aboard, this is going to be an exciting journey. Let’s change '
    'the world together.';
const _venueIntroductionFirst =
    'Venues and events of every shape, size, type and location will be central '
    'to Fun App’s mission to make the world a friendlier place.';
const _venueIntroductionSecond =
    'Venues love what Fun App is doing. Fun App loves talking to venues.';

void main() {
  testWidgets('renders authoritative English founding and venue copy', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('Founding Friends are Very Special'), findsOneWidget);
    expect(find.text(_foundingFriendsBodyFirst), findsOneWidget);
    expect(find.text(_foundingFriendsBodySecond), findsOneWidget);
    expect(find.text('Become a Founding Friend'), findsOneWidget);

    final venueIntroductionHeading = tester.widget<Text>(
      find.byKey(const Key('venueIntroductionHeadingText')),
    );
    expect(
      venueIntroductionHeading.textSpan?.toPlainText(),
      'I Run a Venue...',
    );
    expect(find.text(_venueIntroductionFirst), findsOneWidget);
    expect(find.text(_venueIntroductionSecond), findsOneWidget);
    expect(find.text('I Run a Venue...'), findsNWidgets(2));
    expect(find.text('How can I help change the world?'), findsOneWidget);
    expect(find.text('Let’s Start a Conversation'), findsOneWidget);
  });

  for (final example in const [
    (
      locale: Locale('es'),
      foundingHeading: 'Los Founding Friends son muy especiales',
      foundingCta: 'Hazte Founding Friend',
      venueHeading: 'Gestiono un espacio...',
      venueCta: 'Empecemos una conversación',
    ),
    (
      locale: Locale('cy'),
      foundingHeading: 'Mae Founding Friends yn Arbennig Iawn',
      foundingCta: 'Dewch yn Founding Friend',
      venueHeading: 'Rwy’n Rhedeg Lleoliad...',
      venueCta: 'Dewch i Ni Ddechrau Sgwrs',
    ),
    (
      locale: Locale('be'),
      foundingHeading: 'Founding Friends — вельмі асаблівыя',
      foundingCta: 'Станьце Founding Friend',
      venueHeading: 'Я кірую пляцоўкай...',
      venueCta: 'Пачнём размову',
    ),
  ]) {
    testWidgets('renders responsive ${example.locale.languageCode} content', (
      tester,
    ) async {
      _setTestSurface(tester, const Size(320, 568));
      await _pumpApp(tester, locale: example.locale);

      expect(find.text(example.foundingHeading), findsOneWidget);
      expect(find.text(example.foundingCta), findsOneWidget);
      expect(
        find.bySemanticsLabel(example.venueHeading),
        findsNWidgets(2),
      );
      expect(find.text(example.venueCta), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses exact committed Figma image compositions', (tester) async {
    await _pumpApp(tester);

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
    _expectSvgAsset(
      tester,
      const Key('foundingFriendsCtaArrow'),
      AppAssets.arrowUpRight,
    );
    _expectSvgAsset(
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

  testWidgets('uses wide cards and content-preserving stacked cards', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(320, 568), usesWideComposition: false),
      (size: Size(768, 1024), usesWideComposition: false),
      (size: Size(1440, 900), usesWideComposition: true),
    ]) {
      _setTestSurface(tester, example.size);
      await _pumpApp(tester);

      expect(find.byType(LandingPromotionalCard), findsNWidgets(2));
      for (final prefix in ['foundingFriends', 'venueCard']) {
        final layout = example.usesWideComposition ? 'Wide' : 'Stacked';
        expect(
          find.byKey(Key('$prefix${layout}Layout')),
          findsOneWidget,
        );
        final image = find.byKey(Key('${prefix}Image'));
        expect(image, findsOneWidget);
        expect(tester.getSize(image).width, greaterThan(0));
        expect(tester.getSize(image).height, greaterThan(0));
      }
      expect(
        tester.getSize(find.byType(FoundingFriendsSection)).width,
        lessThanOrEqualTo(example.size.width),
      );
      expect(
        tester.getSize(find.byType(VenueSection)).width,
        lessThanOrEqualTo(example.size.width),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('exposes headings and one semantic node per composition', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpApp(tester);

    _expectHeaderSemantics(
      tester,
      const Key('foundingFriendsHeadingSemantics'),
      'Founding Friends are Very Special',
    );
    _expectHeaderSemantics(
      tester,
      const Key('venueIntroductionHeadingSemantics'),
      'I Run a Venue...',
    );
    _expectHeaderSemantics(
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
        'Founding Friends are Very Special',
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
      expect(
        find.descendant(of: section, matching: find.byType(InkWell)),
        findsNothing,
      );
    }
    expect(find.byType(LandingCtaButton), findsNWidgets(4));
    semantics.dispose();
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  tester.binding.platformDispatcher.localesTestValue = <Locale>[locale];
  addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(const FunAppLandingPageApp());
  await tester.pump();
}

void _setTestSurface(WidgetTester tester, Size size) {
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
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

void _expectSvgAsset(
  WidgetTester tester,
  Key key,
  String expectedAsset,
) {
  final picture = tester.widget<SvgPicture>(find.byKey(key));
  expect(picture.bytesLoader, isA<SvgAssetLoader>());
  expect(
    (picture.bytesLoader as SvgAssetLoader).assetName,
    expectedAsset,
  );
}

void _expectHeaderSemantics(
  WidgetTester tester,
  Key key,
  String expectedLabel,
) {
  final data = tester.getSemantics(find.byKey(key)).getSemanticsData();
  expect(data.label, expectedLabel);
  expect(data.flagsCollection.isHeader, isTrue);
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
