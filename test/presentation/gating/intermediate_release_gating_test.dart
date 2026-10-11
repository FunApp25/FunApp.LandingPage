import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/core/config/release_configuration.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';
import 'package:fun_app_landing_page/domain/venue/venue_lead_repository_interface.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_router.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_dialog.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_placeholder_page.dart';
import 'package:fun_app_landing_page/presentation/privacy/pages/privacy_notice_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/founding_friend_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/here_and_now_page.dart';
import 'package:fun_app_landing_page/presentation/venue/pages/venue_page.dart';

import '../landing/landing_test_helpers.dart';

void main() {
  const gatedPaths = <String>[
    HereAndNowPage.routeName,
    FoundingFriendPage.routeName,
    LegalPlaceholderPage.termsRouteName,
    LegalPlaceholderPage.refundsRouteName,
    LegalPlaceholderPage.cookiesRouteName,
    LegalPlaceholderPage.cookieBannerRouteName,
  ];

  testWidgets('production direct visits replace gated routes with landing', (
    tester,
  ) async {
    for (final path in gatedPaths) {
      tester.binding.platformDispatcher.defaultRouteNameTestValue = path;
      await _pumpProductionApp(tester);
      await tester.pumpAndSettle();

      expect(find.byType(LandingPage), findsOneWidget, reason: path);
      expect(find.byType(HereAndNowPage), findsNothing, reason: path);
      expect(find.byType(FoundingFriendPage), findsNothing, reason: path);
      expect(find.byType(LegalPlaceholderPage), findsNothing, reason: path);
      final router = tester.element(find.byType(LandingPage)).router;
      expect(router.currentPath, '/', reason: path);
      expect(router.stackData, hasLength(1), reason: path);
      expect(tester.takeException(), isNull, reason: path);
    }
    tester.binding.platformDispatcher.clearDefaultRouteNameTestValue();
  });

  testWidgets('production internal route updates cannot bypass gating', (
    tester,
  ) async {
    await _pumpProductionApp(tester);
    final router = tester.element(find.byType(LandingPage)).router;

    for (final path in gatedPaths) {
      expect(await tester.binding.handlePushRoute(path), isTrue, reason: path);
      await tester.pumpAndSettle();
      expect(find.byType(LandingPage), findsOneWidget, reason: path);
      expect(router.currentPath, '/', reason: path);
      expect(router.stackData, hasLength(1), reason: path);
    }
  });

  testWidgets('production exposes only Privacy in every landing footer', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 900));
    await _pumpProductionApp(tester);

    final footer = find.byKey(const Key('footerLegalItems'));
    await tester.ensureVisible(footer);
    expect(find.byKey(const Key('footerPrivacyNoticeLink')), findsOneWidget);
    expect(find.byKey(const Key('footerTermsLink')), findsNothing);
    expect(find.byKey(const Key('footerRefundsLink')), findsNothing);
    expect(find.byKey(const Key('footerCookiePolicyLink')), findsNothing);
    expect(find.byKey(const Key('footerCookieBannerLink')), findsNothing);
  });

  testWidgets('all production landing sign-up CTAs show one reusable dialog', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 1000));
    await _pumpProductionApp(tester);

    for (final key in const [
      Key('landingHeaderContactCta'),
      Key('membershipCta-free'),
      Key('membershipCta-hereNow'),
      Key('foundingOfferCta'),
      Key('membershipCta-lifetime'),
      Key('foundingFriendsCta'),
    ]) {
      final cta = find.byKey(key);
      await tester.ensureVisible(cta);
      await tester.tap(cta);
      await tester.pumpAndSettle();

      expect(find.byType(LandingDialog), findsOneWidget, reason: '$key');
      expect(find.byType(HereAndNowPage), findsNothing, reason: '$key');
      expect(find.byType(FoundingFriendPage), findsNothing, reason: '$key');
      final router = tester.element(find.byType(LandingPage)).router;
      expect(router.stackData, hasLength(1), reason: '$key');

      await tester.tap(find.byKey(const Key('landingDialogCloseButton')));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('production mobile header and menu queue CTAs show the dialog', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await _pumpProductionApp(tester);

    await tester.tap(find.byKey(const Key('landingHeaderContactCta')));
    await tester.pumpAndSettle();
    expect(find.byType(LandingDialog), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('landingMobileMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('landingMobileMenuContactCta')));
    await tester.pumpAndSettle();
    expect(find.byType(LandingDialog), findsOneWidget);
    expect(find.byType(HereAndNowPage), findsNothing);
  });

  testWidgets('production keeps Venue and Privacy routes available', (
    tester,
  ) async {
    await _pumpProductionApp(tester);
    final router = tester.element(find.byType(LandingPage)).router;

    unawaited(router.push(VenueRoute()));
    await tester.pumpAndSettle();
    expect(find.byType(VenuePage), findsOneWidget);

    await _pumpProductionApp(tester);
    unawaited(
      tester
          .element(find.byType(LandingPage))
          .router
          .push(
            PrivacyNoticeRoute(),
          ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PrivacyNoticePage), findsOneWidget);
  });

  testWidgets('explicit preview keeps forms and draft legal routes available', (
    tester,
  ) async {
    await _pumpPreviewApp(tester);
    final router = tester.element(find.byType(LandingPage)).router;

    unawaited(router.push(HereAndNowRoute()));
    await tester.pumpAndSettle();
    expect(find.byType(HereAndNowPage), findsOneWidget);

    await _pumpPreviewApp(tester);
    unawaited(
      tester
          .element(find.byType(LandingPage))
          .router
          .push(
            FoundingFriendRoute(),
          ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FoundingFriendPage), findsOneWidget);

    await _pumpPreviewApp(tester);
    unawaited(
      tester
          .element(find.byType(LandingPage))
          .router
          .push(
            const TermsRoute(),
          ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(LegalPlaceholderPage), findsOneWidget);
  });

  testWidgets('coming-soon message is localized in all supported locales', (
    tester,
  ) async {
    for (final locale in AppLocalizations.supportedLocales) {
      setTestSurface(tester, const Size(390, 844));
      tester.binding.platformDispatcher.localesTestValue = [locale];
      await _pumpProductionApp(tester);
      await tester.tap(find.byKey(const Key('landingHeaderContactCta')));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(LandingDialog));
      final l10n = AppLocalizations.of(context);
      expect(
        find.text(l10n.landingInterestedUserComingSoonTitle),
        findsOneWidget,
        reason: locale.languageCode,
      );
      expect(
        find.text(l10n.landingInterestedUserComingSoonBody),
        findsOneWidget,
        reason: locale.languageCode,
      );
    }
    tester.binding.platformDispatcher.clearLocalesTestValue();
  });
}

Future<void> _pumpProductionApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    FunAppLandingPageApp(
      createVenueLeadFormBloc: () =>
          VenueLeadFormBloc(const _ImmediateVenueLeadRepository()),
    ),
  );
  await tester.pump();
}

Future<void> _pumpPreviewApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    const FunAppLandingPageApp(
      releaseConfiguration: ReleaseConfiguration.preview(),
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
