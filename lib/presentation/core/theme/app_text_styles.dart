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

  /// Shared eyebrow label used by implemented landing-page sections.
  static final TextStyle landingSectionEyebrow = _manrope(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 20 / 12,
    letterSpacing: 0.96,
    color: AppColors.textPrimary,
  );

  /// Centered research statement from Figma node `2190:1581`.
  static final TextStyle landingProblemStatement = _instrumentSerif(
    fontSize: 50,
    fontWeight: FontWeight.w400,
    height: 60 / 50,
    letterSpacing: -0.5,
    color: AppColors.blueMain.withValues(alpha: 0.4),
  );

  /// Italic emphasis within the research statement.
  static final TextStyle landingProblemStatementEmphasis = _instrumentSerif(
    fontSize: 50,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 60 / 50,
    letterSpacing: -0.5,
    color: AppColors.blueMain,
  );

  /// Shared section heading from Figma nodes `2190:1587` and `2190:1596`.
  static final TextStyle landingSectionHeading = _instrumentSerif(
    fontSize: 44,
    fontWeight: FontWeight.w400,
    height: 54 / 44,
    letterSpacing: -0.44,
    color: AppColors.textPrimary,
  );

  /// Italic orange emphasis within a standard landing section heading.
  static final TextStyle landingSectionHeadingEmphasis = _instrumentSerif(
    fontSize: 44,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 54 / 44,
    letterSpacing: -0.44,
    color: AppColors.warmOrange,
  );

  /// Research attribution treatment from Figma node `2190:1587`.
  static final TextStyle landingStatsAttribution = _manrope(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 26 / 16,
    letterSpacing: 0.32,
    color: AppColors.bodyGray,
  );

  /// Highlighted research-source treatment from Figma node `2190:1587`.
  static final TextStyle landingStatsAttributionSource =
      _manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 26 / 16,
        letterSpacing: 0.32,
        color: AppColors.warmOrange,
      ).copyWith(
        decoration: TextDecoration.underline,
        decorationColor: AppColors.warmOrange,
        decorationThickness: 0.8,
      );

  /// Separators between the visual research-source labels.
  static final TextStyle landingStatsAttributionSeparator = _manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 26 / 16,
    letterSpacing: 0.32,
    color: AppColors.bodyGray,
  );

  /// Percentage treatment used by the research statistic cards.
  static final TextStyle landingStatValue = _manrope(
    fontSize: 64,
    fontWeight: FontWeight.w600,
    height: 72 / 64,
    color: AppColors.textPrimary,
    fontFeatures: const [
      FontFeature.liningFigures(),
      FontFeature.tabularFigures(),
    ],
  );

  /// Supporting copy used by the research statistic cards.
  static final TextStyle landingStatBody = _manrope(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 26 / 18,
    letterSpacing: 0.36,
    color: AppColors.bodyGray,
  );

  /// Explanatory body copy from Figma node `2190:1596`.
  static final TextStyle landingSectionBody = _manrope(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 28 / 18,
    letterSpacing: 0.36,
    color: AppColors.bodyGray,
  );

  /// Membership-card tier title from Figma node `2190:1610`.
  static final TextStyle landingMembershipCardTitle = _instrumentSerif(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 40 / 32,
    letterSpacing: -0.32,
    color: AppColors.lightForeground,
  );

  /// Membership-card price from Figma node `2190:1610`.
  static final TextStyle landingMembershipPrice = _manrope(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 50 / 40,
    letterSpacing: -0.4,
    color: AppColors.lightForeground,
    fontFeatures: const [
      FontFeature.liningFigures(),
      FontFeature.tabularFigures(),
    ],
  );

  /// Membership-card billing period from Figma node `2190:1610`.
  static final TextStyle landingMembershipPriceUnit = _manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22 / 14,
    letterSpacing: 0.28,
    color: AppColors.lightForeground,
  );

  /// Membership-card description and supporting text.
  static final TextStyle landingMembershipCardBody = _manrope(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 26 / 16,
    letterSpacing: 0.32,
    color: AppColors.lightForeground,
  );

  /// Visual, intentionally unwired membership-card link treatment.
  static final TextStyle landingMembershipCardLink =
      _manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 22 / 14,
        letterSpacing: 1.12,
        color: AppColors.yellowAccent,
      ).copyWith(
        decoration: TextDecoration.underline,
        decorationColor: AppColors.blueMain.withValues(alpha: 0.3),
        decorationThickness: 1.12,
      );

  /// Centered limited-time-offer statement from Figma node `2190:1613`.
  static final TextStyle landingFoundingOfferStatement = _instrumentSerif(
    fontSize: 50,
    fontWeight: FontWeight.w400,
    height: 60 / 50,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Italic emphasis within the limited-time offer statement.
  static final TextStyle landingFoundingOfferStatementEmphasis =
      _instrumentSerif(
        fontSize: 50,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 60 / 50,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  /// Contact-address treatment from Figma footer node `2190:1664`.
  static final TextStyle landingFooterEmail =
      _manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 24 / 16,
        letterSpacing: 0.32,
        color: AppColors.blueMain,
      ).copyWith(
        decoration: TextDecoration.underline,
        decorationColor: AppColors.blueMain.withValues(alpha: 0.3),
        decorationThickness: 1.28,
      );

  /// FAQ question treatment from Figma node `2190:1644`.
  static final TextStyle landingFaqQuestion = _instrumentSerif(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 40 / 32,
    letterSpacing: -0.32,
    color: AppColors.textPrimary,
  );

  /// FAQ answer treatment from Figma node `2190:1644`.
  static final TextStyle landingFaqAnswer = _manrope(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    letterSpacing: 0.32,
    color: AppColors.bodyGray,
  );

  /// Approved emphasis within selected FAQ answers.
  static final TextStyle landingFaqAnswerEmphasis = _manrope(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
    letterSpacing: 0.32,
    color: AppColors.bodyGray,
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
    } else {
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
