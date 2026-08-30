import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/connection_experience_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/faq_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/founding_friends_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/founding_offer_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/hero_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_header.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/membership_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/problem_statement_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/research_stats_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/venue_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/welcome_statement_section.dart';

void main() {
  testWidgets('renders every landing section in Figma order', (tester) async {
    await _pumpApp(tester);

    expect(find.byType(LandingPage), findsOneWidget);

    const expectedTypes = <Type>[
      LandingHeader,
      HeroSection,
      ProblemStatementSection,
      ResearchStatsSection,
      ConnectionExperienceSection,
      MembershipSection,
      FoundingOfferSection,
      FoundingFriendsSection,
      VenueSection,
      WelcomeStatementSection,
      FaqSection,
      LandingFooter,
    ];

    for (final type in expectedTypes) {
      expect(find.byType(type), findsOneWidget);
    }

    final sections = tester.widget<Column>(
      find.byKey(const Key('landingPageSections')),
    );
    expect(
      sections.children.map((widget) => widget.runtimeType),
      orderedEquals(expectedTypes),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.runtimeType.toString() == 'LandingSectionPlaceholder',
      ),
      findsNothing,
    );
  });

  testWidgets('renders the authoritative English header and hero copy', (
    tester,
  ) async {
    await _pumpApp(tester);

    for (final label in [
      'OUR BELIEF',
      'MEMBERSHIP',
      'FOUNDING FRIENDS',
      'FOR VENUES',
    ]) {
      expect(find.text(label), findsNWidgets(2));
    }
    for (final label in [
      'Contact Us',
      'A FRIENDLIER WAY TO CONNECT',
      'Join the Waitlist',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    final headline = tester.widget<Text>(
      find.byKey(const Key('heroHeadlineText')),
    );
    expect(
      headline.textSpan?.toPlainText(),
      'Fun App started from a belief that creating connections should be '
      'SO much better',
    );
    expect(
      find.text(
        'Welcome to a friendlier future. Welcome to Fun App. Fun App believes '
        'friendship, group and dating platforms can be SO much better.',
      ),
      findsOneWidget,
    );
  });

  for (final example in const [
    (
      locale: Locale('es'),
      contact: 'Contáctanos',
      eyebrow: 'UNA FORMA MÁS AMABLE DE CONECTAR',
      headline:
          'Fun App nació de la convicción de que crear conexiones debería ser '
          'MUCHO mejor',
      waitlist: 'Únete a la lista de espera',
    ),
    (
      locale: Locale('cy'),
      contact: 'Cysylltwch â Ni',
      eyebrow: 'FFORDD FWY CYFEILLGAR O GYSYLLTU',
      headline:
          'Dechreuodd Fun App o’r gred y dylai creu cysylltiadau fod '
          'GYMAINT yn well',
      waitlist: 'Ymunwch â’r Rhestr Aros',
    ),
    (
      locale: Locale('be'),
      contact: 'Звязацца з намі',
      eyebrow: 'БОЛЬШ ПРЫЯЗНЫ СПОСАБ ЗНАЁМІЦЦА',
      headline:
          'Fun App пачаўся з веры ў тое, што наладжваць сувязі павінна быць '
          'НАШМАТ лепш',
      waitlist: 'Далучыцца да спіса чакання',
    ),
  ]) {
    testWidgets('renders representative ${example.locale.languageCode} copy', (
      tester,
    ) async {
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      await _pumpApp(tester, locale: example.locale);

      expect(find.text(example.contact), findsOneWidget);
      expect(find.text(example.eyebrow), findsOneWidget);
      expect(find.text(example.waitlist), findsOneWidget);
      expect(find.bySemanticsLabel(example.headline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses only committed local header and hero assets', (
    tester,
  ) async {
    await _pumpApp(tester);

    final logoWidgets = tester.widgetList<FunAppLogo>(find.byType(FunAppLogo));
    expect(logoWidgets, hasLength(2));
    expect(
      logoWidgets.map((logo) => logo.variant),
      everyElement(FunAppLogoVariant.landingV2),
    );
    _expectSvgAsset(
      tester,
      const Key('funAppLogo'),
      AppAssets.funAppLogoV2,
    );
    _expectSvgAsset(
      tester,
      const Key('heroEyebrowGlyph'),
      AppAssets.heroEyebrowGlyph,
    );
    _expectSvgAsset(
      tester,
      const Key('landingCtaArrow'),
      AppAssets.arrowUpRight,
    );

    final heroImage = tester.widget<Image>(
      find.byKey(const Key('heroPeopleImage')),
    );
    expect(heroImage.image, isA<AssetImage>());
    expect(
      (heroImage.image as AssetImage).assetName,
      AppAssets.heroPeople,
    );
  });

  testWidgets('uses a vertically scrollable page composition', (tester) async {
    await _pumpApp(tester);

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(scrollView.scrollDirection, Axis.vertical);
    expect(find.byType(CustomScrollView), findsNothing);
    expect(find.byType(SliverList), findsNothing);
    expect(find.byType(SliverToBoxAdapter), findsNothing);

    final initialHeaderTop = tester.getTopLeft(find.byType(LandingHeader)).dy;
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pump();

    expect(
      tester.getTopLeft(find.byType(LandingHeader)).dy,
      lessThan(initialHeaderTop),
    );
  });

  testWidgets('renders safely at narrow, intermediate, and wide widths', (
    tester,
  ) async {
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.devicePixelRatio = 1;

    for (final size in [
      const Size(320, 568),
      const Size(768, 1024),
      const Size(1440, 900),
    ]) {
      tester.view.physicalSize = size;
      await _pumpApp(tester);

      expect(find.byType(LandingPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('heroPeopleImage')), findsOneWidget);

      if (size.width == 1440) {
        expect(
          find.byKey(const Key('landingHeaderHorizontalLayout')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('heroDesktopLayout')), findsOneWidget);
      } else {
        expect(
          find.byKey(const Key('landingHeaderWrappedLayout')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('heroStackedLayout')), findsOneWidget);
      }

      for (final finder in [
        find.byType(LandingHeader),
        find.byType(HeroSection),
        find.byType(ProblemStatementSection),
        find.byType(ResearchStatsSection),
        find.byType(ConnectionExperienceSection),
        find.byType(MembershipSection),
        find.byType(FoundingOfferSection),
        find.byType(FoundingFriendsSection),
        find.byType(VenueSection),
        find.byType(WelcomeStatementSection),
        find.byType(FaqSection),
        find.byType(LandingFooter),
      ]) {
        expect(tester.getSize(finder).width, lessThanOrEqualTo(size.width));
      }
    }
  });

  testWidgets('exposes one hero heading and image semantic description', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpApp(tester);

    expect(
      tester.getSemantics(
        find.byKey(const Key('heroHeadlineSemantics')),
      ),
      matchesSemantics(
        label:
            'Fun App started from a belief that creating connections should be '
            'SO much better',
        isHeader: true,
      ),
    );
    final imageSemantics = tester
        .getSemantics(find.byKey(const Key('heroImageSemantics')))
        .getSemanticsData();
    expect(
      imageSemantics.label,
      'Three smiling people looking toward the camera.',
    );
    expect(imageSemantics.flagsCollection.isImage, isTrue);
    expect(find.bySemanticsLabel('Fun App'), findsNWidgets(2));

    final eyebrowGlyph = tester.widget<SvgPicture>(
      find.byKey(const Key('heroEyebrowGlyph')),
    );
    final ctaArrow = tester.widget<SvgPicture>(
      find.byKey(const Key('landingCtaArrow')),
    );
    expect(eyebrowGlyph.excludeFromSemantics, isTrue);
    expect(ctaArrow.excludeFromSemantics, isTrue);
    expect(find.byType(ButtonStyleButton), findsNothing);
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
