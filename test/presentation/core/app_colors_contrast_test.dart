import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';

void main() {
  test('known landing text combinations meet their contrast targets', () {
    final problemText = Color.alphaBlend(
      AppTextStyles.landingProblemStatement.color!,
      AppColors.lightForeground,
    );

    expect(
      _contrastRatio(problemText, AppColors.lightForeground),
      greaterThanOrEqualTo(3),
    );
    expect(
      _contrastRatio(
        AppColors.warmOrangeLargeText,
        AppColors.beigeAccent,
      ),
      greaterThanOrEqualTo(3),
    );
    expect(
      _contrastRatio(AppColors.warmOrangeText, AppColors.beigeAccent),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.warmOrangeText, AppColors.lightForeground),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.textPrimary, AppColors.warmOrange),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('focus outline clears non-text contrast on light surfaces', () {
    expect(
      _contrastRatio(AppColors.energeticPlum, AppColors.lightForeground),
      greaterThanOrEqualTo(3),
    );
    expect(
      _contrastRatio(AppColors.energeticPlum, AppColors.beigeAccent),
      greaterThanOrEqualTo(3),
    );
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;

  return (lighter + 0.05) / (darker + 0.05);
}
