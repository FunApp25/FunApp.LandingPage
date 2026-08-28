import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing_page.dart';

void main() {
  testWidgets('renders the branded temporary landing page', (tester) async {
    await tester.pumpWidget(const FunAppLandingPageApp());
    await tester.pump();

    expect(find.byType(LandingPage), findsOneWidget);
    expect(find.byType(FunAppLogo), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(
      find.bySemanticsLabel(LandingPage.brandSemanticLabel),
      findsOneWidget,
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, FunAppLandingPageApp.title);
    expect(app.debugShowCheckedModeBanner, isFalse);

    final pageContext = tester.element(find.byType(LandingPage));
    final theme = Theme.of(pageContext);
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.scaffoldBackgroundColor, AppColors.scaffoldBackground);

    final logo = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(logo.key, const Key('funAppLogo'));
    expect(logo.bytesLoader, isA<SvgAssetLoader>());
    expect(
      (logo.bytesLoader as SvgAssetLoader).assetName,
      AppAssets.funAppWordmarkBlack,
    );
  });

  testWidgets('renders without errors at narrow and wide sizes', (
    tester,
  ) async {
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.devicePixelRatio = 1;

    for (final size in [const Size(320, 568), const Size(1440, 900)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const FunAppLandingPageApp());
      await tester.pump();

      expect(find.byType(FunAppLogo), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
