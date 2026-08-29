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

  /// Maximum width available inside the desktop page gutters.
  static const double maxContentWidth = 1360;

  /// Radius used by the landing page's large cards and image containers.
  static const double cardRadius = 20;

  /// Effectively circular radius used by pill-shaped controls.
  static const double pillRadius = 600;

  /// Temporary width for the existing wordmark in the header skeleton.
  static const double headerWordmarkWidth = 89;
}
