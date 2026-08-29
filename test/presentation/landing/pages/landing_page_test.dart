import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
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
  });

  testWidgets('uses a vertically scrollable page composition', (tester) async {
    await _pumpApp(tester);

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(scrollView.scrollDirection, Axis.vertical);

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

      for (final finder in [
        find.byType(LandingHeader),
        find.byType(HeroSection),
        find.byType(FaqSection),
        find.byType(LandingFooter),
      ]) {
        expect(tester.getSize(finder).width, lessThanOrEqualTo(size.width));
      }
    }
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  tester.binding.platformDispatcher.localesTestValue = const <Locale>[
    Locale('en'),
  ];
  addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(const FunAppLandingPageApp());
  await tester.pump();
}
