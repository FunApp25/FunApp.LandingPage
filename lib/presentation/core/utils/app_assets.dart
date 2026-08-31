/// Centralized asset paths used by landing-page presentation widgets.
abstract final class AppAssets {
  static const _brandingLogoPath = 'assets/branding/logos';
  static const _brandingShapePath = 'assets/branding/shapes';
  static const _landingConnectionPath = 'assets/landing/connection';
  static const _landingFaqPath = 'assets/landing/faq';
  static const _landingFoundingMemberPath = 'assets/landing/founding_member';
  static const _landingFoundingFriendsPath = 'assets/landing/founding_friends';
  static const _landingFooterPath = 'assets/landing/footer';
  static const _landingHeaderPath = 'assets/landing/header';
  static const _landingHeroPath = 'assets/landing/hero';
  static const _landingMembershipPath = 'assets/landing/membership';
  static const _landingVenuesPath = 'assets/landing/venues';
  static const _landingWelcomePath = 'assets/landing/welcome';

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

  /// Exact purple decorative glyph used by the FAQ eyebrow.
  static const String faqGlyph = '$_landingFaqPath/faq_glyph.svg';

  /// Exact collapsed-state icon used by FAQ question controls.
  static const String faqPlus = '$_landingFaqPath/faq_plus.svg';

  /// Exact expanded-state icon used by FAQ question controls.
  static const String faqMinus = '$_landingFaqPath/faq_minus.svg';

  /// Orange sparkle used by the Free Membership eyebrow.
  static const String membershipFreeEyebrow =
      '$_landingMembershipPath/free_eyebrow.svg';

  /// Blue sparkle used by the Here & Now Membership eyebrow.
  static const String membershipHereNowEyebrow =
      '$_landingMembershipPath/here_now_eyebrow.svg';

  /// Yellow sparkle used by the Lifetime Membership eyebrow.
  static const String membershipLifetimeEyebrow =
      '$_landingMembershipPath/lifetime_eyebrow.svg';

  /// White check used by Free and Lifetime Membership benefits.
  static const String membershipCheckWhite =
      '$_landingMembershipPath/check_white.svg';

  /// Blue check used by Here & Now Membership benefits.
  static const String membershipCheckBlue =
      '$_landingMembershipPath/check_blue.svg';

  /// Charcoal arrow used by the Lifetime Membership visual CTA.
  static const String membershipArrowCharcoal =
      '$_landingMembershipPath/arrow_charcoal.svg';

  /// Purple decorative glyph used by the limited-time offer eyebrow.
  static const String foundingOfferGlyph =
      '$_landingMembershipPath/founding_offer_glyph.svg';

  /// Users icon used by the Recognised Forever benefit card.
  static const String foundingMemberUsers =
      '$_landingFoundingMemberPath/users_three.svg';

  /// Rocket icon used by the Early Access Always benefit card.
  static const String foundingMemberRocket =
      '$_landingFoundingMemberPath/rocket_launch.svg';

  /// Chat icon used by the A Direct Voice benefit card.
  static const String foundingMemberChat =
      '$_landingFoundingMemberPath/chat_teardrop_text.svg';

  /// Masked photograph used by the Founding Friends promotional card.
  static const String foundingFriendsGroup =
      '$_landingFoundingFriendsPath/founding_friends_group.png';

  /// Masked photograph used by the venue promotional card.
  static const String venueGroup = '$_landingVenuesPath/venue_group.png';

  /// Exact decorative glyph used by the welcome-statement eyebrow.
  static const String welcomeGlyph = '$_landingWelcomePath/welcome_glyph.svg';

  /// Exact envelope artwork used by the landing-page footer.
  static const String footerEnvelope =
      '$_landingFooterPath/envelope_simple.svg';
}
