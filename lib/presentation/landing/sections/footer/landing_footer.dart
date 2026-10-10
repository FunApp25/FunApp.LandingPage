import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_email.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_legal_items.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_logo_and_navigation.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/mobile_footer.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_placeholder_page.dart';

/// Landing-page footer from Figma node `2262:1347`.
final class LandingFooter extends StatelessWidget {
  /// Creates the landing footer.
  const LandingFooter({
    required this.onLogoSelected,
    required this.onOurBeliefSelected,
    required this.onMembershipSelected,
    required this.onFoundingFriendsSelected,
    required this.onVenuesSelected,
    required this.onPrivacyNoticeSelected,
    super.key,
  });

  /// Returns to the top of the landing page.
  final VoidCallback onLogoSelected;

  /// Scrolls to the hero section.
  final VoidCallback onOurBeliefSelected;

  /// Scrolls to the Membership section.
  final VoidCallback onMembershipSelected;

  /// Scrolls to the Founding Friends section.
  final VoidCallback onFoundingFriendsSelected;

  /// Scrolls to the venue section.
  final VoidCallback onVenuesSelected;

  /// Opens the hosted Privacy Notice in a separate tab.
  final VoidCallback onPrivacyNoticeSelected;

  /// Visible contact address opened through the user's configured mail client.
  static const contactEmail = 'info@funapp.world';

  @override
  Widget build(BuildContext context) {
    final navigationItems = <FooterNavigationItemData>[
      (
        label: context.l10n.landingHeaderOurBelief,
        onSelected: onOurBeliefSelected,
      ),
      (
        label: context.l10n.landingHeaderMembership,
        onSelected: onMembershipSelected,
      ),
      (
        label: context.l10n.landingHeaderFoundingFriends,
        onSelected: onFoundingFriendsSelected,
      ),
      (
        label: context.l10n.landingHeaderForVenues,
        onSelected: onVenuesSelected,
      ),
    ];
    void openLegalRoute(String routeName) {
      if (ModalRoute.of(context)?.settings.name != routeName) {
        Navigator.of(context).pushNamed(routeName);
      }
    }

    final legalItems = <FooterLegalItemData>[
      (
        semanticKey: const Key('footerPrivacyNoticeLink'),
        label: context.l10n.landingFooterPrivacyPolicy,
        onSelected: onPrivacyNoticeSelected,
      ),
      (
        semanticKey: const Key('footerTermsLink'),
        label: context.l10n.landingFooterTermsOfUse,
        onSelected: () => openLegalRoute(LegalPlaceholderPage.termsRouteName),
      ),
      (
        semanticKey: const Key('footerRefundsLink'),
        label: context.l10n.landingFooterRefundCancellationPolicy,
        onSelected: () => openLegalRoute(LegalPlaceholderPage.refundsRouteName),
      ),
      (
        semanticKey: const Key('footerCookiePolicyLink'),
        label: context.l10n.landingFooterCookiePolicy,
        onSelected: () => openLegalRoute(LegalPlaceholderPage.cookiesRouteName),
      ),
      (
        semanticKey: const Key('footerCookieBannerLink'),
        label: context.l10n.landingFooterCookieBanner,
        onSelected: () =>
            openLegalRoute(LegalPlaceholderPage.cookieBannerRouteName),
      ),
    ];
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return ColoredBox(
      color: AppColors.beigeAccent,
      child: isMobile
          ? MobileFooter(
              items: navigationItems,
              onLogoSelected: onLogoSelected,
              email: contactEmail,
              legalItems: legalItems,
            )
          : _DesktopFooter(
              navigationItems: navigationItems,
              onLogoSelected: onLogoSelected,
              legalItems: legalItems,
            ),
    );
  }
}

final class _DesktopFooter extends StatelessWidget {
  const _DesktopFooter({
    required this.navigationItems,
    required this.onLogoSelected,
    required this.legalItems,
  });

  final List<FooterNavigationItemData> navigationItems;
  final VoidCallback onLogoSelected;
  final List<FooterLegalItemData> legalItems;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final availableWidth = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : AppSizes.desktopPageWidth;
      final usesWideRows =
          availableWidth >= 1200 &&
          Localizations.localeOf(context).languageCode == 'en' &&
          MediaQuery.textScalerOf(context).scale(12) <= 12;
      final pageGutter = AppSizes.pageGutterFor(availableWidth);
      final verticalPadding = availableWidth >= 1200 ? 88.0 : 64.0;

      return Padding(
        key: const Key('footerDesktopLayout'),
        padding: EdgeInsets.symmetric(
          horizontal: pageGutter,
          vertical: verticalPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            key: const Key('footerDesktopContent'),
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FooterLogoAndNavigation(
                  items: navigationItems,
                  onLogoSelected: onLogoSelected,
                  horizontal: usesWideRows,
                ),
                const SizedBox(height: 72),
                const Divider(
                  key: Key('footerDesktopDivider'),
                  height: 1,
                  thickness: 1,
                  color: Color(0x331D1220),
                ),
                const SizedBox(height: 71),
                if (usesWideRows)
                  Row(
                    children: [
                      const FooterEmail(email: LandingFooter.contactEmail),
                      const SizedBox(width: 40),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FooterLegalItems(
                            items: legalItems,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FooterEmail(email: LandingFooter.contactEmail),
                      const SizedBox(height: 32),
                      FooterLegalItems(
                        items: legalItems,
                        spacing: 20,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
