import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_friends/founding_friends_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/landing_header.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/landing_mobile_menu.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/hero/hero_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_section.dart';

import '../../landing_test_helpers.dart';

void main() {
  testWidgets(
    'selects mobile and established header variants at the boundary',
    (
      tester,
    ) async {
      setTestSurface(tester, const Size(320, 568));

      for (final example in const [
        (width: 320.0, mobile: true, establishedKey: ''),
        (width: 390.0, mobile: true, establishedKey: ''),
        (width: 599.0, mobile: true, establishedKey: ''),
        (
          width: 600.0,
          mobile: false,
          establishedKey: 'landingHeaderNarrowLayout',
        ),
        (
          width: 768.0,
          mobile: false,
          establishedKey: 'landingHeaderIntermediateLayout',
        ),
        (
          width: 1440.0,
          mobile: false,
          establishedKey: 'landingHeaderHorizontalLayout',
        ),
      ]) {
        tester.view.physicalSize = Size(example.width, 900);
        await _pumpHeader(tester);

        expect(
          find.byKey(const Key('landingHeaderMobileLayout')),
          example.mobile ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('landingMobileMenuButton')),
          example.mobile ? findsOneWidget : findsNothing,
        );
        if (!example.mobile) {
          expect(find.byKey(Key(example.establishedKey)), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('matches the compact 390px header composition and exact assets', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await pumpLandingApp(tester);

    final header = find.byType(LandingHeader);
    final logo = find.descendant(
      of: header,
      matching: find.byType(FunAppLogo),
    );
    final contact = find.descendant(
      of: header,
      matching: find.byKey(const Key('landingHeaderContactCta')),
    );
    final menuButton = find.byKey(const Key('landingMobileMenuButton'));
    final menuVisual = find.byKey(const Key('mobileMenuControlVisual'));
    final icon = tester.widget<SvgPicture>(
      find.descendant(
        of: menuButton,
        matching: find.byKey(const Key('mobileMenuControlIcon')),
      ),
    );

    expect(tester.getSize(header), const Size(390, 70));
    expect(logo, findsOneWidget);
    expect(tester.getSize(logo).width, closeTo(89, 0.5));
    expect(tester.getSize(logo).height, 29);
    expect(tester.getRect(logo).left, 16);
    expect(find.text('Contact Us'), findsOneWidget);
    expect(contact, findsOneWidget);
    expect(tester.getSize(menuButton), const Size.square(44));
    expect(tester.getSize(menuVisual), const Size.square(38));
    expect(tester.getRect(header).right - tester.getRect(menuVisual).right, 16);
    expect(tester.getRect(menuVisual).left - tester.getRect(contact).right, 8);
    expect(
      (icon.bytesLoader as SvgAssetLoader).assetName,
      AppAssets.mobileMenu,
    );
    expect(find.byKey(const Key('landingHeaderNavigationItem0')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final example in const [
    (
      locale: Locale('en'),
      contact: 'Contact Us',
      open: 'Open navigation menu',
      close: 'Close navigation menu',
      firstNavigation: 'OUR BELIEF',
    ),
    (
      locale: Locale('es'),
      contact: 'Contáctanos',
      open: 'Abrir menú de navegación',
      close: 'Cerrar menú de navegación',
      firstNavigation: 'NUESTRA CREENCIA',
    ),
    (
      locale: Locale('cy'),
      contact: 'Cysylltwch â Ni',
      open: 'Agor y ddewislen lywio',
      close: "Cau'r ddewislen lywio",
      firstNavigation: 'EIN CRED',
    ),
    (
      locale: Locale('be'),
      contact: 'Звязацца з намі',
      open: 'Адкрыць меню навігацыі',
      close: 'Закрыць меню навігацыі',
      firstNavigation: 'НАША ВЕРА',
    ),
  ]) {
    testWidgets(
      '${example.locale.languageCode} mobile header and menu fit at '
      '320 and 390',
      (tester) async {
        setTestSurface(tester, const Size(320, 568));

        for (final size in const [Size(320, 568), Size(390, 844)]) {
          tester.view.physicalSize = size;
          await pumpLandingApp(tester, locale: example.locale);

          expect(find.text(example.contact), findsOneWidget);
          expect(find.bySemanticsLabel(example.open), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.tap(find.byKey(const Key('landingMobileMenuButton')));
          await tester.pump();

          final menu = find.byType(LandingMobileMenu);
          expect(menu, findsOneWidget);
          expect(
            find.descendant(of: menu, matching: find.text(example.contact)),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: menu,
              matching: find.text(example.firstNavigation),
            ),
            findsOneWidget,
          );
          expect(
            _semanticLabel(
              tester,
              find.byKey(const Key('landingMobileMenuCloseButton')),
            ),
            example.close,
          );
          expect(tester.takeException(), isNull);

          await tester.tap(
            find.byKey(const Key('landingMobileMenuCloseButton')),
          );
          await tester.pump();
        }
      },
    );
  }

  testWidgets(
    'menu uses modal focus, semantics, Escape, and repeat dismissal',
    (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      setTestSurface(tester, const Size(390, 844));
      await pumpLandingApp(tester);

      final opener = find.byKey(const Key('landingMobileMenuButton'));
      expect(_expandedState(tester, opener), isFalse);
      final openerData = tester.getSemantics(opener).getSemanticsData();
      expect(openerData.label, 'Open navigation menu');
      expect(openerData.flagsCollection.isButton, isTrue);

      await tester.tap(opener);
      await tester.pump();

      final menu = find.byKey(const Key('landingMobileMenu'));
      final close = find.byKey(const Key('landingMobileMenuCloseButton'));
      expect(menu, findsOneWidget);
      expect(tester.getSize(menu), const Size(390, 844));
      expect(_expandedState(tester, opener), isTrue);
      expect(_semanticLabel(tester, close), 'Close navigation menu');
      expect(_semanticButtonState(tester, close), isTrue);
      final closeData = tester.getSemantics(close).getSemanticsData();
      expect(closeData.label, 'Close navigation menu');
      expect(closeData.flagsCollection.isButton, isTrue);
      expect(_controlFocusNode(tester, close).hasFocus, isTrue);
      expect(_focusIsInside(menu), isTrue);
      final closeIcon = tester.widget<SvgPicture>(
        find.descendant(
          of: close,
          matching: find.byKey(const Key('mobileMenuControlIcon')),
        ),
      );
      expect(
        (closeIcon.bytesLoader as SvgAssetLoader).assetName,
        AppAssets.mobileMenuClose,
      );
      expect(closeIcon.excludeFromSemantics, isTrue);

      final topArea = find.byKey(const Key('landingMobileMenuTopArea'));
      final bottomContact = find.byKey(
        const Key('landingMobileMenuContactCta'),
      );
      expect(tester.getSize(topArea).height, 70);
      expect(tester.getRect(bottomContact).left, 16);
      expect(tester.getSize(bottomContact), const Size(358, 38));
      expect(
        tester.getRect(menu).bottom - tester.getRect(bottomContact).bottom,
        16,
      );
      for (var index = 0; index < 3; index++) {
        final item = find.byKey(Key('landingMobileMenuNavigationItem$index'));
        expect(_semanticButtonState(tester, item), isTrue);
        expect(tester.getSize(item).height, greaterThanOrEqualTo(44));
      }

      for (var index = 0; index < 8; index++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(_focusIsInside(menu), isTrue);
      }

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump();
      expect(menu, findsNothing);
      expect(_controlFocusNode(tester, opener).hasFocus, isTrue);
      expect(_expandedState(tester, opener), isFalse);

      await tester.tap(opener);
      await tester.pump();
      expect(menu, findsOneWidget);
      await tester.tap(find.byKey(const Key('landingMobileMenuCloseButton')));
      await tester.pump();
      await tester.pump();
      expect(menu, findsNothing);
      expect(_controlFocusNode(tester, opener).hasFocus, isTrue);
      semantics.dispose();
    },
  );

  testWidgets('menu keeps page scroll fixed and Contact Us opens Coming Soon', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await pumpLandingApp(tester);
    final scrollController = _scrollController(tester)..jumpTo(900);
    await tester.pump();
    final initialOffset = scrollController.offset;

    await tester.tap(find.byKey(const Key('landingMobileMenuButton')));
    await tester.pump();

    for (final key in const [
      Key('landingHeaderContactCta'),
      Key('landingMobileMenuContactCta'),
    ]) {
      expect(
        find.descendant(of: find.byKey(key), matching: find.byType(InkWell)),
        findsOneWidget,
      );
    }
    await tester.drag(
      find.byKey(const Key('landingMobileMenu')),
      const Offset(0, -250),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pump();
    expect(scrollController.offset, initialOffset);

    await tester.tap(find.byKey(const Key('landingMobileMenuContactCta')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('interestedUserComingSoonDialogContent')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('landingDialogCloseButton')));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('landingPageScrollView')),
      const Offset(0, -250),
    );
    await tester.pump();
    expect(scrollController.offset, greaterThan(initialOffset));
  });

  testWidgets('menu destinations support Enter and Space activation', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    var activationCount = 0;
    await _pumpHeader(
      tester,
      onOurBeliefSelected: () => activationCount++,
    );

    for (final key in const [
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.space,
    ]) {
      await tester.tap(find.byKey(const Key('landingMobileMenuButton')));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        _focusIsInside(
          find.byKey(const Key('landingMobileMenuNavigationItem0')),
        ),
        isTrue,
      );
      await tester.sendKeyEvent(key);
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('landingMobileMenu')), findsNothing);
    }

    expect(activationCount, 2);
  });

  testWidgets('system back dismisses the menu and restores opener focus', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpHeader(tester);
    final opener = find.byKey(const Key('landingMobileMenuButton'));

    await tester.tap(opener);
    await tester.pump();
    expect(find.byKey(const Key('landingMobileMenu')), findsOneWidget);
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('landingMobileMenu')), findsNothing);
    expect(_controlFocusNode(tester, opener).hasFocus, isTrue);
  });

  testWidgets('resizing across 600 dismisses without stale focus restoration', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    await _pumpHeader(tester, scrollController: scrollController);
    scrollController.jumpTo(300);
    await tester.pump();
    final initialOffset = scrollController.offset;
    await tester.tap(find.byKey(const Key('landingMobileMenuButton')));
    await tester.pump();

    tester.view.physicalSize = const Size(599, 844);
    await tester.pump();
    expect(find.byKey(const Key('landingMobileMenu')), findsOneWidget);

    tester.view.physicalSize = const Size(600, 844);
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('landingMobileMenu')), findsNothing);
    expect(find.byKey(const Key('landingHeaderNarrowLayout')), findsOneWidget);
    expect(find.byKey(const Key('landingMobileMenuButton')), findsNothing);
    expect(scrollController.offset, initialOffset);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pump();
    expect(find.byKey(const Key('landingMobileMenu')), findsNothing);
    expect(find.byKey(const Key('landingMobileMenuButton')), findsOneWidget);
  });

  testWidgets('mobile destinations close the menu before anchor navigation', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    const targets = <Type>[
      HeroSection,
      FoundingFriendsSection,
      VenueSection,
    ];

    for (var index = 0; index < targets.length; index++) {
      await pumpLandingApp(tester);
      final controller = _scrollController(tester);
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      await tester.tap(find.byKey(const Key('landingMobileMenuButton')));
      await tester.pump();
      await tester.tap(
        find.byKey(Key('landingMobileMenuNavigationItem$index')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('landingMobileMenu')), findsNothing);
      expect(controller.position.isScrollingNotifier.value, isFalse);
      _expectTargetBelowHeader(tester, targets[index]);
    }
  });

  testWidgets('reduced motion keeps menu and selected anchor immediate', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpLandingPage(tester, disableAnimations: true);
    final controller = _scrollController(tester);
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    await tester.tap(find.byKey(const Key('landingMobileMenuButton')));
    await tester.pump();
    final menuContext = tester.element(
      find.byKey(const Key('landingMobileMenu')),
    );
    expect(ModalRoute.of(menuContext)?.transitionDuration, Duration.zero);
    await tester.tap(
      find.byKey(const Key('landingMobileMenuNavigationItem1')),
    );
    await tester.pump();

    expect(find.byKey(const Key('landingMobileMenu')), findsNothing);
    expect(controller.position.isScrollingNotifier.value, isFalse);
    _expectTargetBelowHeader(tester, FoundingFriendsSection);
  });
}

