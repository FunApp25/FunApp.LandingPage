import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';

/// Shared, platform-neutral Material theme for the landing-page shell.
final ThemeData appTheme = ThemeData(
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: AppColors.warmOrange,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.warmOrangeAccent,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.sunnyYellowAccent,
        onSecondaryContainer: AppColors.onSecondary,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.energeticPlumAccent,
        onTertiaryContainer: AppColors.onTertiary,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.error,
        onErrorContainer: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.warmCharcoalAccent,
        onSurfaceVariant: AppColors.onInverseSurface,
        outline: AppColors.outline,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.onInverseSurface,
      ),
  scaffoldBackgroundColor: AppColors.scaffoldBackground,
  canvasColor: Colors.white,
  textTheme: AppTextStyles.textTheme,
  iconTheme: const IconThemeData(
    color: AppColors.textPrimary,
    size: 24,
  ),
  useMaterial3: true,
);
