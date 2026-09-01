import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/connection/connection_experience_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/problem/problem_statement_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_stat_card.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_stats_section.dart';

import '../landing_test_helpers.dart';

const _thirdStatDescription =
    'of 16-24 year olds say loneliness negatively affects their mental health';
const _fourthStatDescription =
    'of all young people find it difficult to move from screen to making '
    'friends IRL';
const _connectionBody =
    'What if the existing introductions app culture — where users are largely '
    'viewed as an asset to generate profit for the connection platforms — was '
    'replaced with a warm, welcoming and respectful environment where users '
    'meet others IRL, free of charge, in thousands of venues of all shapes, '
    'sizes and types around the country?';

void main() {
  testWidgets('renders authoritative English research and connection copy', (
    tester,
  ) async {
    await pumpLandingApp(tester);

    expect(find.text('THE PROBLEM'), findsOneWidget);
    final problemStatement = tester.widget<Text>(
      find.byKey(const Key('problemStatementText')),
    );
    expect(
      problemStatement.textSpan?.toPlainText(),
      'Widespread research highlights shocking statistics about a loneliness '
      'epidemic across the UK and the world, especially amongst young adults.',
    );

    expect(find.text('Did you know that in the UK?'), findsOneWidget);
    for (final value in ['49%', '67%', '70%', '44%']) {
      expect(find.text(value), findsOneWidget);
    }
    for (final description in [
      'of 18-24 year old women feel lonely some or all of the time',
      'of 18-29 year olds feel lonely at least once a week',
      _thirdStatDescription,
      _fourthStatDescription,
    ]) {
      expect(find.text(description), findsOneWidget);
    }

    final attribution = tester.widget<Text>(
      find.byKey(const Key('researchStatsAttribution')),
    );
    expect(
      attribution.textSpan?.toPlainText(),
      'Recent UK research from Belonging Forum · Marmalade Trust · '
      'BACP / YouGov. With thanks to The Great Friendship Project, London, '
      'for compiling these figures.',
    );

    expect(find.text('A DIFFERENT WAY TO CONNECT'), findsOneWidget);
    expect(
      find.text('Do you recognise any of these experiences?'),
      findsOneWidget,
    );
    expect(find.text(_connectionBody), findsOneWidget);
  });

  for (final example in const [
    (
      locale: Locale('es'),
      problem: 'EL PROBLEMA',
      stats: '¿Sabías que en el Reino Unido?',
      connection: '¿Reconoces alguna de estas experiencias?',
      firstStat:
          'de las mujeres de 18 a 24 años se sienten solas algunas veces o '
          'todo el tiempo',
    ),
    (
      locale: Locale('cy'),
      problem: 'Y BROBLEM',
      stats: 'Oeddech chi’n gwybod hyn am y DU?',
      connection: 'Ydych chi’n adnabod unrhyw un o’r profiadau hyn?',
      firstStat:
          'o fenywod 18–24 oed yn teimlo’n unig rywfaint o’r amser neu '
          'drwy’r amser',
    ),
    (
      locale: Locale('be'),
      problem: 'ПРАБЛЕМА',
      stats: 'Ці ведалі вы, што ў Вялікабрытаніі?',
      connection: 'Ці знаёмыя вам якія-небудзь з гэтых сітуацый?',
      firstStat:
          'жанчын ва ўзросце 18–24 гадоў адчуваюць адзіноту часам або '
          'ўвесь час',
    ),
  ]) {
    testWidgets('renders representative ${example.locale.languageCode} copy', (
      tester,
    ) async {
      setTestSurface(tester, const Size(320, 568));
      await pumpLandingApp(tester, locale: example.locale);

      expect(find.text(example.problem), findsOneWidget);
      expect(find.text(example.stats), findsOneWidget);
      expect(find.text(example.connection), findsOneWidget);
      expect(find.text(example.firstStat), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses committed local Figma and verified brand assets', (
    tester,
  ) async {
    await pumpLandingApp(tester);

    expectSvgAsset(
      tester,
      const Key('problemEyebrowGlyph'),
      AppAssets.fiveDiagonalOvals,
    );
    expectSvgAsset(
      tester,
      const Key('connectionEyebrowGlyph'),
      AppAssets.roundedSparkleDiamond,
    );

    final image = tester.widget<Image>(
      find.byKey(const Key('connectionExperienceImage')),
    );
    expect(image.image, isA<AssetImage>());
    expect(
      (image.image as AssetImage).assetName,
      AppAssets.connectionGroup,
    );

    for (final asset in [
      AppAssets.fiveDiagonalOvals,
      AppAssets.roundedSparkleDiamond,
      AppAssets.connectionGroup,
    ]) {
      expect(asset, startsWith('assets/'));
      expect(asset, isNot(contains('figma.com')));
    }
  });

  testWidgets('reflows statistic cards and connection content by constraints', (
    tester,
  ) async {
    for (final example in const [
      (
        size: Size(320, 568),
        columns: 1,
        headingSize: 34.0,
        statementSize: 34.0,
        usesWideConnection: false,
      ),
      (
        size: Size(390, 844),
        columns: 1,
        headingSize: 34.0,
        statementSize: 34.0,
        usesWideConnection: false,
      ),
      (
        size: Size(768, 1024),
        columns: 2,
        headingSize: 40.0,
        statementSize: 42.0,
        usesWideConnection: false,
      ),
      (
        size: Size(1024, 768),
        columns: 2,
        headingSize: 40.0,
        statementSize: 42.0,
        usesWideConnection: false,
      ),
      (
        size: Size(1440, 900),
        columns: 4,
        headingSize: 44.0,
        statementSize: 50.0,
        usesWideConnection: true,
      ),
    ]) {
      setTestSurface(tester, example.size);
      await pumpLandingApp(tester);

      expect(find.byType(ResearchStatCard), findsNWidgets(4));
      final grid = find.byKey(Key('researchStatsColumns${example.columns}'));
      expect(grid, findsOneWidget);
      expect(tester.widget<Wrap>(grid).children, hasLength(4));
      expect(
        tester
            .widget<Text>(
              find.byKey(const Key('researchStatsHeadingText')),
            )
            .style
            ?.fontSize,
        example.headingSize,
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('problemStatementText')))
            .textSpan
            ?.style
            ?.fontSize,
        example.statementSize,
      );
      final firstCardBounds = tester.widget<ConstrainedBox>(
        find.byKey(const Key('researchStatCardBounds-49%')),
      );
      if (example.columns == 1) {
        expect(firstCardBounds.constraints.minHeight, 0);
      } else {
        expect(firstCardBounds.constraints.minHeight, 404);
      }
      expect(
        find.byKey(
          Key(
            example.usesWideConnection
                ? 'connectionWideLayout'
                : 'connectionStackedLayout',
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      for (final section in [
        find.byType(ProblemStatementSection),
        find.byType(ResearchStatsSection),
        find.byType(ConnectionExperienceSection),
      ]) {
        expect(
          tester.getSize(section).width,
          lessThanOrEqualTo(example.size.width),
        );
      }
    }
  });

  testWidgets('exposes section, card, and image semantics in reading order', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpLandingApp(tester);

    expectHeaderSemantics(
      tester,
      const Key('problemStatementSemantics'),
      'Widespread research highlights shocking statistics about a loneliness '
      'epidemic across the UK and the world, especially amongst young '
      'adults.',
    );
    expectHeaderSemantics(
      tester,
      const Key('researchStatsHeadingSemantics'),
      'Did you know that in the UK?',
    );
    expectHeaderSemantics(
      tester,
      const Key('connectionHeadingSemantics'),
      'Do you recognise any of these experiences?',
    );

    for (final value in ['49%', '67%', '70%', '44%']) {
      final cardSemantics = tester.widget<Semantics>(
        find.byKey(Key('researchStatCardSemantics-$value')),
      );
      expect(cardSemantics.container, isTrue);
      expect(cardSemantics.explicitChildNodes, isTrue);
    }

    final firstCardText = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(ResearchStatCard).first,
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data)
        .toList();
    expect(
      firstCardText,
      orderedEquals([
        '49%',
        'of 18-24 year old women feel lonely some or all of the time',
      ]),
    );

    final imageSemantics = tester
        .getSemantics(find.byKey(const Key('connectionImageSemantics')))
        .getSemanticsData();
    expect(
      imageSemantics.label,
      'Four smiling people posing closely together outdoors.',
    );
    expect(imageSemantics.flagsCollection.isImage, isTrue);

    for (final key in const [
      Key('problemEyebrowGlyph'),
      Key('connectionEyebrowGlyph'),
    ]) {
      expect(
        tester.widget<SvgPicture>(find.byKey(key)).excludeFromSemantics,
        isTrue,
      );
    }
    semantics.dispose();
  });
}
