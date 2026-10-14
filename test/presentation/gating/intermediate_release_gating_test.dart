import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';
import 'package:fun_app_landing_page/domain/venue/venue_lead_repository_interface.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_router.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_placeholder_page.dart';
import 'package:fun_app_landing_page/presentation/privacy/pages/privacy_notice_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/founding_friend_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/here_and_now_page.dart';
import 'package:fun_app_landing_page/presentation/venue/pages/venue_page.dart';

import '../landing/landing_test_helpers.dart';

void main() {
  const protectedLegalPaths = <String>[
    LegalPlaceholderPage.termsRouteName,
    LegalPlaceholderPage.refundsRouteName,
    LegalPlaceholderPage.cookiesRouteName,
    LegalPlaceholderPage.cookieBannerRouteName,
  ];

  testWidgets('registration forms support direct route initialization', (
    tester,
  ) async {
    for (final example in const [
      (path: HereAndNowPage.routeName, type: HereAndNowPage),
      (path: FoundingFriendPage.routeName, type: FoundingFriendPage),
    ]) {
      tester.binding.platformDispatcher.defaultRouteNameTestValue =
          example.path;
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );
      await _pumpPublicApp(tester);
      await tester.pumpAndSettle();

      expect(find.byType(example.type), findsOneWidget, reason: example.path);
      final router = tester.element(find.byType(example.type)).router;
      expect(router.currentPath, example.path, reason: example.path);
      expect(router.stackData, hasLength(1), reason: example.path);
      expect(tester.takeException(), isNull, reason: example.path);
    }
  });

  testWidgets('registration CTAs navigate to their intended forms', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 1000));
    await _pumpPublicApp(tester);

    for (final example in const [
      (
        key: 'landingHeaderContactCta',
        type: HereAndNowPage,
        path: HereAndNowPage.routeName,
      ),
      (
        key: 'membershipCta-free',
        type: HereAndNowPage,
        path: HereAndNowPage.routeName,
      ),
      (
        key: 'membershipCta-hereNow',
        type: HereAndNowPage,
        path: HereAndNowPage.routeName,
      ),
      (
        key: 'foundingOfferCta',
        type: HereAndNowPage,
        path: HereAndNowPage.routeName,
      ),
      (
        key: 'membershipCta-lifetime',
        type: FoundingFriendPage,
        path: FoundingFriendPage.routeName,
      ),
      (
        key: 'foundingFriendsCta',
        type: FoundingFriendPage,
        path: FoundingFriendPage.routeName,
      ),
    ]) {
      final cta = find.byKey(Key(example.key));
      await tester.ensureVisible(cta);
      await tester.tap(cta);
      await tester.pumpAndSettle();

      expect(find.byType(example.type), findsOneWidget, reason: example.key);
      expect(
        tester.element(find.byType(example.type)).router.currentPath,
        example.path,
        reason: example.key,
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LandingPage), findsOneWidget, reason: example.key);
    }
  });

  testWidgets('mobile header and menu registration CTAs navigate', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpPublicApp(tester);

    await tester.tap(find.byKey(const Key('landingHeaderContactCta')));
    await tester.pumpAndSettle();
    expect(find.byType(HereAndNowPage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('landingMobileMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('landingMobileMenuContactCta')));
    await tester.pumpAndSettle();
    expect(find.byType(HereAndNowPage), findsOneWidget);
  });

  testWidgets('registration routes support Back and Forward updates', (
    tester,
  ) async {
    await _pumpPublicApp(tester);
    final router = tester.element(find.byType(LandingPage)).router;

    unawaited(router.push(HereAndNowRoute()));
    await tester.pumpAndSettle();
    expect(router.currentPath, HereAndNowPage.routeName);
    expect(router.stackData, hasLength(2));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(router.currentPath, '/');
    expect(router.stackData, hasLength(1));

    expect(
      await tester.binding.handlePushRoute(FoundingFriendPage.routeName),
      isTrue,
    );
    await tester.pumpAndSettle();
    expect(router.currentPath, FoundingFriendPage.routeName);
    expect(router.stackData, hasLength(2));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(router.currentPath, '/');
    expect(router.stackData, hasLength(1));
  });

  testWidgets('unfinished legal routes stay inaccessible', (tester) async {
    for (final path in protectedLegalPaths) {
      tester.binding.platformDispatcher.defaultRouteNameTestValue = path;
      addTearDown(
        tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
      );
      await _pumpPublicApp(tester);
      await tester.pumpAndSettle();

      expect(find.byType(LandingPage), findsOneWidget, reason: path);
      expect(find.byType(LegalPlaceholderPage), findsNothing, reason: path);
      final router = tester.element(find.byType(LandingPage)).router;
      expect(router.currentPath, '/', reason: path);
      expect(router.stackData, hasLength(1), reason: path);
    }
  });

  testWidgets('unfinished legal route updates cannot bypass restrictions', (
    tester,
  ) async {
    await _pumpPublicApp(tester);
    final router = tester.element(find.byType(LandingPage)).router;

    for (final path in protectedLegalPaths) {
      expect(await tester.binding.handlePushRoute(path), isTrue, reason: path);
      await tester.pumpAndSettle();
      expect(find.byType(LandingPage), findsOneWidget, reason: path);
      expect(find.byType(LegalPlaceholderPage), findsNothing, reason: path);
      expect(router.currentPath, '/', reason: path);
      expect(router.stackData, hasLength(1), reason: path);
    }
  });

  testWidgets('production exposes only Privacy in the landing footer', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 900));
    await _pumpPublicApp(tester);

    final footer = find.byKey(const Key('footerLegalItems'));
    await tester.ensureVisible(footer);
    expect(find.byKey(const Key('footerPrivacyNoticeLink')), findsOneWidget);
    expect(find.byKey(const Key('footerTermsLink')), findsNothing);
    expect(find.byKey(const Key('footerRefundsLink')), findsNothing);
    expect(find.byKey(const Key('footerCookiePolicyLink')), findsNothing);
    expect(find.byKey(const Key('footerCookieBannerLink')), findsNothing);
  });

  testWidgets('Venue and Privacy routes remain available', (tester) async {
    await _pumpPublicApp(tester);
    final router = tester.element(find.byType(LandingPage)).router;

    unawaited(router.push(VenueRoute()));
    await tester.pumpAndSettle();
    expect(find.byType(VenuePage), findsOneWidget);

    await _pumpPublicApp(tester);
    unawaited(
      tester
          .element(find.byType(LandingPage))
          .router
          .push(PrivacyNoticeRoute()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PrivacyNoticePage), findsOneWidget);
  });
}

Future<void> _pumpPublicApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    FunAppLandingPageApp(
      createVenueLeadFormBloc: () =>
          VenueLeadFormBloc(const _ImmediateVenueLeadRepository()),
    ),
  );
  await tester.pump();
}

final class _ImmediateVenueLeadRepository
    implements VenueLeadRepositoryInterface {
  const _ImmediateVenueLeadRepository();

  @override
  Future<Either<AppFailure, Unit>> submitVenueLead(VenueLead lead) async =>
      right(unit);
}
