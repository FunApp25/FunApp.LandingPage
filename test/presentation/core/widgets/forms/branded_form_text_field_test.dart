import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_text_field.dart';

void main() {
  for (final useValidator in [false, true]) {
    testWidgets('complete styled error with validator=$useValidator', (
      tester,
    ) async {
      final form = GlobalKey<FormState>();
      const message =
          'A complete validation message that needs more than '
          'three lines at narrow widths and enlarged text sizes.';
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: Form(
                key: form,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 256,
                    child: BrandedFormTextField(
                      fieldKey: const Key('field'),
                      label: 'Label',
                      semanticLabel: 'Label',
                      hint: '',
                      errorText: useValidator ? null : message,
                      validator: useValidator ? (_) => message : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      if (useValidator) {
        expect(form.currentState!.validate(), isFalse);
      }
      await tester.pumpAndSettle();
      final text = tester.widget<Text>(find.text(message));
      expect(text.style?.color, AppColors.cherryRed);
      expect(text.style?.fontSize, 12);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text(message),
      );
      expect(paragraph.maxLines, isNull);
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
