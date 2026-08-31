import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/founding_offer_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/membership_card.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/membership_section.dart';

const _membershipBody =
    'Connections for everyone. Choose the membership that works for you and '
    'enjoy a friendlier future with Fun App.';
const _freeDescription =
    'Free membership will deliver a fully working app including some super '
    'attractive benefits.';
const _hereNowDescription =
    '‘Here & Now’ membership will include EVERYTHING Fun App is busy '
    'developing.';
const _foundingOffer =
    'Become A Fun App Founding Friend... for free. Enjoy latest news plus '
    '‘Here & Now’ membership on us.';

void main() {
  testWidgets('renders authoritative English membership and offer copy', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('Membership'), findsOneWidget);
    expect(find.text(_membershipBody), findsOneWidget);
    expect(find.text('Free Membership'), findsOneWidget);
    expect(find.text('Here & Now Membership'), findsOneWidget);
    expect(find.text('£0'), findsOneWidget);
    expect(find.text('£11'), findsOneWidget);
    expect(find.text('/ month'), findsNWidgets(2));
    expect(find.text(_freeDescription), findsOneWidget);
    expect(find.text(_hereNowDescription), findsOneWidget);
    expect(find.text('However, see offer below...'), findsNWidgets(2));
    expect(find.text('BECOME A FOUNDING FRIEND'), findsNWidgets(2));
    expect(find.text('LIMITED TIME OFFER'), findsOneWidget);

    final offerStatement = tester.widget<Text>(
      find.byKey(const Key('foundingOfferStatementText')),
    );
    expect(offerStatement.textSpan?.toPlainText(), _foundingOffer);
  });

  for (final example in const [
    (
      locale: Locale('es'),
      heading: 'Membresía',
      freeTier: 'Membresía gratuita',
      billingPeriod: '/ mes',
      offerEyebrow: 'OFERTA POR TIEMPO LIMITADO',
      offer:
          'Hazte Fun App Founding Friend... gratis. Disfruta de las últimas '
          'noticias además de la membresía ‘Here & Now’ por nuestra cuenta.',
    ),
    (
      locale: Locale('cy'),
      heading: 'Aelodaeth',
      freeTier: 'Aelodaeth am Ddim',
      billingPeriod: '/ mis',
      offerEyebrow: 'CYNNIG AM GYFNOD CYFYNGEDIG',
      offer:
          'Dewch yn Fun App Founding Friend... am ddim. Mwynhewch y newyddion '
          'diweddaraf ynghyd ag aelodaeth ‘Here & Now’ ar ein cyfrif ni.',
    ),
    (
      locale: Locale('be'),
      heading: 'Членства',
      freeTier: 'Бясплатнае членства',
      billingPeriod: '/ месяц',
      offerEyebrow: 'ПРАПАНОВА НА АБМЕЖАВАНЫ ЧАС',
      offer:
          'Станьце Fun App Founding Friend... бясплатна. Атрымлівайце апошнія '
          'навіны плюс членства «Here & Now» за наш кошт.',
    ),
  ]) {
    testWidgets('renders responsive ${example.locale.languageCode} content', (
      tester,
    ) async {
      _setTestSurface(tester, const Size(320, 568));
      await _pumpApp(tester, locale: example.locale);

      expect(find.text(example.heading), findsOneWidget);
      expect(find.text(example.freeTier), findsOneWidget);
      expect(find.text(example.billingPeriod), findsNWidgets(2));
      expect(find.text(example.offerEyebrow), findsOneWidget);
      expect(find.bySemanticsLabel(example.offer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses exact committed membership Figma vectors', (tester) async {
    await _pumpApp(tester);

    for (final id in ['free', 'hereNow']) {
      _expectSvgAsset(
        tester,
        Key('membershipCheck-$id'),
        AppAssets.membershipCheck,
      );
      _expectSvgAsset(
        tester,
        Key('membershipOfferArrow-$id'),
        AppAssets.membershipArrowUpRight,
      );
    }
    _expectSvgAsset(
      tester,
      const Key('foundingOfferGlyph'),
      AppAssets.foundingOfferGlyph,
    );

    for (final asset in [
      AppAssets.membershipCheck,
      AppAssets.membershipArrowUpRight,
      AppAssets.foundingOfferGlyph,
    ]) {
      expect(asset, startsWith('assets/'));
      expect(asset, isNot(contains('figma.com')));
    }
  });

  testWidgets('reflows membership cards by available constraints', (
    tester,
  ) async {
    for (final example in const [
      (
        size: Size(320, 568),
        columns: 1,
        headingSize: 34.0,
        statementSize: 34.0,
        usesDesktopComposition: false,
      ),
      (
        size: Size(390, 844),
        columns: 1,
        headingSize: 34.0,
        statementSize: 34.0,
        usesDesktopComposition: false,
      ),
      (
        size: Size(768, 1024),
        columns: 2,
        headingSize: 40.0,
        statementSize: 42.0,
        usesDesktopComposition: false,
      ),
      (
        size: Size(1024, 768),
        columns: 2,
        headingSize: 40.0,
        statementSize: 42.0,
        usesDesktopComposition: false,
      ),
      (
        size: Size(1440, 900),
        columns: 2,
        headingSize: 44.0,
        statementSize: 50.0,
        usesDesktopComposition: true,
      ),
    ]) {
      _setTestSurface(tester, example.size);
      await _pumpApp(tester);

      expect(find.byType(MembershipCard), findsNWidgets(2));
      expect(
        find.byKey(Key('membershipCardsColumns${example.columns}')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('membershipHeadingText')))
            .style
            ?.fontSize,
        example.headingSize,
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('foundingOfferStatementText')))
            .textSpan
            ?.style
            ?.fontSize,
        example.statementSize,
      );
      final freeCardBounds = tester.widget<ConstrainedBox>(
        find.byKey(const Key('membershipCardBounds-free')),
      );
      if (example.columns == 1) {
        expect(freeCardBounds.constraints.minHeight, 0);
      } else {
        expect(freeCardBounds.constraints.minHeight, 464);
      }
      expect(
        find.byKey(
          Key(
            example.usesDesktopComposition
                ? 'membershipDesktopLayout'
                : 'membershipStackedIntroLayout',
          ),
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(MembershipSection)).width,
        lessThanOrEqualTo(example.size.width),
      );
      expect(
        tester.getSize(find.byType(FoundingOfferSection)).width,
        lessThanOrEqualTo(example.size.width),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('exposes tier, price, and offer semantics without actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpApp(tester);

    _expectHeaderSemantics(
      tester,
      const Key('membershipHeadingSemantics'),
      'Membership',
    );
    _expectHeaderSemantics(
      tester,
      const Key('membershipTierSemantics-free'),
      'Free Membership',
    );
    _expectHeaderSemantics(
      tester,
      const Key('membershipTierSemantics-hereNow'),
      'Here & Now Membership',
    );
    expect(
      tester
          .getSemantics(find.byKey(const Key('membershipPriceSemantics-free')))
          .getSemanticsData()
          .label,
      '£0 per month',
    );
    expect(
      tester
          .getSemantics(
            find.byKey(const Key('membershipPriceSemantics-hereNow')),
          )
          .getSemanticsData()
          .label,
      '£11 per month',
    );
    _expectHeaderSemantics(
      tester,
      const Key('foundingOfferHeadingSemantics'),
      _foundingOffer,
    );

    final freeCardText = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(MembershipCard).first,
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data)
        .whereType<String>()
        .toList();
    expect(
      freeCardText,
      orderedEquals([
        'Free Membership',
        '£0',
        '/ month',
        _freeDescription,
        'However, see offer below...',
        'BECOME A FOUNDING FRIEND',
      ]),
    );

    for (final key in const [
      Key('membershipCheck-free'),
      Key('membershipCheck-hereNow'),
      Key('membershipOfferArrow-free'),
      Key('membershipOfferArrow-hereNow'),
      Key('foundingOfferGlyph'),
    ]) {
      expect(
        tester.widget<SvgPicture>(find.byKey(key)).excludeFromSemantics,
        isTrue,
      );
    }
    expect(
      find.descendant(
        of: find.byType(MembershipSection),
        matching: find.byType(ButtonStyleButton),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(MembershipSection),
        matching: find.byType(InkWell),
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

void _expectHeaderSemantics(
  WidgetTester tester,
  Key key,
  String expectedLabel,
) {
  final data = tester.getSemantics(find.byKey(key)).getSemanticsData();
  expect(data.label, expectedLabel);
  expect(data.flagsCollection.isHeader, isTrue);
}
