// Landing styles are runtime-built shared tokens.
// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';

/// Text styles specific to the Figma landing-page presentation.
abstract final class LandingTextStyles {
  /// Navigation label style from the landing header.
  static final TextStyle headerNavigation = AppTextStyles.bodyFontStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 20 / 12,
    letterSpacing: 0.96,
    color: AppColors.textPrimary,
  );

  /// Compact call-to-action label from the landing header.
  static final TextStyle headerCta = AppTextStyles.bodyFontStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 22 / 14,
    color: AppColors.lightForeground,
  );

  /// Regular display treatment from the Hero.
  static final TextStyle heroHeadline = AppTextStyles.headlineFontStyle(
    fontSize: 60,
    fontWeight: FontWeight.w400,
    height: 70 / 60,
    letterSpacing: -1.8,
    color: AppColors.textPrimary,
  );

  /// Italic orange emphasis used by the Hero headline.
  static final TextStyle heroHeadlineEmphasis = AppTextStyles.headlineFontStyle(
    fontSize: 60,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 70 / 60,
    letterSpacing: -1.8,
    color: AppColors.warmOrange,
  );

  /// Supporting Hero copy.
  static final TextStyle heroSupporting = AppTextStyles.bodyFontStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 26 / 18,
    letterSpacing: 0.36,
    color: AppColors.bodyGray,
  );

  /// Prominent landing-page call-to-action label.
  static final TextStyle heroCta = AppTextStyles.bodyFontStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
    color: AppColors.lightForeground,
  );

  /// Shared landing-page eyebrow label.
  static final TextStyle sectionEyebrow = AppTextStyles.bodyFontStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 20 / 12,
    letterSpacing: 0.96,
    color: AppColors.textPrimary,
  );

  /// Regular Problem Statement text.
  static final TextStyle problemStatement = AppTextStyles.headlineFontStyle(
    fontSize: 50,
    fontWeight: FontWeight.w400,
    height: 60 / 50,
    letterSpacing: -0.5,
    color: AppColors.blueMain.withValues(alpha: 0.4),
  );

  /// Italic emphasis within the Problem Statement.
  static final TextStyle problemStatementEmphasis =
      AppTextStyles.headlineFontStyle(
        fontSize: 50,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 60 / 50,
        letterSpacing: -0.5,
        color: AppColors.blueMain,
      );

  /// Shared landing-page section heading.
  static final TextStyle sectionHeading = AppTextStyles.headlineFontStyle(
    fontSize: 44,
    fontWeight: FontWeight.w400,
    height: 54 / 44,
    letterSpacing: -0.44,
    color: AppColors.textPrimary,
  );

  /// Italic orange emphasis within a section heading.
  static final TextStyle sectionHeadingEmphasis =
      AppTextStyles.headlineFontStyle(
        fontSize: 44,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 54 / 44,
        letterSpacing: -0.44,
        color: AppColors.warmOrange,
      );

  /// Research attribution and related supporting copy.
  static final TextStyle statsAttribution = AppTextStyles.bodyFontStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 26 / 16,
    letterSpacing: 0.32,
    color: AppColors.bodyGray,
  );

  /// Underlined research-source treatment.
  static final TextStyle statsAttributionSource =
      AppTextStyles.bodyFontStyle(
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

  /// Separator treatment between visual research sources.
  static final TextStyle statsAttributionSeparator =
      AppTextStyles.bodyFontStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 26 / 16,
        letterSpacing: 0.32,
        color: AppColors.bodyGray,
      );

  /// Percentage treatment used by research statistic cards.
  static final TextStyle statValue = AppTextStyles.bodyFontStyle(
    fontSize: 64,
    fontWeight: FontWeight.w600,
    height: 72 / 64,
    color: AppColors.textPrimary,
    fontFeatures: const [
      FontFeature.liningFigures(),
      FontFeature.tabularFigures(),
    ],
  );

  /// Supporting copy used by research and promotional cards.
  static final TextStyle statBody = AppTextStyles.bodyFontStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 26 / 18,
    letterSpacing: 0.36,
    color: AppColors.bodyGray,
  );

  /// Explanatory body copy used by landing sections.
  static final TextStyle sectionBody = AppTextStyles.bodyFontStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 28 / 18,
    letterSpacing: 0.36,
    color: AppColors.bodyGray,
  );

  /// Membership-card eyebrow label.
  static final TextStyle membershipCardEyebrow = AppTextStyles.bodyFontStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 20 / 12,
    letterSpacing: 0.96,
    color: AppColors.textPrimary,
  );

  /// Membership-card price.
  static final TextStyle membershipPrice = AppTextStyles.bodyFontStyle(
    fontSize: 50,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    fontFeatures: const [
      FontFeature.liningFigures(),
      FontFeature.tabularFigures(),
    ],
  );

  /// Membership-card billing period.
  static final TextStyle membershipPriceUnit = AppTextStyles.bodyFontStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 22 / 14,
    letterSpacing: 0.28,
    color: AppColors.textPrimary,
  );

  /// Membership-card body copy.
  static final TextStyle membershipCardBody = AppTextStyles.bodyFontStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    letterSpacing: 0.32,
    color: AppColors.textPrimary,
  );

  /// Emphasized first benefit on paid membership cards.
  static final TextStyle membershipCardBenefitEmphasis =
      AppTextStyles.bodyFontStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 24 / 16,
        letterSpacing: 0.32,
        color: AppColors.textPrimary,
      );

  /// Fine print beneath membership-card calls to action.
  static final TextStyle membershipFootnote = AppTextStyles.bodyFontStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 20 / 12,
    letterSpacing: 0.24,
    color: AppColors.textPrimary.withValues(alpha: 0.6),
  );

  /// Founding Member benefit-card title.
  static final TextStyle foundingMemberCardTitle =
      AppTextStyles.headlineFontStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 40 / 32,
        letterSpacing: -0.32,
        color: AppColors.textPrimary,
      );

  /// Compact explanatory copy used by the current Figma cards and Venue intro.
  static final TextStyle compactSectionBody = AppTextStyles.bodyFontStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    letterSpacing: 0.32,
    color: AppColors.bodyGray,
  );

  /// Regular large statement treatment.
  static final TextStyle foundingOfferStatement =
      AppTextStyles.headlineFontStyle(
        fontSize: 50,
        fontWeight: FontWeight.w400,
        height: 60 / 50,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  /// Italic emphasis within a large statement.
  static final TextStyle foundingOfferStatementEmphasis =
      AppTextStyles.headlineFontStyle(
        fontSize: 50,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 60 / 50,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  /// Contact-address treatment used by the landing footer.
  static final TextStyle footerEmail =
      AppTextStyles.bodyFontStyle(
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

  /// FAQ question treatment.
  static final TextStyle faqQuestion = AppTextStyles.headlineFontStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 40 / 32,
    letterSpacing: -0.32,
    color: AppColors.textPrimary,
  );

  /// FAQ answer treatment.
  static final TextStyle faqAnswer = AppTextStyles.bodyFontStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    letterSpacing: 0.32,
    color: AppColors.bodyGray,
  );

  /// Approved emphasis within selected FAQ answers.
  static final TextStyle faqAnswerEmphasis = AppTextStyles.bodyFontStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
    letterSpacing: 0.32,
    color: AppColors.bodyGray,
  );
}
