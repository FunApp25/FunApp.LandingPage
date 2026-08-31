import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/welcome_statement_section.dart';

void main() {
  testWidgets('renders authoritative English welcome and footer copy', (
    tester,
  ) async {
    await _pumpApp(tester);

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
      _setTestSurface(tester, const Size(320, 568));
      await _pumpApp(tester, locale: example.locale);

      expect(find.bySemanticsLabel(example.eyebrow), findsOneWidget);
      expect(find.bySemanticsLabel(example.statement), findsOneWidget);
      expect(find.text(example.firstNavigation), findsNWidgets(2));
      expect(find.text(LandingFooter.contactEmail), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses exact committed Figma assets and the shared V2 logo', (
    tester,
  ) async {
    await _pumpApp(tester);

    _expectSvgAsset(
      tester,
      const Key('welcomeEyebrowGlyph'),
      AppAssets.welcomeGlyph,
    );
    _expectSvgAsset(
      tester,
      const Key('footerEnvelope'),
      AppAssets.footerEnvelope,
    );
    _expectSvgAsset(
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

  testWidgets('adapts statement and footer wrapping by constraints', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(320, 568), statementSize: 34.0, wrapsNavigation: true),
      (size: Size(390, 844), statementSize: 34.0, wrapsNavigation: true),
      (size: Size(768, 1024), statementSize: 42.0, wrapsNavigation: true),
      (size: Size(1024, 768), statementSize: 42.0, wrapsNavigation: false),
      (size: Size(1440, 900), statementSize: 50.0, wrapsNavigation: false),
    ]) {
      _setTestSurface(tester, example.size);
      await _pumpApp(tester);

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
      if (example.wrapsNavigation) {
        expect(itemOffsets.toSet(), hasLength(greaterThan(1)));
      } else {
        expect(itemOffsets.toSet(), hasLength(1));
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('exposes navigation controls and keeps email static', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpApp(tester);

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
        .getSemantics(find.byKey(const Key('footerLogoAsset')))
        .getSemanticsData();
    expect(logo.label, 'Fun App');
    expect(logo.flagsCollection.isImage, isTrue);
    final email = tester
        .getSemantics(find.byKey(const Key('footerEmailSemantics')))
        .getSemanticsData();
    expect(email.label, LandingFooter.contactEmail);
    expect(email.flagsCollection.isLink, isFalse);
    expect(email.flagsCollection.isButton, isFalse);
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
