import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_offer/founding_offer_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_section.dart';

import '../landing_test_helpers.dart';

const _membershipBody =
    'Connections for everyone. Choose the membership that works for you and '
    'enjoy a friendlier future with Fun App.';
const _freeDescription =
    'For testing early builds, sharing honest thoughts, and watching the app '
    'take shape';
const _hereNowDescription =
    'Full access from day one. You get every feature now and lock in permanent '
    'Founding status.';
const _lifetimeDescription =
    'Pay once, keep full access forever, and never deal with a monthly renewal '
    'again';
const _foundingOffer =
    'Become A Fun App Founding Friend... for free. Enjoy ‘Here & Now’ '
    'membership on us.';

void main() {
  testWidgets('renders the three authoritative English pricing cards', (
    tester,
  ) async {
    await pumpLandingApp(tester);

    expect(find.text('Membership'), findsOneWidget);
    expect(find.text(_membershipBody), findsOneWidget);
    expect(find.byType(MembershipCard), findsNWidgets(3));
    expect(
      [
        for (final id in ['free', 'hereNow', 'lifetime'])
          tester.widget<Text>(find.byKey(Key('membershipTierName-$id'))).data,
      ],
      orderedEquals([
        'FREE MEMBERSHIP',
        'HERE & NOW MEMBERSHIP',
        'LIFETIME MEMBERSHIP',
      ]),
    );
    expect(find.text('£0'), findsOneWidget);
    expect(find.text('£11'), findsOneWidget);
    expect(find.text('£249'), findsOneWidget);
    expect(find.text('/ month'), findsNWidgets(2));
    expect(find.text('/ one time'), findsOneWidget);
    expect(find.text(_freeDescription), findsOneWidget);
    expect(find.text(_hereNowDescription), findsOneWidget);
    expect(find.text(_lifetimeDescription), findsOneWidget);

    for (final copy in [
      'First look at beta releases',
      'Everything in Free Membership',
      'Permanent Founding Member badge on your profile',
      'All Here & Now perks for life',
      'Only available during the pre-launch phase',
      'Join the Community',
      'Start Here & Now',
      'Get Lifetime Membership',
      '*Cancel anytime. Your Founding badge stays forever.',
      '*Available only before the public launch',
      'LIMITED FOUNDING OFFER',
    ]) {
      expect(find.text(copy), findsAtLeastNWidgets(1));
    }
  });

  testWidgets('renders the current white limited-time offer', (tester) async {
    await pumpLandingApp(tester);

    expect(
      tester
          .widget<ColoredBox>(
            find.byKey(const Key('foundingOfferBackground')),
          )
          .color,
      AppColors.lightForeground,
    );
    expect(find.text('LIMITED TIME OFFER'), findsOneWidget);
    final statement = tester.widget<Text>(
      find.byKey(const Key('foundingOfferStatementText')),
    );
    expect(statement.textSpan?.toPlainText(), _foundingOffer);
  });

  for (final example in const [
    (
      locale: Locale('es'),
      size: Size(390, 844),
      heading: 'Membresía',
      freeTier: 'MEMBRESÍA GRATUITA',
      lifetimeCta: 'Obtén la membresía de por vida',
      offer:
          'Hazte Founding Friend de Fun App... gratis. Disfruta de la '
          'membresía ‘Here & Now’ por nuestra cuenta.',
    ),
    (
      locale: Locale('cy'),
      size: Size(900, 800),
      heading: 'Aelodaeth',
      freeTier: 'AELODAETH AM DDIM',
      lifetimeCta: 'Cael Aelodaeth Oes',
      offer:
          'Dewch yn Founding Friend i Fun App... am ddim. Mwynhewch aelodaeth '
          '‘Here & Now’ ar ein cyfrif ni.',
    ),
    (
      locale: Locale('be'),
      size: Size(1440, 900),
      heading: 'Членства',
      freeTier: 'БЯСПЛАТНАЕ ЧЛЕНСТВА',
      lifetimeCta: 'Атрымаць пажыццёвае членства',
      offer:
          'Станьце Founding Friend Fun App... бясплатна. Атрымайце членства '
          '«Here & Now» за наш кошт.',
    ),
  ]) {
    testWidgets('renders responsive ${example.locale.languageCode} content', (
      tester,
    ) async {
      setTestSurface(tester, example.size);
      await pumpLandingApp(tester, locale: example.locale);

      expect(find.text(example.heading), findsOneWidget);
      expect(find.text(example.freeTier), findsOneWidget);
      expect(find.text(example.lifetimeCta), findsOneWidget);
      expect(find.bySemanticsLabel(example.offer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses exact local membership Figma vectors', (tester) async {
    await pumpLandingApp(tester);

    for (final entry in const [
      (key: 'free', asset: AppAssets.membershipFreeEyebrow),
      (key: 'hereNow', asset: AppAssets.membershipHereNowEyebrow),
      (key: 'lifetime', asset: AppAssets.membershipLifetimeEyebrow),
    ]) {
      expectSvgAsset(
        tester,
        Key('membershipEyebrow-${entry.key}'),
        entry.asset,
      );
    }
    expectSvgAsset(
      tester,
      const Key('membershipCheck-free-0'),
      AppAssets.membershipCheckWhite,
    );
    expectSvgAsset(
      tester,
      const Key('membershipCheck-hereNow-0'),
      AppAssets.membershipCheckBlue,
    );
    expectSvgAsset(
      tester,
      const Key('membershipCheck-lifetime-0'),
      AppAssets.membershipCheckWhite,
    );
    expectSvgAsset(
      tester,
      const Key('membershipCtaArrow-free'),
      AppAssets.arrowUpRight,
    );
    expectSvgAsset(
      tester,
      const Key('membershipCtaArrow-lifetime'),
      AppAssets.membershipArrowCharcoal,
    );
    expectSvgAsset(
      tester,
      const Key('foundingOfferGlyph'),
      AppAssets.foundingOfferGlyph,
    );

    for (final asset in [
      AppAssets.membershipFreeEyebrow,
      AppAssets.membershipHereNowEyebrow,
      AppAssets.membershipLifetimeEyebrow,
      AppAssets.membershipCheckWhite,
      AppAssets.membershipCheckBlue,
      AppAssets.membershipArrowCharcoal,
    ]) {
      expect(asset, startsWith('assets/'));
      expect(asset, isNot(contains('figma.com')));
    }
  });

  testWidgets('uses deliberate pricing-card column transitions', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(320, 568), columns: 1),
      (size: Size(390, 844), columns: 1),
      (size: Size(768, 1024), columns: 2),
      (size: Size(900, 800), columns: 2),
      (size: Size(1024, 768), columns: 2),
      (size: Size(1200, 900), columns: 3),
      (size: Size(1440, 900), columns: 3),
    ]) {
      setTestSurface(tester, example.size);
      await pumpLandingApp(tester);

      expect(find.byType(MembershipCard), findsNWidgets(3));
      expect(
        find.byKey(Key('membershipCardsColumns${example.columns}')),
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
      if (example.size.width == 1440) {
        final heights = <double>[];
        for (final id in ['free', 'hereNow', 'lifetime']) {
          final cardSize = tester.getSize(
            find.byKey(Key('membershipCardSurface-$id')),
          );
          expect(cardSize.width, closeTo(442.6666666666667, 0.01));
          expect(cardSize.height, greaterThanOrEqualTo(640));
          heights.add(cardSize.height);
        }
        expect(heights.toSet(), hasLength(1));
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('preserves visual-only pricing actions and card variants', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpLandingApp(tester);

    expectHeaderSemantics(
      tester,
      const Key('membershipHeadingSemantics'),
      'Membership',
    );
    for (final entry in const [
      (id: 'free', tier: 'FREE MEMBERSHIP', price: '£0 per month'),
      (id: 'hereNow', tier: 'HERE & NOW MEMBERSHIP', price: '£11 per month'),
      (
        id: 'lifetime',
        tier: 'LIFETIME MEMBERSHIP',
        price: '£249 one-time payment',
      ),
    ]) {
      expectHeaderSemantics(
        tester,
        Key('membershipTierSemantics-${entry.id}'),
        entry.tier,
      );
      expect(
        tester
            .getSemantics(
              find.byKey(Key('membershipPriceSemantics-${entry.id}')),
            )
            .getSemanticsData()
            .label,
        entry.price,
      );
    }
    expect(
      (tester
                  .widget<DecoratedBox>(
                    find.byKey(const Key('membershipCardSurface-free')),
                  )
                  .decoration
              as BoxDecoration)
          .color,
      AppColors.lightForeground,
    );
    expect(
      (tester
                  .widget<DecoratedBox>(
                    find.byKey(const Key('membershipCardSurface-hereNow')),
                  )
                  .decoration
              as BoxDecoration)
          .color,
      AppColors.yellowAccent,
    );
    expect(
      (tester
                  .widget<DecoratedBox>(
                    find.byKey(const Key('membershipCardSurface-lifetime')),
                  )
                  .decoration
              as BoxDecoration)
          .color,
      AppColors.warmCharcoalAccent,
    );
    expect(
      find.descendant(
        of: find.byType(MembershipSection),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
    for (final key in const [
      Key('membershipCheck-free-0'),
      Key('membershipCheck-hereNow-0'),
      Key('membershipCheck-lifetime-0'),
      Key('membershipCtaArrow-free'),
      Key('membershipCtaArrow-hereNow'),
      Key('membershipCtaArrow-lifetime'),
    ]) {
      expect(
        tester.widget<SvgPicture>(find.byKey(key)).excludeFromSemantics,
        isTrue,
      );
    }
    semantics.dispose();
  });
}
