import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_email.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_legal_items.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_logo_and_navigation.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/mobile_footer.dart';

/// Landing-page footer from Figma node `2262:1347`.
final class LandingFooter extends StatelessWidget {
  /// Creates the landing footer.
  const LandingFooter({
    required this.onOurBeliefSelected,
    required this.onMembershipSelected,
    required this.onFoundingFriendsSelected,
    required this.onVenuesSelected,
    required this.onPrivacyNoticeSelected,
    super.key,
  });

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

  /// Visible contact address whose interaction remains intentionally deferred.
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
    final legalLabels = [
      context.l10n.landingFooterPrivacyPolicy,
      context.l10n.landingFooterTermsOfUse,
      context.l10n.landingFooterRefundCancellationPolicy,
      context.l10n.landingFooterCookiePolicy,
      context.l10n.landingFooterCookieBanner,
    ];
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return ColoredBox(
      color: AppColors.beigeAccent,
      child: isMobile
          ? MobileFooter(
              items: navigationItems,
              email: contactEmail,
              legalLabels: legalLabels,
              onPrivacyNoticeSelected: onPrivacyNoticeSelected,
            )
          : _DesktopFooter(
              navigationItems: navigationItems,
              legalLabels: legalLabels,
              onPrivacyNoticeSelected: onPrivacyNoticeSelected,
            ),
    );
  }
}

final class _DesktopFooter extends StatelessWidget {
  const _DesktopFooter({
    required this.navigationItems,
    required this.legalLabels,
    required this.onPrivacyNoticeSelected,
  });

  final List<FooterNavigationItemData> navigationItems;
  final List<String> legalLabels;
  final VoidCallback onPrivacyNoticeSelected;

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
                            labels: legalLabels,
                            onPrivacyNoticeSelected: onPrivacyNoticeSelected,
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
                        labels: legalLabels,
                        onPrivacyNoticeSelected: onPrivacyNoticeSelected,
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
