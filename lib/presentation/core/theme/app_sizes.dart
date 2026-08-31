// Sizing tokens intentionally retain the static theme-token shape used by the
// Fun App presentation layer.
// ignore_for_file: avoid_classes_with_only_static_members

/// Shared sizing and spacing tokens used by the active landing page.
abstract final class AppSizes {
  /// Width of the desktop Figma landing-page frame.
  static const double desktopPageWidth = 1440;

  /// Horizontal gutter used by the desktop Figma landing page.
  static const double desktopPageGutter = 40;

  /// Smallest safe page gutter when the desktop composition cannot fit.
  static const double minimumPageGutter = 16;

  /// Vertical inset used by complete desktop landing-page sections.
  static const double desktopSectionVerticalPadding = 128;

  /// Vertical inset used by intermediate landing-page sections.
  static const double intermediateSectionVerticalPadding = 88;

  /// Vertical inset used by narrow landing-page sections.
  static const double narrowSectionVerticalPadding = 48;

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

  /// Resolves deliberate desktop, intermediate, and narrow section rhythm.
  static double sectionVerticalPaddingFor(double availableWidth) {
    if (availableWidth >= 1200) {
      return desktopSectionVerticalPadding;
    } else if (availableWidth >= 600) {
      return intermediateSectionVerticalPadding;
    } else {
      return narrowSectionVerticalPadding;
    }
  }

  /// Resolves the shared landing-page section-heading size.
  static double sectionHeadingSizeFor(double availableWidth) {
    if (availableWidth >= 1200) {
      return 44;
    } else if (availableWidth >= 600) {
      return 40;
    } else {
      return 34;
    }
  }

  /// Resolves the large statement size used by narrative sections.
  static double statementHeadingSizeFor(double availableWidth) {
    if (availableWidth >= 1200) {
      return 50;
    } else if (availableWidth >= 600) {
      return 42;
    } else {
      return 34;
    }
  }
}
