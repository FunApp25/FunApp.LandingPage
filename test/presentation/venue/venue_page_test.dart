import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';
import 'package:fun_app_landing_page/domain/venue/venue_lead_repository_interface.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/landing_header.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_privacy_disclosure.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_dialog.dart';
import 'package:fun_app_landing_page/presentation/venue/pages/venue_page.dart';
import 'package:fun_app_landing_page/presentation/venue/widgets/venue_page_introduction.dart';

import '../landing/landing_test_helpers.dart';

void main() {
  const eyebrow =
      'LIFE IS TOUGH FOR PEOPLE. LIFE IS TOUGH FOR VENUES. FUN APP IS '
      'ARRIVING TO HELP.';
  const introFirst =
      'Fun App is arriving to help, launching in the UK in Feb ’27 and '
      'rolling out to the USA in July.';
  const introSecond =
      'Tell us who you are, what you’re doing and Fun App will be thrilled '
      'to tell you how it is going to change the world – and welcome your '
      'venue to an exciting new future.';

  testWidgets('landing Venue CTA pushes the canonical routed page', (
    tester,
  ) async {
    await _pumpApp(tester);

    final cta = find.byKey(const Key('venueCardCta'));
    await tester.ensureVisible(cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.byType(VenuePage), findsOneWidget);
    expect(find.byType(LandingDialog), findsNothing);
    expect(
      ModalRoute.of(tester.element(find.byType(VenuePage)))?.settings.name,
      VenuePage.routeName,
    );
    expect(find.byKey(const Key('venueLeadForm')), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LandingPage), findsOneWidget);
  });

  testWidgets('Venue page composes shared chrome and exact Figma intro', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final launched = <Uri>[];
    await _pumpApp(tester, onPrivacyNoticeLaunch: launched.add);
    Navigator.of(
      tester.element(find.byType(LandingPage)),
    ).pushNamed(VenuePage.routeName);
    await tester.pumpAndSettle();

    expect(find.byType(LandingHeader), findsOneWidget);
    expect(find.byType(LandingFooter), findsOneWidget);
    expect(find.byType(VenuePageIntroduction), findsOneWidget);
    expect(find.text(eyebrow), findsOneWidget);
    expect(find.text('Thank you for your interest'), findsOneWidget);
    expect(find.text(introFirst), findsOneWidget);
    expect(find.text(introSecond), findsOneWidget);
    expect(find.byKey(const Key('venueLeadForm')), findsOneWidget);
    expect(find.byKey(const Key('venueLeadDialogTitle')), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(CheckboxListTile), findsNothing);

    final disclosure = find.byType(VenuePrivacyDisclosure);
    await tester.ensureVisible(disclosure);
    tester.semantics.tap(find.semantics.byLabel('Privacy Notice'));
    await tester.pump();
    expect(launched, hasLength(1));
    expect(launched.single.fragment, '/privacy');
    semantics.dispose();
  });

  testWidgets('Venue shared navigation returns to a rendered landing anchor', (
    tester,
  ) async {
    await _pumpApp(tester);
    Navigator.of(
      tester.element(find.byType(LandingPage)),
    ).pushNamed(VenuePage.routeName);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('landingHeaderNavigationItem1')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(VenuePage), findsNothing);
    expect(find.byType(LandingPage), findsOneWidget);
    expect(find.byType(MembershipSection), findsOneWidget);
    final scrollable = tester.widget<SingleChildScrollView>(
      find.byKey(const Key('landingPageScrollView')),
    );
    expect(scrollable.controller?.offset, greaterThan(0));
    expect(
      ModalRoute.of(tester.element(find.byType(LandingPage)))?.settings.name,
      '/',
    );
  });

  testWidgets('Venue footer navigation returns to the landing route', (
    tester,
  ) async {
    await _pumpDirectVenuePage(tester);

    final footerMembership = find.byKey(const Key('footerNavigationItem1'));
    await tester.ensureVisible(footerMembership);
    await tester.tap(footerMembership);
    await tester.pumpAndSettle();

    expect(find.byType(VenuePage), findsNothing);
    expect(find.byType(LandingPage), findsOneWidget);
    final scrollable = tester.widget<SingleChildScrollView>(
      find.byKey(const Key('landingPageScrollView')),
    );
    expect(scrollable.controller?.offset, greaterThan(0));
  });

  testWidgets('Venue mobile menu closes before routing to a landing anchor', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpDirectVenuePage(tester);

    await tester.tap(find.byKey(const Key('landingMobileMenuButton')));
    await tester.pump();
    expect(find.byKey(const Key('landingMobileMenu')), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('landingMobileMenuNavigationItem2')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('landingMobileMenu')), findsNothing);
    expect(find.byType(VenuePage), findsNothing);
    expect(find.byType(LandingPage), findsOneWidget);
  });

  testWidgets('routed form preserves the current temporary success behavior', (
    tester,
  ) async {
    await _pumpDirectVenuePage(tester);

    for (final entry in <(Key, String)>[
      (const Key('venueLeadVenueNameField'), 'Test Venue'),
      (const Key('venueLeadWebsiteField'), 'venue.example.com'),
      (const Key('venueLeadFirstNameField'), 'Test'),
      (const Key('venueLeadLastNameField'), 'Person'),
      (const Key('venueLeadRoleField'), 'Manager'),
      (const Key('venueLeadEmailField'), 'test@venue.example.com'),
    ]) {
      await tester.enterText(find.byKey(entry.$1), entry.$2);
    }
    final submit = find.byKey(const Key('venueLeadSubmitButton'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('venueLeadSuccess')), findsOneWidget);
    expect(find.byKey(const Key('venueLeadSubmitButton')), findsNothing);
    expect(
      find.byKey(const Key('venueLeadSuccessCloseButton')),
      findsOneWidget,
    );
  });

  testWidgets('Venue shell follows mobile and desktop Figma geometry', (
    tester,
  ) async {
    for (final size in const [Size(390, 844), Size(1440, 1200)]) {
      setTestSurface(tester, size);
      await _pumpDirectVenuePage(tester);

      final wrapper = tester.widget<Padding>(
        find.byKey(const Key('venuePageOuterWrapper')),
      );
      final cardPadding = tester.widget<Padding>(
        find.byKey(const Key('venuePageCardPadding')),
      );
      final card = tester.widget<DecoratedBox>(
        find.byKey(const Key('venuePageCard')),
      );
      final decoration = card.decoration as BoxDecoration;
      final cardRect = tester.getRect(find.byKey(const Key('venuePageCard')));

      expect(decoration.color, AppColors.beigeAccent);
      expect(decoration.borderRadius, BorderRadius.circular(20));
      expect(cardRect.width, size.width - (size.width < 600 ? 32 : 80));
      if (size.width < 600) {
        expect(wrapper.padding, const EdgeInsets.all(16));
        expect(
          cardPadding.padding,
          const EdgeInsets.fromLTRB(16, 80, 16, 80),
        );
        expect(cardRect.width, 358);
        expect(
          svgAssetName(tester, const Key('venuePageEyebrowGlyph')),
          AppAssets.venuePageEyebrowMobile,
        );
      } else {
        expect(
          wrapper.padding,
          const EdgeInsets.fromLTRB(40, 20, 40, 40),
        );
        expect(
          cardPadding.padding,
          const EdgeInsets.fromLTRB(40, 128, 40, 128),
        );
        expect(
          tester.getSize(find.byKey(const Key('venuePageContent'))).width,
          1016,
        );
        expect(
          svgAssetName(tester, const Key('venuePageEyebrowGlyph')),
          AppAssets.heroEyebrowGlyph,
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  for (final width in const [320.0, 390.0, 599.0, 600.0, 768.0, 1440.0]) {
    testWidgets('Venue page remains overflow-safe at ${width}px', (
      tester,
    ) async {
      setTestSurface(tester, Size(width, 1000));
      await _pumpDirectVenuePage(tester);

      expect(find.byType(VenuePage), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('venuePageCard'))).width,
        lessThanOrEqualTo(width),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Venue page supports two-times text scaling', (tester) async {
    setTestSurface(tester, const Size(390, 1000));
    tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );
    await _pumpDirectVenuePage(tester);

    expect(find.byType(VenuePage), findsOneWidget);
    expect(find.byKey(const Key('venuePageScrollView')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  ValueChanged<Uri>? onPrivacyNoticeLaunch,
}) async {
  await tester.pumpWidget(
    FunAppLandingPageApp(
      createVenueLeadFormBloc: () =>
          VenueLeadFormBloc(const _ImmediateVenueLeadRepository()),
      onPrivacyNoticeLaunch: onPrivacyNoticeLaunch,
    ),
  );
  await tester.pump();
}

Future<void> _pumpDirectVenuePage(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    FunAppLandingPageApp(
      createVenueLeadFormBloc: () =>
          VenueLeadFormBloc(const _ImmediateVenueLeadRepository()),
    ),
  );
  await tester.pump();
  Navigator.of(
    tester.element(find.byType(LandingPage)),
  ).pushNamed(VenuePage.routeName);
  await tester.pumpAndSettle();
}

final class _ImmediateVenueLeadRepository
    implements VenueLeadRepositoryInterface {
  const _ImmediateVenueLeadRepository();

  @override
  Future<Either<AppFailure, Unit>> submitVenueLead(VenueLead lead) async =>
      right(unit);
}
