import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';

/// Internal visual tokens for each membership card variant.
enum MembershipCardDesign {
  /// Free membership card tokens.
  free(
    backgroundColor: AppColors.lightForeground,
    foregroundColor: AppColors.textPrimary,
    eyebrowColor: AppColors.warmOrange,
    eyebrowAsset: AppAssets.membershipFreeEyebrow,
    checkBackgroundColor: AppColors.energeticPlum,
    checkAsset: AppAssets.membershipCheckWhite,
    ctaBackgroundColor: AppColors.warmOrange,
    ctaForegroundColor: AppColors.lightForeground,
    ctaArrowAsset: AppAssets.arrowUpRight,
  ),

  /// Here & Now membership card tokens.
  hereNow(
    backgroundColor: AppColors.yellowAccent,
    foregroundColor: AppColors.textPrimary,
    eyebrowColor: AppColors.blueMain,
    eyebrowAsset: AppAssets.membershipHereNowEyebrow,
    checkBackgroundColor: AppColors.lightForeground,
    checkAsset: AppAssets.membershipCheckBlue,
    ctaBackgroundColor: AppColors.blueMain,
    ctaForegroundColor: AppColors.lightForeground,
    ctaArrowAsset: AppAssets.arrowUpRight,
  ),

  /// Lifetime membership card tokens.
  lifetime(
    backgroundColor: AppColors.warmCharcoalAccent,
    foregroundColor: AppColors.lightForeground,
    eyebrowColor: AppColors.yellowAccent,
    eyebrowAsset: AppAssets.membershipLifetimeEyebrow,
    checkBackgroundColor: AppColors.blueMain,
    checkAsset: AppAssets.membershipCheckWhite,
    ctaBackgroundColor: AppColors.yellowAccent,
    ctaForegroundColor: AppColors.textPrimary,
    ctaArrowAsset: AppAssets.membershipArrowCharcoal,
  );

  const MembershipCardDesign({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.eyebrowColor,
    required this.eyebrowAsset,
    required this.checkBackgroundColor,
    required this.checkAsset,
    required this.ctaBackgroundColor,
    required this.ctaForegroundColor,
    required this.ctaArrowAsset,
  });

  /// Card background color.
  final Color backgroundColor;

  /// Primary card foreground color.
  final Color foregroundColor;

  /// Tier eyebrow color.
  final Color eyebrowColor;

  /// Tier eyebrow asset.
  final String eyebrowAsset;

  /// Benefit check background color.
  final Color checkBackgroundColor;

  /// Benefit check asset.
  final String checkAsset;

  /// Visual CTA background color.
  final Color ctaBackgroundColor;

  /// Visual CTA foreground color.
  final Color ctaForegroundColor;

  /// Visual CTA arrow asset.
  final String ctaArrowAsset;
}
