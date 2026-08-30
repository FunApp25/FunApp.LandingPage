import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/core/utils/document_language.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';

/// Root widget for the Fun App landing-page application.
final class FunAppLandingPageApp extends StatelessWidget {
  /// Creates the root landing-page application widget.
  const FunAppLandingPageApp({super.key});

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
    home: const LandingPage(),
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
