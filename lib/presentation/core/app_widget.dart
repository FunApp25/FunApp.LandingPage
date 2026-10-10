import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/core/utils/document_language.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_route_controller.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_section_target.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_placeholder_page.dart';
import 'package:fun_app_landing_page/presentation/privacy/pages/privacy_notice_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/founding_friend_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/here_and_now_page.dart';
import 'package:fun_app_landing_page/presentation/venue/pages/venue_page.dart';

/// Root widget for the Fun App landing-page application.
final class FunAppLandingPageApp extends StatefulWidget {
  /// Creates the root landing-page application widget.
  const FunAppLandingPageApp({
    this.onPrivacyNoticeLaunch,
    this.createVenueLeadFormBloc,
    super.key,
  });

  /// Optional browser-launch override for presentation tests.
  final ValueChanged<Uri>? onPrivacyNoticeLaunch;

  /// Optional Venue form BLoC factory override for presentation tests.
  final VenueLeadFormBlocFactory? createVenueLeadFormBloc;

  @override
  State<FunAppLandingPageApp> createState() => _FunAppLandingPageAppState();
}

final class _FunAppLandingPageAppState extends State<FunAppLandingPageApp> {
  final _landingRouteController = LandingRouteController();

  @override
  void dispose() {
    _landingRouteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Route<void> generateRoute(RouteSettings settings) {
      if (settings.name == PrivacyNoticePage.routeName) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PrivacyNoticePage(
            landingRouteController: _landingRouteController,
            onPrivacyNoticeLaunch: widget.onPrivacyNoticeLaunch,
          ),
        );
      } else if (settings.name case final name?
          when _legalPlaceholderRoutes.containsKey(name)) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => LegalPlaceholderPage(
            kind: _legalPlaceholderRoutes[name]!,
            landingRouteController: _landingRouteController,
            onPrivacyNoticeLaunch: widget.onPrivacyNoticeLaunch,
          ),
        );
      } else if (settings.name == VenuePage.routeName) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => VenuePage(
            createBloc: widget.createVenueLeadFormBloc,
            onPrivacyNoticeLaunch: widget.onPrivacyNoticeLaunch,
            landingRouteController: _landingRouteController,
          ),
        );
      } else if (settings.name == HereAndNowPage.routeName) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => HereAndNowPage(
            landingRouteController: _landingRouteController,
          ),
        );
      } else if (settings.name == FoundingFriendPage.routeName) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => FoundingFriendPage(
            landingRouteController: _landingRouteController,
          ),
        );
      } else {
        final initialSection =
            settings.name == '/' && settings.arguments is LandingSectionTarget
            ? settings.arguments! as LandingSectionTarget
            : null;
        return MaterialPageRoute<void>(
          settings: RouteSettings(
            name: '/',
            arguments: initialSection,
          ),
          builder: (_) => LandingPage(
            initialSection: initialSection,
            onPrivacyNoticeLaunch: widget.onPrivacyNoticeLaunch,
            landingRouteController: _landingRouteController,
          ),
        );
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) {
        synchronizeDocumentLanguage(Localizations.localeOf(context));
        return context.l10n.appTitle;
      },
      theme: appTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: _resolveLocaleList,
      onGenerateInitialRoutes: (initialRouteName) => [
        generateRoute(RouteSettings(name: initialRouteName)),
      ],
      onGenerateRoute: generateRoute,
    );
  }
}

const _legalPlaceholderRoutes = <String, LegalPlaceholderKind>{
  LegalPlaceholderPage.termsRouteName: LegalPlaceholderKind.terms,
  LegalPlaceholderPage.refundsRouteName: LegalPlaceholderKind.refunds,
  LegalPlaceholderPage.cookiesRouteName: LegalPlaceholderKind.cookies,
  LegalPlaceholderPage.cookieBannerRouteName: LegalPlaceholderKind.cookieBanner,
};

Locale _resolveLocaleList(
  List<Locale>? preferredLocales,
  Iterable<Locale> supportedLocales,
) {
  final browserLocales = preferredLocales ?? const <Locale>[];
  final hasSupportedLocale = browserLocales.any(
    AppLocalizations.delegate.isSupported,
  );

  return hasSupportedLocale
      ? basicLocaleListResolution(browserLocales, supportedLocales)
      : const Locale('en');
}
