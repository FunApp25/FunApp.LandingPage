import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_benefit_card.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_section.dart';

import '../landing_test_helpers.dart';

void main() {
  testWidgets('renders authoritative English Founding Member content', (
    tester,
  ) async {
    await pumpLandingApp(tester);

    expect(find.text('What does Founding Member mean'), findsOneWidget);
    expect(
      find.text(
        'It simply means you supported Fun App before everyone else. In '
        'return, we keep it simple.',
      ),
      findsOneWidget,
    );
    expect(find.byType(FoundingMemberBenefitCard), findsNWidgets(3));
    expect(
      [
        for (final id in ['recognised', 'access', 'voice'])
          tester
              .widget<Text>(find.byKey(Key('foundingMemberCardTitle-$id')))
              .data,
      ],
      orderedEquals([
        'Recognised Forever',
        'Early Access Always',
        'A Direct Voice',
      ]),
    );
    expect(
      find.text(
        'A clean profile badge showing you backed the project from the start',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Try new tools and experiments before they roll out publicly',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Your feedback goes straight to the team building the roadmap',
      ),
      findsOneWidget,
    );
  });

  for (final example in const [
    (
      locale: Locale('es'),
      size: Size(390, 844),
      heading: '¿Qué significa ser Founding Member?',
      firstTitle: 'Reconocimiento para siempre',
    ),
    (
      locale: Locale('cy'),
      size: Size(900, 800),
      heading: 'Beth mae Founding Member yn ei olygu?',
      firstTitle: 'Cydnabyddiaeth am Byth',
    ),
    (
      locale: Locale('be'),
      size: Size(1440, 900),
      heading: 'Што азначае Founding Member?',
      firstTitle: 'Прызнанне назаўсёды',
    ),
  ]) {
    testWidgets('renders responsive ${example.locale.languageCode} content', (
      tester,
    ) async {
      setTestSurface(tester, example.size);
      await pumpLandingApp(tester, locale: example.locale);

      expect(find.text(example.heading), findsOneWidget);
      expect(find.text(example.firstTitle), findsOneWidget);
      expect(find.byType(FoundingMemberBenefitCard), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses the exact committed Founding Member icons', (tester) async {
    await pumpLandingApp(tester);

    for (final entry in const [
      (id: 'recognised', asset: AppAssets.foundingMemberUsers),
      (id: 'access', asset: AppAssets.foundingMemberRocket),
      (id: 'voice', asset: AppAssets.foundingMemberChat),
    ]) {
      expectSvgAsset(
        tester,
        Key('foundingMemberIcon-${entry.id}'),
        entry.asset,
      );
      expect(entry.asset, startsWith('assets/landing/founding_member/'));
      expect(entry.asset, isNot(contains('figma.com')));
      expect(
        tester
            .widget<SvgPicture>(
              find.byKey(Key('foundingMemberIcon-${entry.id}')),
            )
            .excludeFromSemantics,
        isTrue,
      );
    }
  });

  testWidgets('uses deliberate Founding Member layout transitions', (
    tester,
  ) async {
    for (final example in const [
      (size: Size(320, 568), columns: 1, wide: false),
      (size: Size(390, 844), columns: 1, wide: false),
      (size: Size(768, 1024), columns: 2, wide: false),
      (size: Size(900, 800), columns: 2, wide: false),
      (size: Size(1024, 768), columns: 2, wide: false),
      (size: Size(1200, 900), columns: 3, wide: false),
      (size: Size(1440, 900), columns: 3, wide: true),
    ]) {
      setTestSurface(tester, example.size);
      await pumpLandingApp(tester);

      expect(
        find.byKey(Key('foundingMemberCardsColumns${example.columns}')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          Key(
            example.wide
                ? 'foundingMemberWideLayout'
                : 'foundingMemberStackedIntroLayout',
          ),
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(FoundingMemberSection)).width,
        lessThanOrEqualTo(example.size.width),
      );
      if (example.size.width == 1440) {
        final cardSize = tester.getSize(
          find.byKey(const Key('foundingMemberCardSurface-recognised')),
        );
        expect(cardSize.width, 328);
        expect(cardSize.height, greaterThanOrEqualTo(360));
        expect(
          tester
              .widget<ConstrainedBox>(
                find.byKey(const Key('foundingMemberCardBounds-recognised')),
              )
              .constraints
              .minHeight,
          360,
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('exposes headings while keeping cards static', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpLandingApp(tester);

    expectHeaderSemantics(
      tester,
      const Key('foundingMemberHeadingSemantics'),
      'What does Founding Member mean',
    );
    expectHeaderSemantics(
      tester,
      const Key('foundingMemberCardTitleSemantics-recognised'),
      'Recognised Forever',
    );
    expect(
      tester
          .widget<ColoredBox>(
            find.byKey(const Key('foundingMemberBackground')),
          )
          .color,
      AppColors.beigeAccent,
    );
    expect(
      find.descendant(
        of: find.byType(FoundingMemberSection),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
    semantics.dispose();
  });
}
