import 'dart:async';
import 'dart:collection';
import 'dart:ui' show CheckedState;

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('routed form reconciles real fields with Figma presentation', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 1200));
    await _pumpDirectVenuePage(tester);

    expect(find.byType(TextField), findsNWidgets(9));
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsNothing);
    expect(find.byKey(const Key('venueLeadTwoColumnLayout')), findsOneWidget);
    for (var row = 1; row <= 6; row++) {
      expect(find.byKey(Key('venueLeadDesktopRow$row')), findsOneWidget);
    }
    expect(find.text('Venue’s Name*'), findsOneWidget);
    expect(find.text('Web Address*'), findsOneWidget);
    expect(find.text('First Name*'), findsOneWidget);
    expect(find.text('Last Name*'), findsOneWidget);
    expect(find.text('Role*'), findsOneWidget);
    expect(find.text('Email*'), findsOneWidget);
    expect(find.text('Type of Venue*'), findsNothing);
    expect(find.text('Independent or Part of Chain*'), findsNothing);
    expect(find.text('Venue Capacity*'), findsNothing);
    expect(find.text('Phone Number*'), findsNothing);

    final venueName = tester.widget<TextField>(
      find.byKey(const Key('venueLeadVenueNameField')),
    );
    final firstName = tester.widget<TextField>(
      find.byKey(const Key('venueLeadFirstNameField')),
    );
    final lastName = tester.widget<TextField>(
      find.byKey(const Key('venueLeadLastNameField')),
    );
    expect(venueName.decoration?.hintText, 'Your Venue’s Name');
    expect(firstName.decoration?.hintText, 'Your First Name');
    expect(lastName.decoration?.hintText, 'Your Last Name');
    expect(
      tester.getSize(find.byKey(const Key('venueLeadVenueNameField'))),
      const Size(500, 48),
    );
    expect(
      tester.getSize(find.byKey(const Key('venueLeadVenueTypeField'))),
      const Size(500, 48),
    );
    expect(
      svgAssetName(tester, const Key('venueLeadChainStatusCaret')),
      AppAssets.venueCaretDown,
    );
    expect(
      svgAssetName(tester, const Key('venueLeadSubmitArrow')),
      AppAssets.venueSendArrowUpRight,
    );
    final submitRect = tester.getRect(
      find.byKey(const Key('venueLeadSubmitButton')),
    );
    final contentRect = tester.getRect(
      find.byKey(const Key('venuePageContent')),
    );
    expect(submitRect.height, 48);
    expect(submitRect.width, greaterThanOrEqualTo(144));
    expect(submitRect.center.dx, closeTo(contentRect.center.dx, 0.1));

    setTestSurface(tester, const Size(390, 1000));
    await _pumpDirectVenuePage(tester);
    expect(find.byKey(const Key('venueLeadOneColumnLayout')), findsOneWidget);
    expect(find.byKey(const Key('venueLeadTwoColumnLayout')), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('venueLeadVenueNameField'))),
      const Size(326, 48),
    );
    expect(
      tester.getSize(find.byKey(const Key('venueLeadSubmitButton'))).width,
      326,
    );

    setTestSurface(tester, const Size(768, 1000));
    await _pumpDirectVenuePage(tester);
    expect(find.byKey(const Key('venueLeadOneColumnLayout')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('acknowledgement is local, accessible, and link-independent', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final launched = <Uri>[];
    setTestSurface(tester, const Size(390, 1000));
    await _pumpDirectVenuePage(
      tester,
      onPrivacyNoticeLaunch: launched.add,
    );

    final checkbox = find.byKey(
      const Key('venuePrivacyAcknowledgementCheckbox'),
    );
    expect(
      tester
          .getSemantics(checkbox)
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.isFalse,
    );
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pump();
    expect(
      tester
          .getSemantics(checkbox)
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.isTrue,
    );

    tester
        .widget<Focus>(
          find.byKey(const Key('venuePrivacyAcknowledgementFocus')),
        )
        .focusNode
        ?.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(
      tester
          .getSemantics(checkbox)
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.isFalse,
    );

    await tester.tap(checkbox);
    await tester.pump();
    tester.semantics.tap(find.semantics.byLabel('Privacy Notice'));
    await tester.pump();
    expect(launched, hasLength(1));
    expect(launched.single.fragment, '/privacy');
    expect(
      tester
          .getSemantics(checkbox)
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.isTrue,
    );
    semantics.dispose();
  });

  testWidgets('chain dropdown preserves conditional count and payload', (
    tester,
  ) async {
    final repository = _ControlledVenueLeadRepository();
    setTestSurface(tester, const Size(390, 1000));
    await _pumpDirectVenuePage(tester, repository: repository);

    await tester.ensureVisible(
      find.byKey(const Key('venueLeadChainStatusMenu')),
    );
    await tester.tap(find.byKey(const Key('venueLeadChainStatusMenu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('venueChainPartOfChainOption')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsOneWidget);
    expect(find.text('If chain, number of venues'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('venueLeadVenueCountField')),
      '12',
    );

    await tester.tap(find.byKey(const Key('venueLeadChainStatusMenu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('venueChainIndependentOption')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsNothing);

    await _fillRequiredVenuePageFields(tester);
    await _tapVenuePageSubmit(tester);
    expect(repository.submittedLeads, hasLength(1));
    expect(repository.submittedLeads.single.venueCount.isNone(), isTrue);
    expect(
      repository.submittedLeads.single.chainStatus.toNullable()?.getOrCrash(),
      'Independent',
    );
    repository.completeNext(right(unit));
    await tester.pumpAndSettle();
  });

  testWidgets('routed validation expands rows and keeps required semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    setTestSurface(tester, const Size(1440, 1200));
    await _pumpDirectVenuePage(tester);

    expect(
      tester
          .getSemantics(find.byKey(const Key('venueLeadVenueNameField')))
          .getSemanticsData()
          .label,
      contains('Venue’s Name (required)'),
    );
    expect(
      tester
          .getSemantics(find.byKey(const Key('venueLeadVenueTypeField')))
          .getSemanticsData()
          .label,
      contains('Type of Venue (optional)'),
    );
    await _tapVenuePageSubmit(tester);
    expect(find.text('Required field'), findsNWidgets(6));
    expect(
      tester.getSize(find.byKey(const Key('venueLeadVenueNameField'))).height,
      greaterThan(48),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('venueLeadDesktopRow2'))).dy,
      greaterThan(
        tester.getBottomLeft(find.byKey(const Key('venueLeadDesktopRow1'))).dy,
      ),
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'acknowledgement does not block or alter pending, failure, or retry',
    (tester) async {
      final repository = _ControlledVenueLeadRepository();
      setTestSurface(tester, const Size(390, 1000));
      await _pumpDirectVenuePage(tester, repository: repository);
      await _fillRequiredVenuePageFields(tester);
      final checkbox = find.byKey(
        const Key('venuePrivacyAcknowledgementCheckbox'),
      );
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pump();

      await _tapVenuePageSubmit(tester);
      expect(repository.submittedLeads, hasLength(1));
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('venueLeadSubmitButton')),
            )
            .onPressed,
        isNull,
      );
      expect(
        find.byKey(const Key('venueLeadSubmissionProgress')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('venueLeadSubmitButton')));
      await tester.pump();
      expect(repository.submittedLeads, hasLength(1));

      repository.completeNext(left(const AppFailure.serviceUnavailable()));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('venueLeadSubmissionFailure')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('venueLeadVenueNameField')))
            .controller
            ?.text,
        'Test Venue',
      );

      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pump();
      await _tapVenuePageSubmit(tester);
      expect(repository.submittedLeads, hasLength(2));
      expect(repository.submittedLeads[1], repository.submittedLeads[0]);
      repository.completeNext(right(unit));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('venueLeadSuccess')), findsOneWidget);
    },
  );

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
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );
    for (final width in const [320.0, 390.0]) {
      setTestSurface(tester, Size(width, 1000));
      tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
      await _pumpDirectVenuePage(tester);

      expect(find.byType(VenuePage), findsOneWidget);
      expect(find.byKey(const Key('venuePageScrollView')), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const Key('venueLeadSubmitButton')),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(const Key('venueLeadSubmitButton'))).right,
        lessThanOrEqualTo(width),
      );
      expect(tester.takeException(), isNull);
    }
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

