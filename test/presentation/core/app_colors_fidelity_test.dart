import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_cta_button.dart';

void main() {
  test('landing text styles retain the approved Figma colors', () {
    expect(AppColors.warmOrange, const Color(0xFFEF6632));
    expect(
      LandingTextStyles.problemStatement.color,
      AppColors.blueMain.withValues(alpha: 0.4),
    );
    expect(
      LandingTextStyles.heroHeadlineEmphasis.color,
      AppColors.warmOrange,
    );
    expect(
      LandingTextStyles.statsAttributionSource.color,
      AppColors.warmOrange,
    );
    expect(
      LandingTextStyles.statsAttributionSource.decorationColor,
      AppColors.warmOrange,
    );
  });

  testWidgets('orange CTA uses the Figma orange and white relationship', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: LandingCtaButton(
            label: 'Join Waitlist',
            size: LandingCtaSize.prominent,
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(LandingCtaButton),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final label = tester.widget<Text>(find.text('Join Waitlist'));

    expect(decoration.color, AppColors.warmOrange);
    expect(label.style?.color, AppColors.lightForeground);
  });

  test('strengthened focus outline remains part of the Figma palette', () {
    expect(AppColors.energeticPlum, const Color(0xFF63328D));
  });
}
