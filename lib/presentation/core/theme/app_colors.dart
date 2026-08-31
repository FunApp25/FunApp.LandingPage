import 'package:flutter/material.dart';

/// Shared color tokens for the Fun App visual language.
abstract final class AppColors {
  /// Primary warm brand color for prominent actions and active controls.
  static const Color warmOrange = Color(0xFFEF6632);

  /// Brighter warm orange accent for emphasized brand moments.
  static const Color warmOrangeAccent = Color(0xFFFF7032);

  /// Main warm neutral for readable text on light surfaces.
  static const Color warmCharcoal = Color(0xFF1D1220);

  /// Deeper warm neutral for dark accents and inverse surfaces.
  static const Color warmCharcoalAccent = Color(0xFF2C222F);

  /// Secondary sunny color for supportive highlights.
  static const Color sunnyYellow = Color(0xFFFFBD00);

  /// Softer sunny accent for selected or contained secondary surfaces.
  static const Color sunnyYellowAccent = Color(0xFFFFD45C);

  /// Secondary energetic color for tertiary accents.
  static const Color energeticPlum = Color(0xFF63328D);

  /// Brighter plum accent for emphasized tertiary states.
  static const Color energeticPlumAccent = Color(0xFF7F42B3);

  /// Supporting red used for errors and destructive status.
  static const Color cherryRed = Color(0xFFCE0237);

  /// Historical app-era warm neutral retained for established brand uses.
  static const Color softSand = Color(0xFFECE1CE);

  /// Warm beige surface used throughout the current landing-page design.
  static const Color beigeAccent = Color(0xFFFAF0DD);

  /// Bright yellow accent used by the current landing-page design.
  static const Color yellowAccent = Color(0xFFFFE66D);

  /// Strong blue accent used by the current landing-page design.
  static const Color blueMain = Color(0xFF1E4DFF);

  /// Neutral gray used for supporting landing-page body copy.
  static const Color bodyGray = Color(0xFF656563);

  /// Light foreground for dark or saturated brand surfaces.
  static const Color lightForeground = Color(0xFFFFFFFF);

  /// Primary theme color used for prominent surfaces and accents.
  static const Color primary = warmOrange;

  /// Foreground color paired with the primary color.
  static const Color onPrimary = lightForeground;

  /// Secondary theme color used for warm supporting highlights.
  static const Color secondary = yellowAccent;

  /// Foreground color paired with the secondary color.
  static const Color onSecondary = warmCharcoal;

  /// Tertiary theme color used for stronger contrast accents.
  static const Color tertiary = energeticPlum;

  /// Foreground color paired with the tertiary color.
  static const Color onTertiary = lightForeground;

  /// Error color for validation and failure states.
  static const Color error = cherryRed;

  /// Foreground color paired with error surfaces.
  static const Color onError = lightForeground;

  /// Base surface color for cards and elevated containers.
  static const Color surface = lightForeground;

  /// Default background color for scaffold-level surfaces.
  static const Color scaffoldBackground = lightForeground;

  /// Default high-contrast text color.
  static const Color textPrimary = warmCharcoal;

  /// Secondary text color for supporting copy.
  static const Color textSecondary = bodyGray;

  /// Neutral outline color for subtle separators and strokes.
  static const Color outline = warmCharcoalAccent;

  /// Dark inverse surface used for high-contrast accents.
  static const Color inverseSurface = warmCharcoalAccent;

  /// Foreground color paired with inverse surfaces.
  static const Color onInverseSurface = lightForeground;
}
