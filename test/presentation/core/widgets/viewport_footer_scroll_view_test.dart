import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/viewport_footer_scroll_view.dart';

import '../../landing/landing_test_helpers.dart';

void main() {
  testWidgets(
    'short content keeps the footer at every target viewport bottom',
    (
      tester,
    ) async {
      for (final width in const [320.0, 390.0, 599.0, 600.0, 768.0, 1440.0]) {
        setTestSurface(tester, Size(width, 900));
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ViewportFooterScrollView(
                scrollKey: Key('viewportScrollView'),
                content: SizedBox(
                  key: Key('shortContent'),
                  height: 80,
                ),
                footer: SizedBox(
                  key: Key('testFooter'),
                  height: 120,
                ),
              ),
            ),
          ),
        );

        final footerRect = tester.getRect(find.byKey(const Key('testFooter')));
        final contentRect = tester.getRect(
          find.byKey(const Key('shortContent')),
        );
        final scrollView = tester.widget<SingleChildScrollView>(
          find.byKey(const Key('viewportScrollView')),
        );

        expect(footerRect.bottom, 900);
        expect(contentRect.bottom, lessThanOrEqualTo(footerRect.top));
        expect(scrollView.controller?.position.maxScrollExtent ?? 0, 0);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('long content scrolls before a non-overlaying footer', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 600));
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ViewportFooterScrollView(
            scrollKey: const Key('viewportScrollView'),
            controller: controller,
            content: const SizedBox(
              key: Key('longContent'),
              height: 900,
            ),
            footer: const SizedBox(
              key: Key('testFooter'),
              height: 120,
            ),
          ),
        ),
      ),
    );

    expect(controller.position.maxScrollExtent, 420);
    expect(
      tester.getRect(find.byKey(const Key('longContent'))).bottom,
      tester.getRect(find.byKey(const Key('testFooter'))).top,
    );

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    expect(tester.getRect(find.byKey(const Key('testFooter'))).bottom, 600);
    expect(tester.takeException(), isNull);
  });
}
