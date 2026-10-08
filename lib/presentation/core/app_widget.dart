import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/core/utils/document_language.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_section_target.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/privacy/pages/privacy_notice_page.dart';
import 'package:fun_app_landing_page/presentation/venue/pages/venue_page.dart';

/// Root widget for the Fun App landing-page application.
final class FunAppLandingPageApp extends StatelessWidget {
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
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) {
      synchronizeDocumentLanguage(Localizations.localeOf(context));
      return context.l10n.appTitle;
    },
    theme: appTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    localeListResolutionCallback: _resolveLocaleList,
    onGenerateRoute: (settings) {
      if (settings.name == PrivacyNoticePage.routeName) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const PrivacyNoticePage(),
        );
      } else if (settings.name == VenuePage.routeName) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => VenuePage(
            createBloc: createVenueLeadFormBloc,
            onPrivacyNoticeLaunch: onPrivacyNoticeLaunch,
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
            onPrivacyNoticeLaunch: onPrivacyNoticeLaunch,
          ),
        );
      }
    },
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
