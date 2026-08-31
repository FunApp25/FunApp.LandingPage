// Google Fonts styles are runtime-built shared tokens, so this file keeps the
// established static theme-token shape used by the Fun App presentation layer.
// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Generic text styles and font factories for the Fun App visual language.
abstract final class AppTextStyles {
  /// Body and UI font family.
  static const String bodyFontFamily = 'Manrope';

  /// Established display and headline font family.
  static const String headlineFontFamily = 'InstrumentSerif';

  /// Title style used for prominent title hierarchy.
  static final TextStyle titleLarge = headlineFontStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Headline style for prominent page-level messaging.
  static final TextStyle headlineSmall = headlineFontStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Headline style for emphasized page-level messaging.
  static final TextStyle headlineMedium = headlineFontStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Headline style for the largest page-level messaging.
  static final TextStyle headlineLarge = headlineFontStyle(
    fontSize: 54,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Primary body style for standard reading content.
  static final TextStyle bodyLarge = bodyFontStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// Default body style for compact reading content and inputs.
  static final TextStyle bodyMedium = bodyFontStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// Small body style for hints and supporting copy.
  static final TextStyle bodySmall = bodyFontStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Supporting label style for secondary metadata.
  static final TextStyle labelLarge = bodyFontStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  /// Label style for smaller controls and input labels.
  static final TextStyle labelMedium = bodyFontStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  /// Shared text theme composed from the generic application tokens.
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

  /// Builds a Manrope style using the repository's test-safe font behavior.
  static TextStyle bodyFontStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required Color color,
    double? letterSpacing,
    FontStyle? fontStyle,
    List<FontFeature>? fontFeatures,
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
        fontFeatures: fontFeatures,
        color: color,
      );
    }
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: fontFeatures,
      color: color,
    );
  }

  /// Builds an Instrument Serif style with the same test-safe behavior.
  static TextStyle headlineFontStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required Color color,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    if (_usesTestFontFallback) {
      return TextStyle(
        fontFamily: headlineFontFamily,
        fontFamilyFallback: const [headlineFontFamily],
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
    return GoogleFonts.instrumentSerif(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // Runtime Google Fonts fetching is intentionally unchanged in this cleanup.
  // Tests use deterministic family names without triggering network requests.
  static bool get _usesTestFontFallback {
    try {
      return WidgetsBinding.instance.runtimeType.toString().contains('Test');
    } on Object {
      return true;
    }
  }
}
