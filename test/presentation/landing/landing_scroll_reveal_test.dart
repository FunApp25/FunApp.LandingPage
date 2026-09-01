import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_scroll_reveal.dart';

import 'landing_test_helpers.dart';

void main() {
  testWidgets(
    'reveals at the viewport threshold once without changing layout',
    (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final controller = ScrollController();
      addTearDown(controller.dispose);
      setTestSurface(tester, const Size(800, 600));
      await _pumpReveal(tester, controller: controller, spacerHeight: 800);
      await tester.pump();

      final childSize = tester.getSize(find.byKey(const Key('revealChild')));
      expect(_revealOpacity(tester), 0.1);
      expect(find.bySemanticsLabel('Reveal content'), findsOneWidget);

      controller.jumpTo(350);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));

      expect(_revealOpacity(tester), greaterThan(0.1));
      expect(_revealOpacity(tester), lessThan(1));

      await tester.pumpAndSettle();

      expect(_revealOpacity(tester), 1);
      expect(tester.getSize(find.byKey(const Key('revealChild'))), childSize);
      expect(tester.binding.hasScheduledFrame, isFalse);

      controller.jumpTo(0);
      await tester.pump();
      controller.jumpTo(350);
      await tester.pump();

      expect(_revealOpacity(tester), 1);
      semantics.dispose();
    },
  );

  testWidgets('initial layout check reveals content already in the viewport', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    setTestSurface(tester, const Size(800, 600));
    await _pumpReveal(tester, controller: controller, spacerHeight: 100);

    expect(_revealOpacity(tester), 0.1);

    await tester.pump();
    await tester.pumpAndSettle();

    expect(_revealOpacity(tester), 1);
  });

  testWidgets('an unrevealed surface rechecks after viewport resize', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    setTestSurface(tester, const Size(800, 400));
    await _pumpReveal(tester, controller: controller, spacerHeight: 350);
    await tester.pump();

    expect(_revealOpacity(tester), 0.1);

    tester.view.physicalSize = const Size(800, 600);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(_revealOpacity(tester), 1);
  });

  testWidgets('reduced motion renders final state without an animation', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    setTestSurface(tester, const Size(800, 600));
    await _pumpReveal(
      tester,
      controller: controller,
      spacerHeight: 800,
      disableAnimations: true,
    );

    expect(_revealOpacity(tester), 1);
    expect(
      find.descendant(
        of: find.byType(LandingScrollReveal),
        matching: find.byType(TweenAnimationBuilder<double>),
      ),
      findsNothing,
    );
  });
}

Future<void> _pumpReveal(
  WidgetTester tester, {
  required ScrollController controller,
  required double spacerHeight,
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              SizedBox(height: spacerHeight),
              LandingScrollReveal(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (context, progress, child) => Opacity(
                  key: const Key('revealOpacity'),
                  opacity: 0.1 + (0.9 * progress),
                  alwaysIncludeSemantics: true,
                  child: child,
                ),
                child: const SizedBox(
                  key: Key('revealChild'),
                  height: 200,
                  child: Text('Reveal content'),
                ),
              ),
              const SizedBox(height: 800),
            ],
          ),
        ),
      ),
    ),
  );
}

double _revealOpacity(WidgetTester tester) =>
    tester.widget<Opacity>(find.byKey(const Key('revealOpacity'))).opacity;
