// Sizing tokens intentionally retain the static theme-token shape used by the
// Fun App presentation layer.
// ignore_for_file: avoid_classes_with_only_static_members

/// Shared sizing and spacing tokens used by the active landing-page shell.
abstract final class AppSizes {
  /// Medium spacing value for page padding and larger gaps.
  static const double spacingMedium = 24;

  /// Restrained width for the Fun App wordmark.
  static const double brandWordmarkWidth = 180;

  /// Width of the desktop Figma landing-page frame.
  static const double desktopPageWidth = 1440;

  /// Horizontal gutter used by the desktop Figma landing page.
  static const double desktopPageGutter = 40;

  /// Smallest safe page gutter when the desktop composition cannot fit.
  static const double minimumPageGutter = 16;

  /// Vertical inset used by complete desktop landing-page sections.
  static const double desktopSectionVerticalPadding = 128;

  /// Smallest vertical section inset used when width is constrained.
  static const double minimumSectionVerticalPadding = 64;

  /// Maximum width available inside the desktop page gutters.
  static const double maxContentWidth = 1360;

  /// Radius used by the landing page's large cards and image containers.
  static const double cardRadius = 20;

  /// Effectively circular radius used by pill-shaped controls.
  static const double pillRadius = 600;

  /// Width of the V2 wordmark in the Figma landing-page header.
  static const double headerWordmarkWidth = 89;

  /// Height of the V2 wordmark in the Figma landing-page header.
  static const double headerWordmarkHeight = 29;

  /// Width of the V2 wordmark in the Figma landing-page footer.
  static const double footerWordmarkWidth = 123;

  /// Height of the V2 wordmark in the Figma landing-page footer.
  static const double footerWordmarkHeight = 40;

  /// Resolves a fluid page gutter capped by the exact desktop value.
  static double pageGutterFor(double availableWidth) =>
      (availableWidth * 0.05).clamp(
        minimumPageGutter,
        desktopPageGutter,
      );

  /// Resolves fluid section spacing capped by the exact desktop value.
  static double sectionVerticalPaddingFor(double availableWidth) =>
      (availableWidth * (desktopSectionVerticalPadding / desktopPageWidth))
          .clamp(
            minimumSectionVerticalPadding,
            desktopSectionVerticalPadding,
          );
}
