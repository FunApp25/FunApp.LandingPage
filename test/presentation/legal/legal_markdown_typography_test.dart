import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_document_page.dart';

import '../landing/landing_test_helpers.dart';

void main() {
  for (final width in [320.0, 390.0, 900.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('legal heading hierarchy and lists at $width, ${scale}x', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        setTestSurface(tester, Size(width, 1000));
        const source =
            '## 4. Partner Venue Rules\n\n'
            'Body paragraph.\n\n### 4.3. Misuse of Offers\n\n'
            '- First bullet\n- Second bullet\n\n'
            '3. Third item\n4. Fourth item\n\nNext paragraph.';
        await tester.pumpWidget(
          MaterialApp(
            theme: appTheme,
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 1000),
                textScaler: TextScaler.linear(scale),
              ),
              child: const Scaffold(
                body: SingleChildScrollView(
                  child: LegalMarkdownDocument(
                    markdownData: source,
                    markdownKey: Key('markdown'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
        expect(markdown.data, source);
        final styles = markdown.styleSheet!;
        expect(styles.h2!.fontFamily, AppTextStyles.headlineFontFamily);
        expect(styles.h3!.fontFamily, AppTextStyles.headlineFontFamily);
        expect(styles.h2!.fontSize, greaterThan(styles.h3!.fontSize!));
        expect(styles.p!.fontFamily, AppTextStyles.bodyFontFamily);
        expect(styles.p!.fontSize, 16);
        expect(styles.p!.height, 1.65);
        expect(styles.pPadding!.bottom, 8);
        expect(styles.blockSpacing, 12);
        for (final (level, label) in [
          (2, '4. Partner Venue Rules'),
          (3, '4.3. Misuse of Offers'),
        ]) {
          final text = find.byWidgetPredicate(
            (widget) =>
                widget is Text && widget.textSpan?.toPlainText() == label,
          );
          expect(text, findsOneWidget);
          expect(
            tester.getSemantics(text).getSemanticsData().headingLevel,
            level,
          );
          final heading = tester.widget<Text>(text);
          expect(heading.style!.fontFamily, AppTextStyles.headlineFontFamily);
        }
        expect(find.text('•', findRichText: true), findsNWidgets(2));
        expect(find.text('3.', findRichText: true), findsOneWidget);
        expect(find.text('4.', findRichText: true), findsOneWidget);
        for (final label in [
          'First bullet',
          'Second bullet',
          'Third item',
          'Fourth item',
          'Body paragraph.',
          'Next paragraph.',
        ]) {
          expect(find.text(label, findRichText: true), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        semantics.dispose();
      });
    }
  }
}