bool? _expandedState(WidgetTester tester, Finder control) => tester
    .widget<Semantics>(
      find.descendant(of: control, matching: find.byType(Semantics)).first,
    )
    .properties
    .expanded;

String? _semanticLabel(WidgetTester tester, Finder control) => tester
    .widget<Semantics>(
      find.descendant(of: control, matching: find.byType(Semantics)).first,
    )
    .properties
    .label;

bool? _semanticButtonState(WidgetTester tester, Finder control) => tester
    .widget<Semantics>(
      find.descendant(of: control, matching: find.byType(Semantics)).first,
    )
    .properties
    .button;

FocusNode _controlFocusNode(WidgetTester tester, Finder control) => tester
    .widget<InkWell>(
      find.descendant(of: control, matching: find.byType(InkWell)),
    )
    .focusNode!;

bool _focusIsInside(Finder ancestor) {
  final context = FocusManager.instance.primaryFocus?.context;
  return context != null &&
      find
          .ancestor(
            of: find.byElementPredicate((element) => element == context),
            matching: ancestor,
          )
          .evaluate()
          .isNotEmpty;
}

ScrollController _scrollController(WidgetTester tester) => tester
    .widget<SingleChildScrollView>(
      find.byKey(const Key('landingPageScrollView')),
    )
    .controller!;

void _expectTargetBelowHeader(WidgetTester tester, Type targetType) {
  final headerBottom = tester.getBottomLeft(find.byType(LandingHeader)).dy;
  final targetTop = tester.getTopLeft(find.byType(targetType)).dy;
  expect(targetTop, closeTo(headerBottom, 1));
}

Future<void> _pumpLandingPage(
  WidgetTester tester, {
  required bool disableAnimations,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData.fromView(
          tester.view,
        ).copyWith(disableAnimations: disableAnimations),
        child: const LandingPage(),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _pumpHeader(
  WidgetTester tester, {
  ScrollController? scrollController,
  VoidCallback? onOurBeliefSelected,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(
          children: [
            LandingHeader(
              onOurBeliefSelected: onOurBeliefSelected ?? () {},
              onFoundingFriendsSelected: () {},
              onVenuesSelected: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: const SizedBox(height: 1600),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
}
