/// Centralized asset paths used by landing-page presentation widgets.
abstract final class AppAssets {
  static const _brandingLogoPath = 'assets/branding/logos';
  static const _brandingShapePath = 'assets/branding/shapes';
  static const _landingConnectionPath = 'assets/landing/connection';
  static const _landingHeaderPath = 'assets/landing/header';
  static const _landingHeroPath = 'assets/landing/hero';

  /// Warm charcoal Fun App wordmark SVG.
  static const String funAppWordmarkBlack =
      '$_brandingLogoPath/fun_app_wordmark_black.svg';

  /// Dual-color wordmark used by the Figma landing-page header.
  static const String funAppLogoV2 = '$_landingHeaderPath/fun_app_logo_v2.svg';

  /// Decorative blue glyph beside the landing-page hero eyebrow.
  static const String heroEyebrowGlyph =
      '$_landingHeroPath/friendlier_way_glyph.svg';

  /// Arrow artwork used by the prominent landing-page call to action.
  static const String arrowUpRight = '$_landingHeroPath/arrow_up_right.svg';

  /// Masked photograph used by the landing-page hero.
  static const String heroPeople = '$_landingHeroPath/hero_people.png';

  /// Five diagonal ovals reused by the problem-section eyebrow.
  static const String fiveDiagonalOvals =
      '$_brandingShapePath/five_diagonal_ovals.svg';

  /// Rounded sparkle reused by the connection-section eyebrow.
  static const String roundedSparkleDiamond =
      '$_brandingShapePath/rounded_sparkle_diamond.svg';

  /// Figma-cropped group photograph used by the connection section.
  static const String connectionGroup =
      '$_landingConnectionPath/connection_group.png';
}
