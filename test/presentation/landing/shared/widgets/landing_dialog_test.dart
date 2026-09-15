import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_dialog.dart';

import '../../landing_test_helpers.dart';

void main() {
  testWidgets('scrolls tall supplied content inside a bounded dialog', (
    tester,
  ) async {
    setTestSurface(tester, const Size(320, 300));
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              key: const Key('openLandingDialog'),
              onPressed: () => showLandingDialog<void>(
                context: context,
                semanticLabel: 'Example dialog',
                closeTooltip: 'Close',
                builder: (context) => const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Example content'),
                    SizedBox(height: 600),
                    Text('End of content'),
                  ],
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('openLandingDialog')));
    await tester.pumpAndSettle();

    final dialogRect = tester.getRect(
      find.byKey(const Key('landingDialogSurface')),
    );
    expect(dialogRect.left, greaterThanOrEqualTo(16));
    expect(dialogRect.right, lessThanOrEqualTo(304));
    expect(find.text('Example content'), findsOneWidget);
    expect(find.text('End of content'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('landingDialogScrollView')),
      const Offset(0, -180),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('landingDialogCloseButton')));
    await tester.pumpAndSettle();
    expect(find.byType(LandingDialog), findsNothing);
  });
}