Future<void> _pumpDirectVenuePage(
  WidgetTester tester, {
  VenueLeadRepositoryInterface? repository,
  ValueChanged<Uri>? onPrivacyNoticeLaunch,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    FunAppLandingPageApp(
      createVenueLeadFormBloc: () => VenueLeadFormBloc(
        repository ?? const _ImmediateVenueLeadRepository(),
      ),
      onPrivacyNoticeLaunch: onPrivacyNoticeLaunch,
    ),
  );
  await tester.pump();
  Navigator.of(
    tester.element(find.byType(LandingPage)),
  ).pushNamed(VenuePage.routeName);
  await tester.pumpAndSettle();
}

Future<void> _fillRequiredVenuePageFields(WidgetTester tester) async {
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
  await tester.pump();
}

Future<void> _tapVenuePageSubmit(WidgetTester tester) async {
  final submit = find.byKey(const Key('venueLeadSubmitButton'));
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit);
  await tester.pump();
}

final class _ImmediateVenueLeadRepository
    implements VenueLeadRepositoryInterface {
  const _ImmediateVenueLeadRepository();

  @override
  Future<Either<AppFailure, Unit>> submitVenueLead(VenueLead lead) async =>
      right(unit);
}

final class _ControlledVenueLeadRepository
    implements VenueLeadRepositoryInterface {
  final submittedLeads = <VenueLead>[];
  final _pendingResults = Queue<Completer<Either<AppFailure, Unit>>>();

  @override
  Future<Either<AppFailure, Unit>> submitVenueLead(VenueLead lead) {
    submittedLeads.add(lead);
    final completer = Completer<Either<AppFailure, Unit>>();
    _pendingResults.add(completer);
    return completer.future;
  }

  void completeNext(Either<AppFailure, Unit> result) {
    _pendingResults.removeFirst().complete(result);
  }
}
