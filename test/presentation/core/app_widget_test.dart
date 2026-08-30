import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';

void main() {
  testWidgets('renders the English branded landing page', (tester) async {
    await _pumpApp(tester, const Locale('en'));

    expect(find.byType(LandingPage), findsOneWidget);
    expect(find.byType(FunAppLogo), findsNWidgets(2));
    expect(find.byType(SvgPicture), findsNWidgets(15));
    expect(find.bySemanticsLabel('Fun App'), findsNWidgets(2));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final pageContext = tester.element(find.byType(LandingPage));
    final l10n = AppLocalizations.of(pageContext);
    _expectLocalizedTitle(tester, 'Fun App Landing Page');
    expect(app.debugShowCheckedModeBanner, isFalse);
    expect(app.locale, isNull);
    expect(app.localeListResolutionCallback, isNotNull);
    expect(
      app.localizationsDelegates,
      AppLocalizations.localizationsDelegates,
    );
    expect(app.supportedLocales, AppLocalizations.supportedLocales);
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
      unorderedEquals(<String>['en', 'es', 'cy', 'be']),
    );
    expect(l10n.brandName, 'Fun App');

    final theme = Theme.of(pageContext);
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.colorScheme.secondary, AppColors.yellowAccent);
    expect(theme.colorScheme.surface, AppColors.lightForeground);
    expect(
      theme.colorScheme.surfaceContainerHighest,
      AppColors.beigeAccent,
    );
    expect(theme.colorScheme.onSurfaceVariant, AppColors.bodyGray);
    expect(theme.scaffoldBackgroundColor, AppColors.scaffoldBackground);
    expect(theme.textTheme.bodyMedium?.color, AppColors.bodyGray);

    final logo = tester.widget<SvgPicture>(
      find.byKey(const Key('funAppLogo')),
    );
    expect(logo.key, const Key('funAppLogo'));
    expect(logo.bytesLoader, isA<SvgAssetLoader>());
    expect(
      (logo.bytesLoader as SvgAssetLoader).assetName,
      AppAssets.funAppLogoV2,
    );
  });

  testWidgets('resolves Spanish localization', (tester) async {
    await _pumpApp(tester, const Locale('es'));

    final context = tester.element(find.byType(LandingPage));
    _expectLocalizedTitle(tester, 'Página de destino de Fun App');
    expect(Localizations.localeOf(context), const Locale('es'));
  });

  testWidgets('resolves Welsh localization', (tester) async {
    await _pumpApp(tester, const Locale('cy'));

    final context = tester.element(find.byType(LandingPage));
    _expectLocalizedTitle(tester, 'Tudalen lanio Fun App');
    expect(Localizations.localeOf(context), const Locale('cy'));
  });

  testWidgets('resolves Belarusian localization', (tester) async {
    await _pumpApp(tester, const Locale('be'));

    final context = tester.element(find.byType(LandingPage));
    _expectLocalizedTitle(tester, 'Мэтавая старонка Fun App');
    expect(Localizations.localeOf(context), const Locale('be'));
  });

  testWidgets('falls back to English for an unsupported locale', (
    tester,
  ) async {
    await _pumpApp(tester, const Locale('fr'));

    final context = tester.element(find.byType(LandingPage));
    _expectLocalizedTitle(tester, 'Fun App Landing Page');
    expect(Localizations.localeOf(context), const Locale('en'));
  });
}

Future<void> _pumpApp(WidgetTester tester, Locale locale) async {
  tester.binding.platformDispatcher.localesTestValue = <Locale>[locale];
  addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(const FunAppLandingPageApp());
  await tester.pump();
}

void _expectLocalizedTitle(WidgetTester tester, String expectedTitle) {
  final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
  final context = tester.element(find.byType(LandingPage));

  expect(AppLocalizations.of(context).appTitle, expectedTitle);
  expect(app.onGenerateTitle?.call(context), expectedTitle);
}
