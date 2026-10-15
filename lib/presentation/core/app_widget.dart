import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_route_dependencies.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_router.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/core/utils/document_language.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/founding_friend_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/here_and_now_page.dart';
import 'package:fun_app_landing_page/presentation/venue/pages/venue_page.dart';

/// Root widget for the Fun App landing-page application.
final class FunAppLandingPageApp extends StatefulWidget {
  /// Creates the root landing-page application widget.
  const FunAppLandingPageApp({
    this.onPrivacyNoticeLaunch,
    this.createVenueLeadFormBloc,
    this.createHereAndNowRegistrationFormBloc,
    this.createFoundingFriendRegistrationFormBloc,
    super.key,
  });

  /// Optional browser-launch override for presentation tests.
  final ValueChanged<Uri>? onPrivacyNoticeLaunch;

  /// Optional Venue form BLoC factory override for presentation tests.
  final VenueLeadFormBlocFactory? createVenueLeadFormBloc;

  /// Optional Here & Now BLoC factory override for presentation tests.
  final HereAndNowRegistrationFormBlocFactory?
  createHereAndNowRegistrationFormBloc;

  /// Optional Founding Friend BLoC factory override for presentation tests.
  final FoundingFriendRegistrationFormBlocFactory?
  createFoundingFriendRegistrationFormBloc;

  @override
  State<FunAppLandingPageApp> createState() => _FunAppLandingPageAppState();
}

final class _FunAppLandingPageAppState extends State<FunAppLandingPageApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
    _appRouter.routeInfoProvider(
      initialRouteInformation: RouteInformation(
        uri: Uri.parse(
          WidgetsBinding.instance.platformDispatcher.defaultRouteName,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) {
      synchronizeDocumentLanguage(Localizations.localeOf(context));
      return context.l10n.appTitle;
    },
    theme: appTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    localeListResolutionCallback: _resolveLocaleList,
    routerConfig: _appRouter.config(includePrefixMatches: false),
    builder: (context, child) => AppRouteDependencies(
      onPrivacyNoticeLaunch: widget.onPrivacyNoticeLaunch,
      createVenueLeadFormBloc: widget.createVenueLeadFormBloc,
      createHereAndNowRegistrationFormBloc:
          widget.createHereAndNowRegistrationFormBloc,
      createFoundingFriendRegistrationFormBloc:
          widget.createFoundingFriendRegistrationFormBloc,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

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
