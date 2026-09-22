import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_mobile_carousel.dart';

import '../../landing_test_helpers.dart';

void main() {
  testWidgets('supports a section-independent three-item carousel', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 600));
    await _pumpCarousel(tester);

    expect(_pageLabel(tester), 'Item 1 of 3');
    await tester.tap(find.byKey(const Key('landingCarouselNext')));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Item 2 of 3');
    expect(find.text('Item 2').hitTestable(), findsOneWidget);

    await tester.tap(find.byKey(const Key('landingCarouselPrevious')));
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Item 1 of 3');
  });

  testWidgets('arrow shortcuts are scoped to focused carousel controls', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 600));
    await _pumpCarousel(tester);

    final outside = find.byKey(const Key('outsideControl'));
    await tester.tap(outside);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Item 1 of 3');

    await tester.tap(find.byKey(const Key('landingCarouselNext')));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Item 3 of 3');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(_pageLabel(tester), 'Item 3 of 3');
  });

  testWidgets('rebuilds page geometry without losing the settled page', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 600));
    await _pumpCarousel(tester);

    await tester.tap(find.byKey(const Key('landingCarouselNext')));
    await tester.pumpAndSettle();
    final originalController = tester
        .widget<PageView>(find.byType(PageView))
        .controller;

    tester.view.physicalSize = const Size(320, 600);
    await tester.pump();
    await tester.pump();
    final resizedController = tester
        .widget<PageView>(find.byType(PageView))
        .controller;

    expect(resizedController, isNot(same(originalController)));
    expect(_pageLabel(tester), 'Item 2 of 3');
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpCarousel(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            TextButton(
              key: const Key('outsideControl'),
              onPressed: () {},
              child: const Text('Outside'),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final viewportWidth = constraints.maxWidth - 16;
                final cardWidth = constraints.maxWidth - 32;

                return Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: viewportWidth,
                    child: LandingMobileCarousel(
                      itemCount: 3,
                      viewportFraction: (cardWidth + 8) / viewportWidth,
                      pageHeight: 160,
                      itemGap: 8,
                      previousSemanticLabel: 'Previous item',
                      nextSemanticLabel: 'Next item',
                      pageSemanticLabelBuilder: (page, count) =>
                          'Item $page of $count',
                      itemBuilder: (context, index) => ColoredBox(
                        color: Colors.white,
                        child: Center(child: Text('Item ${index + 1}')),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
}

String _pageLabel(WidgetTester tester) => tester
    .getSemantics(
      find.byKey(const Key('landingCarouselCurrentPageSemantics')),
    )
    .getSemanticsData()
    .label;
