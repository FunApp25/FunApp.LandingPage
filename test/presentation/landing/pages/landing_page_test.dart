import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/connection_experience_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/faq_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/founding_friends_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/founding_member_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/founding_offer_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/hero_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_header.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_navigation_item.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/membership_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/problem_statement_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/research_stats_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/venue_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/welcome_statement_section.dart';

import '../landing_test_helpers.dart';

void main() {
  testWidgets('renders all 13 landing surfaces in Figma order', (tester) async {
    await pumpLandingApp(tester);

    expect(find.byType(LandingPage), findsOneWidget);

    const expectedSectionTypes = <Type>[
      HeroSection,
      ProblemStatementSection,
      ResearchStatsSection,
      ConnectionExperienceSection,
      MembershipSection,
      FoundingOfferSection,
      FoundingMemberSection,
      FoundingFriendsSection,
      VenueSection,
      WelcomeStatementSection,
      FaqSection,
      LandingFooter,
    ];

    expect(find.byType(LandingHeader), findsOneWidget);
    expect(expectedSectionTypes, hasLength(12));
    for (final type in expectedSectionTypes) {
      expect(find.byType(type), findsOneWidget);
    }

    final sections = tester.widget<Column>(
      find.byKey(const Key('landingPageSections')),
    );
    expect(
      sections.children.map((widget) => widget.runtimeType),
      orderedEquals(expectedSectionTypes),
    );
  });

  testWidgets('renders the authoritative English header and hero copy', (
    tester,
  ) async {
    await pumpLandingApp(tester);

    for (final label in [
      'OUR BELIEF',
      'MEMBERSHIP',
      'FOUNDING FRIENDS',
      'FOR VENUES',
    ]) {
      expect(find.text(label), findsNWidgets(2));
    }
    for (final label in ['Contact Us', 'A FRIENDLIER WAY TO CONNECT']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Join the Waitlist'), findsNothing);
    expect(find.byKey(const Key('landingHeroWaitlistCta')), findsNothing);

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
        'Fun App is going to work differently… very differently! A warm, '
        'welcoming and respectful environment where users can meet others '
        'online or IRL, free of charge, in thousands of venues of all shapes, '
        'sizes and types around the country. But, let us explain why change '
        'is needed.',
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
    ),
    (
      locale: Locale('cy'),
      contact: 'Cysylltwch â Ni',
      eyebrow: 'FFORDD FWY CYFEILLGAR O GYSYLLTU',
      headline:
          'Dechreuodd Fun App o’r gred y dylai creu cysylltiadau fod '
          'GYMAINT yn well',
    ),
    (
      locale: Locale('be'),
      contact: 'Звязацца з намі',
      eyebrow: 'БОЛЬШ ПРЫЯЗНЫ СПОСАБ ЗНАЁМІЦЦА',
      headline:
          'Fun App пачаўся з веры ў тое, што наладжваць сувязі павінна быць '
          'НАШМАТ лепш',
    ),
  ]) {
    testWidgets('renders representative ${example.locale.languageCode} copy', (
      tester,
    ) async {
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      await pumpLandingApp(tester, locale: example.locale);

      expect(find.text(example.contact), findsOneWidget);
      expect(find.text(example.eyebrow), findsOneWidget);
      expect(find.byKey(const Key('landingHeroWaitlistCta')), findsNothing);
      expect(find.bySemanticsLabel(example.headline), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses only committed local header and hero assets', (
    tester,
  ) async {
    await pumpLandingApp(tester);

    final logoWidgets = tester.widgetList<FunAppLogo>(find.byType(FunAppLogo));
    expect(logoWidgets, hasLength(2));
    expect(
      logoWidgets.map((logo) => logo.variant),
      everyElement(FunAppLogoVariant.landingV2),
    );
    expectSvgAsset(
      tester,
      const Key('funAppLogo'),
      AppAssets.funAppLogoV2,
    );
    expectSvgAsset(
      tester,
      const Key('heroEyebrowGlyph'),
      AppAssets.heroEyebrowGlyph,
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

  testWidgets('keeps the header outside the single scrolling page body', (
    tester,
  ) async {
    await pumpLandingApp(tester);

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(scrollView.scrollDirection, Axis.vertical);
    expect(scrollView.controller, isNotNull);
    expect(
      find.ancestor(
        of: find.byType(LandingHeader),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );

    final initialHeaderTop = tester.getTopLeft(find.byType(LandingHeader)).dy;
    final initialHeroTop = tester.getTopLeft(find.byType(HeroSection)).dy;
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pump();

    expect(
      tester.getTopLeft(find.byType(LandingHeader)).dy,
      initialHeaderTop,
    );
    expect(
      tester.getTopLeft(find.byType(HeroSection)).dy,
      lessThan(initialHeroTop),
    );
  });

  testWidgets('maps header and footer navigation to anchored sections', (
    tester,
  ) async {
    const targets = <Type>[
      HeroSection,
      MembershipSection,
      FoundingFriendsSection,
      VenueSection,
    ];

    for (var index = 0; index < targets.length; index++) {
      await pumpLandingApp(tester);
      await _moveToPageEnd(tester);
      await tester.tap(
        find.byKey(Key('landingHeaderNavigationItem$index')),
      );
      await tester.pumpAndSettle();
      _expectTargetBelowHeader(tester, targets[index]);

      await _moveToPageEnd(tester);
      await tester.tap(find.byKey(Key('footerNavigationItem$index')));
      await tester.pumpAndSettle();
      _expectTargetBelowHeader(tester, targets[index]);
    }
  });

  testWidgets('navigation respects reduced motion', (
    tester,
  ) async {
    await _pumpLandingPage(tester, disableAnimations: true);
    await _moveToPageEnd(tester);

    final scrollController = _scrollController(tester);
    await tester.tap(
      find.byKey(const Key('landingHeaderNavigationItem0')),
    );
    expect(scrollController.offset, scrollController.position.minScrollExtent);
    _expectTargetBelowHeader(tester, HeroSection);
  });

  testWidgets('navigation items support Enter and Space activation', (
    tester,
  ) async {
    var activationCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LandingNavigationItem(
            label: 'OUR BELIEF',
            onSelected: () => activationCount++,
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activationCount, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(activationCount, 2);
  });

  testWidgets('navigation exposes a full hover and keyboard-focus surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LandingNavigationItem(
            label: 'OUR BELIEF',
            onSelected: () {},
          ),
        ),
      ),
    );

    final itemFinder = find.byType(LandingNavigationItem);
    final visualFinder = find.descendant(
      of: itemFinder,
      matching: find.byKey(const Key('landingNavigationVisualSurface')),
    );
    expect(tester.getSize(itemFinder).height, greaterThanOrEqualTo(44));

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(itemFinder));
    await tester.pump();
    expect(
      tester.widget<Material>(visualFinder).color,
      AppColors.energeticPlum.withValues(alpha: 0.06),
    );
    await mouse.removePointer();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final focusedMaterial = tester.widget<Material>(visualFinder);
    final focusedShape = focusedMaterial.shape! as RoundedRectangleBorder;
    expect(
      focusedMaterial.color,
      AppColors.energeticPlum.withValues(alpha: 0.08),
    );
    expect(focusedShape.side.color, AppColors.energeticPlum);
    expect(focusedShape.side.width, 2);
    expect(tester.getSize(itemFinder).height, greaterThanOrEqualTo(44));
  });

  testWidgets('navigation is accessible while Contact Us stays unwired', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpLandingApp(tester);

    for (final prefix in [
      'landingHeaderNavigationItem',
      'footerNavigationItem',
    ]) {
      for (var index = 0; index < 4; index++) {
        final itemFinder = find.byKey(Key('$prefix$index'));
        final itemSemantics = tester
            .getSemantics(itemFinder)
            .getSemanticsData();
        expect(itemSemantics.flagsCollection.isButton, isTrue);
        final inkWell = tester.widget<InkWell>(
          find.descendant(of: itemFinder, matching: find.byType(InkWell)),
        );
        expect(inkWell.mouseCursor, SystemMouseCursors.click);
        expect(tester.getSize(itemFinder).height, greaterThanOrEqualTo(44));
      }
    }

    final headerBoundary = tester.widget<DecoratedBox>(
      find.byKey(const Key('landingHeaderBoundary')),
    );
    final headerDecoration = headerBoundary.decoration as BoxDecoration;
    final headerBorder = headerDecoration.border! as Border;
    expect(headerBorder.bottom.color.a, greaterThan(0));

    final contact = tester
        .getSemantics(find.text('Contact Us'))
        .getSemanticsData();
    expect(contact.label, 'Contact Us');
    expect(contact.flagsCollection.isButton, isFalse);
    expect(contact.flagsCollection.isLink, isFalse);
    expect(
      find.descendant(
        of: find.byKey(const Key('landingHeaderContactCta')),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
    semantics.dispose();
  });

  testWidgets('renders safely at narrow, intermediate, and wide widths', (
    tester,
  ) async {
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.devicePixelRatio = 1;

    for (final size in [
      const Size(320, 568),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(900, 800),
      const Size(1024, 768),
      const Size(1200, 900),
      const Size(1440, 900),
    ]) {
      tester.view.physicalSize = size;
      await pumpLandingApp(tester);

      expect(find.byType(LandingPage), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'No layout exception is expected at $size.',
      );
      expect(find.byKey(const Key('heroPeopleImage')), findsOneWidget);
      expect(find.text('Contact Us'), findsOneWidget);

      final heroTop = tester.getTopLeft(find.byType(HeroSection)).dy;
      final heroCardTop = tester
          .getTopLeft(
            find.byKey(const Key('heroCard')),
          )
          .dy;
      final expectedHeroGap = switch (size.width) {
        >= 1200 => 24.0,
        >= 600 => 20.0,
        _ => 16.0,
      };
      expect(heroCardTop - heroTop, expectedHeroGap);

      final headline = tester.widget<Text>(
        find.byKey(const Key('heroHeadlineText')),
      );
      final expectedHeadlineSize = switch (size.width) {
        >= 1360 => 60.0,
        >= 600 => 46.0,
        >= 340 => 38.0,
        _ => 34.0,
      };
      expect(headline.textSpan?.style?.fontSize, expectedHeadlineSize);

      final heroCardRect = tester.getRect(find.byKey(const Key('heroCard')));
      final heroArtworkRect = tester.getRect(
        find.byKey(const Key('heroPeopleImage')),
      );
      expect(heroArtworkRect.top, lessThan(heroCardRect.top));
      expect(heroArtworkRect.right, greaterThan(heroCardRect.right));
      expect(
        heroArtworkRect.right - heroCardRect.right,
        greaterThanOrEqualTo(heroArtworkRect.width * 0.135),
      );
      expect(
        tester.widget<Image>(find.byKey(const Key('heroPeopleImage'))).fit,
        BoxFit.contain,
      );

      if (size.width < 1360) {
        expect(
          find.byKey(const Key('heroResponsiveLayout')),
          findsOneWidget,
        );
        final contentRect = tester.getRect(
          find.byKey(const Key('heroContentBounds')),
        );
        expect(contentRect.top, greaterThan(heroArtworkRect.top));
        expect(
          contentRect.top,
          greaterThanOrEqualTo(
            heroArtworkRect.bottom - (size.width < 600 ? 17 : 33),
          ),
        );
        if (size.width <= 390) {
          expect(heroArtworkRect.width, lessThanOrEqualTo(340));
        }
      } else {
        expect(
          tester
              .widget<ConstrainedBox>(
                find.byKey(const Key('heroDesktopLayout')),
              )
              .constraints
              .minHeight,
          644,
        );
      }

      for (final prefix in [
        'landingHeaderNavigationItem',
        'footerNavigationItem',
      ]) {
        for (var index = 0; index < 4; index++) {
          expect(
            tester.getSize(find.byKey(Key('$prefix$index'))).height,
            greaterThanOrEqualTo(44),
          );
        }
      }

      for (final target in const [
        (index: 0, type: HeroSection),
        (index: 1, type: MembershipSection),
        (index: 2, type: FoundingFriendsSection),
        (index: 3, type: VenueSection),
      ]) {
        await _moveToPageEnd(tester);
        await tester.tap(
          find.byKey(Key('landingHeaderNavigationItem${target.index}')),
        );
        await tester.pumpAndSettle();
        _expectTargetBelowHeader(tester, target.type);
        expect(tester.takeException(), isNull);
      }

      if (size.width >= 1080) {
        expect(
          find.byKey(const Key('landingHeaderHorizontalLayout')),
          findsOneWidget,
        );
      } else if (size.width >= 768) {
        expect(
          find.byKey(const Key('landingHeaderIntermediateLayout')),
          findsOneWidget,
        );
      } else {
        expect(
          find.byKey(const Key('landingHeaderNarrowLayout')),
          findsOneWidget,
        );
      }

      if (size.width >= 1360) {
        expect(find.byKey(const Key('heroDesktopLayout')), findsOneWidget);
      } else {
        expect(
          find.byKey(const Key('heroResponsiveLayout')),
          findsOneWidget,
        );
      }

      final headerHeight = tester.getSize(find.byType(LandingHeader)).height;
      if (size.width <= 390) {
        expect(headerHeight, lessThanOrEqualTo(168));

        final headerFinder = find.byType(LandingHeader);
        final logoRect = tester.getRect(
          find.descendant(
            of: headerFinder,
            matching: find.byKey(const Key('funAppLogo')),
          ),
        );
        final firstNavigationRect = tester.getRect(
          find.byKey(const Key('landingHeaderNavigationItem0')),
        );
        final secondNavigationRect = tester.getRect(
          find.byKey(const Key('landingHeaderNavigationItem1')),
        );
        final thirdNavigationRect = tester.getRect(
          find.byKey(const Key('landingHeaderNavigationItem2')),
        );
        final fourthNavigationRect = tester.getRect(
          find.byKey(const Key('landingHeaderNavigationItem3')),
        );
        final contactRect = tester.getRect(
          find.byKey(const Key('landingHeaderContactCta')),
        );
        final headerRect = tester.getRect(headerFinder);

        expect(logoRect.bottom, lessThanOrEqualTo(firstNavigationRect.top));
        expect(firstNavigationRect.top, secondNavigationRect.top);
        expect(thirdNavigationRect.top, fourthNavigationRect.top);
        expect(
          thirdNavigationRect.top,
          greaterThanOrEqualTo(firstNavigationRect.bottom),
        );
        expect(thirdNavigationRect.bottom, lessThanOrEqualTo(contactRect.top));
        expect(contactRect.center.dx, closeTo(headerRect.center.dx, 1));
      } else if (size.width < 1080) {
        expect(headerHeight, lessThanOrEqualTo(104));
      }

      for (final finder in [
        find.byType(LandingHeader),
        find.byType(HeroSection),
        find.byType(ProblemStatementSection),
        find.byType(ResearchStatsSection),
        find.byType(ConnectionExperienceSection),
        find.byType(MembershipSection),
        find.byType(FoundingOfferSection),
        find.byType(FoundingMemberSection),
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

  testWidgets(
    'long localized header labels fit intermediate and narrow layouts',
    (
      tester,
    ) async {
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1;

      for (final size in const [Size(320, 568), Size(768, 1024)]) {
        tester.view.physicalSize = size;
        await pumpLandingApp(tester, locale: const Locale('be'));

        expect(find.text('СЯБРЫ-ЗАСНАВАЛЬНІКІ'), findsNWidgets(2));
        expect(find.text('Звязацца з намі'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(
          size.width == 320
              ? find.byKey(const Key('landingHeaderNarrowLayout'))
              : find.byKey(const Key('landingHeaderIntermediateLayout')),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets(
    'Hero artwork stays upper-right as constrained copy moves below',
    (
      tester,
    ) async {
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      tester.view.devicePixelRatio = 1;
      const visibleArtworkWidthFraction = 1216 / 1412;
      const visibleArtworkHeightFraction = 1412 / 1434;

      for (final example in const [
        (size: Size(1440, 900), usesWideLayout: true),
        (size: Size(1360, 900), usesWideLayout: true),
        (size: Size(1359, 900), usesWideLayout: false),
        (size: Size(1200, 900), usesWideLayout: false),
        (size: Size(1024, 768), usesWideLayout: false),
        (size: Size(900, 900), usesWideLayout: false),
        (size: Size(768, 1024), usesWideLayout: false),
        (size: Size(390, 844), usesWideLayout: false),
        (size: Size(320, 568), usesWideLayout: false),
      ]) {
        tester.view.physicalSize = example.size;
        await pumpLandingApp(
          tester,
          locale: example.size.width == 320
              ? const Locale('be')
              : const Locale('en'),
        );

        expect(find.byKey(const Key('heroPeopleImage')), findsOneWidget);
        expect(
          find.byKey(
            Key(
              example.usesWideLayout
                  ? 'heroDesktopLayout'
                  : 'heroResponsiveLayout',
            ),
          ),
          findsOneWidget,
        );

        final cardRect = tester.getRect(find.byKey(const Key('heroCard')));
        final artworkRect = tester.getRect(
          find.byKey(const Key('heroPeopleImage')),
        );
        final contentRect = tester.getRect(
          find.byKey(const Key('heroContentBounds')),
        );
        final heroClip = tester.widget<ClipRRect>(
          find.byKey(const Key('heroCard')),
        );

        expect(artworkRect.top, lessThan(cardRect.top));
        expect(artworkRect.right, greaterThan(cardRect.right));
        expect(
          artworkRect.right - cardRect.right,
          greaterThanOrEqualTo(artworkRect.width * 0.135),
        );
        expect(artworkRect.center.dx, greaterThan(cardRect.center.dx));
        expect(find.byKey(const Key('landingHeroWaitlistCta')), findsNothing);
        expect(heroClip.clipBehavior, isNot(Clip.none));
        if (example.usesWideLayout) {
          if (example.size.width == 1440) {
            expect(cardRect.width, 1360);
            expect(artworkRect.size, const Size(706, 717));
            expect(contentRect.left - cardRect.left, 80);
          }
        } else {
          final visibleArtworkRight =
              artworkRect.left +
              (artworkRect.width * visibleArtworkWidthFraction);
          final visibleArtworkBottom =
              artworkRect.top +
              (artworkRect.height * visibleArtworkHeightFraction);
          final expectedArtworkWidth = switch (example.size.width) {
            1024 => 520.0,
            768 => 440.0,
            390 => 340.0,
            320 => 311.04,
            _ => null,
          };

          expect(visibleArtworkRight, greaterThan(cardRect.right + 8));
          expect(
            contentRect.top - visibleArtworkBottom,
            greaterThanOrEqualTo(15),
          );
          if (expectedArtworkWidth case final width?) {
            expect(artworkRect.width, closeTo(width, 0.01));
          }
        }
        expect(artworkRect.size.aspectRatio, closeTo(706 / 717, 0.001));
        expect(
          tester.widget<Image>(find.byKey(const Key('heroPeopleImage'))).fit,
          BoxFit.contain,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('all supported locales lay out at every responsive viewport', (
    tester,
  ) async {
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.devicePixelRatio = 1;
    const visibleArtworkHeightFraction = 1412 / 1434;

    for (final locale in AppLocalizations.supportedLocales) {
      for (final size in const [
        Size(320, 568),
        Size(390, 844),
        Size(768, 1024),
        Size(900, 800),
        Size(1024, 768),
        Size(1200, 900),
        Size(1440, 900),
      ]) {
        tester.view.physicalSize = size;
        await pumpLandingApp(tester, locale: locale);

        if (size.width < 1440) {
          final artworkRect = tester.getRect(
            find.byKey(const Key('heroPeopleImage')),
          );
          final contentRect = tester.getRect(
            find.byKey(const Key('heroContentBounds')),
          );
          final visibleArtworkBottom =
              artworkRect.top +
              (artworkRect.height * visibleArtworkHeightFraction);
          expect(
            contentRect.top - visibleArtworkBottom,
            greaterThanOrEqualTo(15),
            reason:
                '${locale.languageCode} Hero copy must clear the visible '
                'artwork at $size.',
          );
        }
        expect(
          tester.takeException(),
          isNull,
          reason: '${locale.languageCode} must not overflow at $size.',
        );
      }
    }
  });

  testWidgets('exposes one hero heading and image semantic description', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpLandingApp(tester);

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
    expect(eyebrowGlyph.excludeFromSemantics, isTrue);
    expect(find.byType(ButtonStyleButton), findsNothing);
    semantics.dispose();
  });
}

Future<void> _pumpLandingPage(
  WidgetTester tester, {
  required bool disableAnimations,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const LandingPage(),
      ),
    ),
  );
  await tester.pump();
}

ScrollController _scrollController(WidgetTester tester) => tester
    .widget<SingleChildScrollView>(
      find.byKey(const Key('landingPageScrollView')),
    )
    .controller!;

Future<void> _moveToPageEnd(WidgetTester tester) async {
  final controller = _scrollController(tester);
  controller.jumpTo(controller.position.maxScrollExtent);
  await tester.pump();
}

void _expectTargetBelowHeader(WidgetTester tester, Type targetType) {
  final headerBottom = tester.getBottomLeft(find.byType(LandingHeader)).dy;
  final targetTop = tester.getTopLeft(find.byType(targetType)).dy;
  expect(targetTop, closeTo(headerBottom, 1));
}
