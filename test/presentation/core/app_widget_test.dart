import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/landing_page.dart';

void main() {
  testWidgets('renders the temporary landing page', (tester) async {
    await tester.pumpWidget(const FunAppLandingPageApp());

    expect(find.byType(LandingPage), findsOneWidget);
    expect(find.text(LandingPage.title), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, FunAppLandingPageApp.title);
    expect(app.debugShowCheckedModeBanner, isFalse);

    final pageContext = tester.element(find.byType(LandingPage));
    expect(Theme.of(pageContext).useMaterial3, isTrue);
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

      expect(find.text(LandingPage.title), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
