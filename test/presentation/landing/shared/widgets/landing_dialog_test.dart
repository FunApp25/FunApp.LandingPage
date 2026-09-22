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

    expect(find.byType(ScaleTransition), findsWidgets);
    expect(find.byKey(const Key('landingDialogTopFade')), findsNothing);

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
    expect(find.byKey(const Key('landingDialogTopFade')), findsOneWidget);
    expect(find.text('End of content'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('landingDialogCloseButton')));
    await tester.pumpAndSettle();
    expect(find.byType(LandingDialog), findsNothing);
  });

  testWidgets('reduced animation still opens and closes the shared dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showLandingDialog<void>(
                  context: context,
                  semanticLabel: 'Example dialog',
                  closeTooltip: 'Close',
                  builder: (_) => const Text('Dialog body'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog body'), findsOneWidget);
    await tester.tap(find.byKey(const Key('landingDialogCloseButton')));
    await tester.pumpAndSettle();
    expect(find.text('Dialog body'), findsNothing);
  });

  testWidgets(
    'footer edge fades follow scroll extent without blocking action',
    (
      tester,
    ) async {
      setTestSurface(tester, const Size(320, 300));
      var footerTaps = 0;
      var showLongContent = false;
      late StateSetter updateDialog;
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showLandingDialogRoute<void>(
                  context: context,
                  barrierLabel: 'Close',
                  builder: (dialogContext) => StatefulBuilder(
                    builder: (context, setState) {
                      updateDialog = setState;
                      return LandingDialog(
                        semanticLabel: 'Example dialog',
                        closeTooltip: 'Close',
                        onClose: () => Navigator.of(dialogContext).pop(),
                        footer: FilledButton(
                          key: const Key('examplePinnedAction'),
                          onPressed: () => footerTaps++,
                          child: const Text('Action'),
                        ),
                        child: showLongContent
                            ? const Column(
                                children: [
                                  Text('Beginning'),
                                  SizedBox(height: 600),
                                  Text('End of content'),
                                ],
                              )
                            : const Text('Short content'),
                      );
                    },
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('landingDialogTopFade')), findsNothing);
      expect(find.byKey(const Key('landingDialogBottomFade')), findsNothing);

      updateDialog(() => showLongContent = true);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('landingDialogTopFade')), findsNothing);
      final bottomFade = find.byKey(const Key('landingDialogBottomFade'));
      expect(bottomFade, findsOneWidget);
      expect(
        tester
            .widgetList<IgnorePointer>(
              find.ancestor(
                of: bottomFade,
                matching: find.byType(IgnorePointer),
              ),
            )
            .any((widget) => widget.ignoring),
        isTrue,
      );

      final scroll = find.byKey(const Key('landingDialogScrollView'));
      await tester.drag(scroll, const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('landingDialogTopFade')), findsOneWidget);
      expect(bottomFade, findsOneWidget);
      await tester.drag(scroll, const Offset(0, -1000));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('landingDialogTopFade')), findsOneWidget);
      expect(bottomFade, findsNothing);
      expect(find.text('End of content'), findsOneWidget);

      await tester.tap(find.byKey(const Key('examplePinnedAction')));
      expect(footerTaps, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
