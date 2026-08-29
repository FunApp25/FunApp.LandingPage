// Google Fonts styles are runtime-built shared tokens, so this file keeps the
// established static theme-token shape used by the Fun App presentation layer.
// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared text style tokens for the Fun App visual language.
abstract final class AppTextStyles {
  /// Body and UI font family.
  static const String bodyFontFamily = 'Manrope';

  /// Temporary Google Fonts headline family inherited from the main app.
  static const String temporaryHeadlineFontFamily = 'InstrumentSerif';

  /// Title style used for prominent title hierarchy.
  static final TextStyle titleLarge = _instrumentSerif(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Headline style for prominent page-level messaging.
  static final TextStyle headlineSmall = _instrumentSerif(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Headline style for emphasized page-level messaging.
  static final TextStyle headlineMedium = _instrumentSerif(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Headline style for the largest page-level messaging.
  static final TextStyle headlineLarge = _instrumentSerif(
    fontSize: 54,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Primary body style for standard reading content.
  static final TextStyle bodyLarge = _manrope(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// Default body style for compact reading content and inputs.
  static final TextStyle bodyMedium = _manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// Small body style for hints and supporting copy.
  static final TextStyle bodySmall = _manrope(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Supporting label style for secondary metadata.
  static final TextStyle labelLarge = _manrope(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  /// Label style for smaller controls and input labels.
  static final TextStyle labelMedium = _manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  /// Navigation label style from Figma header node `2190:1568`.
  static final TextStyle landingHeaderNavigation = _manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 20 / 12,
    letterSpacing: 0.96,
    color: AppColors.textPrimary,
  );

  /// Compact call-to-action label from Figma header node `2190:1568`.
  static final TextStyle landingHeaderCta = _manrope(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 22 / 14,
    color: AppColors.lightForeground,
  );

  /// Eyebrow label from Figma hero node `2190:1569`.
  static final TextStyle landingHeroEyebrow = _manrope(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 20 / 12,
    letterSpacing: 0.96,
    color: AppColors.blueMain,
  );

  /// Regular display treatment from Figma hero node `2190:1569`.
  static final TextStyle landingHeroHeadline = _instrumentSerif(
    fontSize: 60,
    fontWeight: FontWeight.w400,
    height: 70 / 60,
    letterSpacing: -1.8,
    color: AppColors.textPrimary,
  );

  /// Italic orange emphasis from Figma hero node `2190:1569`.
  static final TextStyle landingHeroHeadlineEmphasis = _instrumentSerif(
    fontSize: 60,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 70 / 60,
    letterSpacing: -1.8,
    color: AppColors.warmOrange,
  );

  /// Supporting copy treatment from Figma hero node `2190:1569`.
  static final TextStyle landingHeroSupporting = _manrope(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 28 / 20,
    letterSpacing: 0.4,
    color: AppColors.bodyGray,
  );

  /// Prominent call-to-action label from Figma hero node `2190:1569`.
  static final TextStyle landingHeroCta = _manrope(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
    color: AppColors.lightForeground,
  );

  /// Shared text theme composed from the active baseline tokens.
  static final TextTheme textTheme = TextTheme(
    titleLarge: titleLarge,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
  );

  static TextStyle _manrope({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required Color color,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    if (_usesTestFontFallback) {
      return TextStyle(
        fontFamily: bodyFontFamily,
        fontFamilyFallback: const [bodyFontFamily],
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    } else {
      return GoogleFonts.manrope(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
  }

  static TextStyle _instrumentSerif({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required Color color,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    if (_usesTestFontFallback) {
      return TextStyle(
        fontFamily: temporaryHeadlineFontFamily,
        fontFamilyFallback: const [temporaryHeadlineFontFamily],
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    } else {
      return GoogleFonts.instrumentSerif(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
  }

  static bool get _usesTestFontFallback {
    try {
      return WidgetsBinding.instance.runtimeType.toString().contains('Test');
    } on Object {
      return true;
    }
  }
}
