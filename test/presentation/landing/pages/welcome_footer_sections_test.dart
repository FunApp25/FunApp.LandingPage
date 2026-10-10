import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_email.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/mobile_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/welcome/welcome_statement_section.dart';
import 'package:fun_app_landing_page/presentation/privacy/pages/privacy_notice_page.dart';

import '../landing_test_helpers.dart';

void main() {
  testWidgets('renders authoritative English welcome and footer copy', (
    tester,
  ) async {
    await pumpLandingApp(tester);

    expect(
      find.bySemanticsLabel('Welcome to Fun App'),
      findsOneWidget,
    );
    final statement = tester.widget<Text>(
      find.byKey(const Key('welcomeStatementText')),
    );
    expect(
      statement.textSpan?.toPlainText(),
      'Fun App believes friendship, group and dating platforms can be SO much '
      'better. Welcome to a friendlier future.',
    );
    for (final label in [
      'OUR BELIEF',
      'MEMBERSHIP',
      'FOUNDING FRIENDS',
      'FOR VENUES',
    ]) {
      expect(find.text(label), findsNWidgets(2));
    }
    expect(find.text(LandingFooter.contactEmail), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  for (final example in const [
    (
      locale: Locale('es'),
      eyebrow: 'Te damos la bienvenida a Fun App',
      statement:
          'Fun App cree que las plataformas de amistad, grupos y citas pueden '
          'ser MUCHO mejores. Te damos la bienvenida a un futuro más amable.',
      firstNavigation: 'NUESTRA CREENCIA',
    ),
    (
      locale: Locale('cy'),
      eyebrow: 'Croeso i Fun App',
      statement:
          'Mae Fun App yn credu y gall llwyfannau cyfeillgarwch, grwpiau a '
          'dyddio fod GYMAINT yn well. Croeso i ddyfodol mwy cyfeillgar.',
      firstNavigation: 'EIN CRED',
    ),
    (
      locale: Locale('be'),
      eyebrow: 'Вітаем у Fun App',
      statement:
          'Fun App верыць, што платформы для сяброўства, групавых зносін і '
          'знаёмстваў могуць быць НАШМАТ лепшымі. Вітаем у больш прыязнай '
          'будучыні.',
      firstNavigation: 'НАША ВЕРА',
    ),
  ]) {
    testWidgets('renders responsive ${example.locale.languageCode} content', (
      tester,
    ) async {
      setTestSurface(tester, const Size(320, 568));
      await pumpLandingApp(tester, locale: example.locale);

      expect(find.bySemanticsLabel(example.eyebrow), findsOneWidget);
      expect(find.bySemanticsLabel(example.statement), findsOneWidget);
      expect(find.text(example.firstNavigation), findsOneWidget);
      expect(find.text(LandingFooter.contactEmail), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses exact committed Figma assets and the shared V2 logo', (
    tester,
  ) async {
    await pumpLandingApp(tester);

    expectSvgAsset(
      tester,
      const Key('welcomeEyebrowGlyph'),
      AppAssets.welcomeGlyph,
    );
    expectSvgAsset(
      tester,
      const Key('footerEnvelope'),
      AppAssets.footerEnvelope,
    );
    expectSvgAsset(
      tester,
      const Key('footerLogoAsset'),
      AppAssets.funAppLogoV2,
    );
    final footerLogo = tester.widget<FunAppLogo>(
      find.descendant(
        of: find.byType(LandingFooter),
        matching: find.byType(FunAppLogo),
      ),
    );
    expect(footerLogo.variant, FunAppLogoVariant.landingV2);
    expect(footerLogo.width, AppSizes.footerWordmarkWidth);
    expect(footerLogo.height, AppSizes.footerWordmarkHeight);

    for (final asset in [
      AppAssets.welcomeGlyph,
      AppAssets.footerEnvelope,
      AppAssets.funAppLogoV2,
    ]) {
      expect(asset, startsWith('assets/'));
      expect(asset, isNot(contains('figma.com')));
    }

    final envelopeSvg = await rootBundle.loadString(AppAssets.footerEnvelope);
    expect(
      envelopeSvg,
      contains('width="16" height="16" viewBox="0 0 16 16"'),
    );
    expect(envelopeSvg, contains('M14.0264 2.90039'));
    expect(envelopeSvg, isNot(contains('figma.com')));
  });

  testWidgets('footer email launches the approved mailto URI from keyboard', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final launched = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FooterEmail(
            email: LandingFooter.contactEmail,
            onOpen: launched.add,
          ),
        ),
      ),
    );

    final link = find.byKey(const Key('footerEmailSemantics'));
    final data = tester.getSemantics(link).getSemanticsData();
    expect(data.label, LandingFooter.contactEmail);
    expect(data.flagsCollection.isLink, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    Focus.of(
      tester.element(find.byKey(const Key('footerEmailText'))),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(launched, [Uri.parse('mailto:info@funapp.world')]);
    expect(
      FooterEmail.mailtoUriFor(LandingFooter.contactEmail).toString(),
      'mailto:info@funapp.world',
    );
    semantics.dispose();
  });

  testWidgets('header and footer logos return to the landing top by keyboard', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpLandingApp(tester);

    await tester.ensureVisible(find.byKey(const Key('footerLogoLink')));
    await tester.pumpAndSettle();
    Focus.of(
      tester.element(find.byKey(const Key('footerLogoAsset'))),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    final headerBottom = tester
        .getRect(find.byKey(const Key('landingHeaderBoundary')))
        .bottom;
    expect(
      tester.getRect(find.byKey(const Key('heroCard'))).top,
      closeTo(headerBottom, 0.01),
    );
    for (final key in const [Key('headerLogoLink'), Key('footerLogoLink')]) {
      final data = tester.getSemantics(find.byKey(key)).getSemanticsData();
      expect(data.label, 'Fun App');
      expect(data.flagsCollection.isLink, isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
    }
    semantics.dispose();
  });

  testWidgets('adapts statement and footer wrapping by constraints', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(320, 568), statementSize: 36.0),
      (size: Size(390, 844), statementSize: 36.0),
      (size: Size(768, 1024), statementSize: 42.0),
      (size: Size(1024, 768), statementSize: 42.0),
      (size: Size(1440, 900), statementSize: 50.0),
    ]) {
      setTestSurface(tester, example.size);
      await pumpLandingApp(tester);

      final statement = tester.widget<Text>(
        find.byKey(const Key('welcomeStatementText')),
      );
      expect(statement.textSpan?.style?.fontSize, example.statementSize);
      expect(
        tester.getSize(find.byType(WelcomeStatementSection)).width,
        lessThanOrEqualTo(example.size.width),
      );
      expect(
        tester.getSize(find.byType(LandingFooter)).width,
        lessThanOrEqualTo(example.size.width),
      );
      final itemOffsets = [
        for (var index = 0; index < 4; index++)
          tester.getTopLeft(find.byKey(Key('footerNavigationItem$index'))).dy,
      ];
      expect(itemOffsets, hasLength(4));
      expect(
        tester.takeException(),
        isNull,
        reason: 'Footer must fit at ${example.size}.',
      );
    }
  });

  testWidgets('aligns Welcome to the mobile Figma rhythm', (tester) async {
    setTestSurface(tester, const Size(390, 844));
    await pumpLandingApp(tester);

    final sectionRect = tester.getRect(
      find.byType(WelcomeStatementSection),
    );
    final contentRect = tester.getRect(
      find.byKey(const Key('welcomeStatementContent')),
    );
    final statement = tester.widget<Text>(
      find.byKey(const Key('welcomeStatementText')),
    );

    expect(contentRect.left - sectionRect.left, 16);
    expect(contentRect.right - sectionRect.right, -16);
    expect(contentRect.top - sectionRect.top, 80);
    expect(statement.textSpan?.style?.fontSize, 36);
    expect(statement.textSpan?.style?.height, closeTo(46 / 36, 0.0001));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the established Welcome treatment at 600px', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(599, 844), statementSize: 36.0),
      (size: Size(600, 844), statementSize: 42.0),
    ]) {
      setTestSurface(tester, example.size);
      await pumpLandingSection(
        tester,
        section: const WelcomeStatementSection(),
      );

      expect(
        tester
            .widget<Text>(find.byKey(const Key('welcomeStatementText')))
            .textSpan
            ?.style
            ?.fontSize,
        example.statementSize,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('uses the Figma mobile footer only below 600px', (tester) async {
    for (final example in const [
      (size: Size(320, 568), usesMobileFooter: true),
      (size: Size(390, 844), usesMobileFooter: true),
      (size: Size(599, 844), usesMobileFooter: true),
      (size: Size(600, 844), usesMobileFooter: false),
      (size: Size(768, 1024), usesMobileFooter: false),
      (size: Size(1440, 900), usesMobileFooter: false),
    ]) {
      setTestSurface(tester, example.size);
      await pumpLandingApp(tester);

      expect(
        find.byType(MobileFooter),
        example.usesMobileFooter ? findsOneWidget : findsNothing,
      );
      expect(
        find.byKey(const Key('footerMobileDivider')),
        example.usesMobileFooter ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('aligns the unblocked mobile footer composition to Figma', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await pumpLandingApp(tester);

    final footerRect = tester.getRect(find.byType(LandingFooter));
    final contentRect = tester.getRect(
      find.byKey(const Key('footerMobileContent')),
    );
    final logoRect = tester.getRect(find.byKey(const Key('footerLogoAsset')));
    final navigationRect = tester.getRect(
      find.byKey(const Key('footerNavigationWrap')),
    );
    final dividerRect = tester.getRect(
      find.byKey(const Key('footerMobileDivider')),
    );
    final emailRect = tester.getRect(
      find.byKey(const Key('footerEmailSemantics')),
    );

    expect(contentRect.left - footerRect.left, 16);
    expect(contentRect.right - footerRect.right, -16);
    expect(contentRect.top - footerRect.top, 80);
    expect(logoRect.width, closeTo(123, 0.2));
    expect(logoRect.height, 40);
    expect(logoRect.center.dx, closeTo(footerRect.center.dx, 0.01));
    expect(navigationRect.top - logoRect.bottom, 32);
    expect(dividerRect.width, 358);
    expect(dividerRect.top - navigationRect.bottom, 60);
    expect(emailRect.top - dividerRect.bottom, 60);
    expect(emailRect.center.dx, closeTo(footerRect.center.dx, 0.01));
    expect(find.text(LandingFooter.contactEmail), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('aligns the 1440px desktop footer rows to Figma', (tester) async {
    setTestSurface(tester, const Size(1440, 900));
    await pumpLandingApp(tester);

    final footerRect = tester.getRect(find.byType(LandingFooter));
    final contentRect = tester.getRect(
      find.byKey(const Key('footerDesktopContent')),
    );
    final logoRect = tester.getRect(find.byKey(const Key('footerLogoAsset')));
    final navigationRect = tester.getRect(
      find.byKey(const Key('footerNavigationWrap')),
    );
    final dividerRect = tester.getRect(
      find.byKey(const Key('footerDesktopDivider')),
    );
    final emailRect = tester.getRect(
      find.byKey(const Key('footerEmailSemantics')),
    );
    final legalRect = tester.getRect(
      find.byKey(const Key('footerLegalItems')),
    );

    expect(footerRect.height, greaterThanOrEqualTo(392));
    expect(contentRect.left - footerRect.left, 40);
    expect(contentRect.right - footerRect.right, -40);
    expect(contentRect.top - footerRect.top, 88);
    expect(logoRect.left, contentRect.left);
    expect(dividerRect.width, 1360);
    expect(dividerRect.top - navigationRect.bottom, 72);
    expect(legalRect.top - dividerRect.bottom, 71);
    expect(legalRect.center.dy, closeTo(emailRect.center.dy, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'shows five functional legal controls in the approved order',
    (
      tester,
    ) async {
      setTestSurface(tester, const Size(390, 844));
      await pumpLandingApp(tester);

      final footer = find.byType(LandingFooter);
      for (final label in const [
        'Privacy Policy',
        'Terms of Use',
        'Refund & Cancellation Policy',
        'Cookie Policy',
        'Cookie Banner',
      ]) {
        expect(
          find.descendant(of: footer, matching: find.text(label)),
          findsOneWidget,
        );
      }
      for (final key in const [
        Key('footerPrivacyNoticeLink'),
        Key('footerTermsLink'),
        Key('footerRefundsLink'),
        Key('footerCookiePolicyLink'),
        Key('footerCookieBannerLink'),
      ]) {
        final data = tester.getSemantics(find.byKey(key)).getSemanticsData();
        expect(data.flagsCollection.isLink, isTrue);
        expect(data.hasAction(SemanticsAction.tap), isTrue);
      }
    },
  );

  testWidgets(
    'footer Privacy Notice requests a new tab without app navigation',
    (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final launched = <Uri>[];
      await pumpLandingApp(tester, onPrivacyNoticeLaunch: launched.add);

      final privacyLink = find.byKey(const Key('footerPrivacyNoticeLink'));
      await tester.ensureVisible(privacyLink);
      await tester.pumpAndSettle();
      final interactiveLink = tester.widget<InkWell>(
        find.descendant(of: privacyLink, matching: find.byType(InkWell)),
      );
      interactiveLink.onTap!();
      await tester.pumpAndSettle();

      expect(launched, hasLength(1));
      expect(launched.single.fragment, '/privacy');
      expect(launched.single.path, '/');
      expect(find.byType(PrivacyNoticePage), findsNothing);
      expect(find.byType(LandingFooter), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('keeps the mobile footer safe across supported locales', (
    tester,
  ) async {
    for (final locale in const [
      Locale('en'),
      Locale('es'),
      Locale('cy'),
      Locale('be'),
    ]) {
      for (final size in const [Size(320, 568), Size(390, 844)]) {
        setTestSurface(tester, size);
        await pumpLandingApp(tester, locale: locale);

        expect(find.byType(MobileFooter), findsOneWidget);
        expect(find.text(LandingFooter.contactEmail), findsOneWidget);
        for (var index = 0; index < 4; index++) {
          expect(
            find.byKey(Key('footerNavigationItem$index')),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('exposes navigation controls and actionable logo and email', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    setTestSurface(tester, const Size(390, 844));
    await pumpLandingApp(tester);

    final statement = tester
        .getSemantics(find.byKey(const Key('welcomeStatementSemantics')))
        .getSemanticsData();
    expect(
      statement.label,
      'Fun App believes friendship, group and dating platforms can be SO much '
      'better. Welcome to a friendlier future.',
    );
    expect(statement.flagsCollection.isHeader, isTrue);
    expect(
      tester
          .widget<SvgPicture>(
            find.byKey(const Key('welcomeEyebrowGlyph')),
          )
          .excludeFromSemantics,
      isTrue,
    );
    final logo = tester
        .getSemantics(find.byKey(const Key('footerLogoLink')))
        .getSemanticsData();
    expect(logo.label, 'Fun App');
    expect(logo.flagsCollection.isLink, isTrue);
    expect(logo.hasAction(SemanticsAction.tap), isTrue);
    final email = tester
        .getSemantics(find.byKey(const Key('footerEmailSemantics')))
        .getSemanticsData();
    expect(email.label, LandingFooter.contactEmail);
    expect(email.flagsCollection.isLink, isTrue);
    expect(email.flagsCollection.isButton, isFalse);
    expect(email.hasAction(SemanticsAction.tap), isTrue);
    expect(
      tester
          .widget<SvgPicture>(find.byKey(const Key('footerEnvelope')))
          .excludeFromSemantics,
      isTrue,
    );
    for (var index = 0; index < 4; index++) {
      final navigation = tester
          .getSemantics(find.byKey(Key('footerNavigationItem$index')))
          .getSemanticsData();
      expect(navigation.flagsCollection.isLink, isFalse);
      expect(navigation.flagsCollection.isButton, isTrue);
    }
    final privacyLink = tester
        .getSemantics(find.byKey(const Key('footerPrivacyNoticeLink')))
        .getSemanticsData();
    expect(privacyLink.label, 'Privacy Policy');
    expect(privacyLink.flagsCollection.isLink, isTrue);
    expect(privacyLink.flagsCollection.isButton, isFalse);
    expect(privacyLink.hasAction(SemanticsAction.tap), isTrue);
    expect(
      find.descendant(
        of: find.byType(LandingFooter),
        matching: find.byType(ButtonStyleButton),
      ),
      findsNothing,
    );
    semantics.dispose();
  });
}
