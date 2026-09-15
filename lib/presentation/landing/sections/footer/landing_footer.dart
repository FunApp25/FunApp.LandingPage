import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_email.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_logo_and_navigation.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_privacy_notice_link.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/mobile_footer.dart';

/// Landing-page footer from Figma node `2190:1664`.
final class LandingFooter extends StatelessWidget {
  /// Creates the landing footer.
  const LandingFooter({
    required this.onOurBeliefSelected,
    required this.onFoundingFriendsSelected,
    required this.onVenuesSelected,
    required this.onPrivacyNoticeSelected,
    super.key,
  });

  /// Scrolls to the hero section.
  final VoidCallback onOurBeliefSelected;

  /// Scrolls to the Founding Friends section.
  final VoidCallback onFoundingFriendsSelected;

  /// Scrolls to the venue section.
  final VoidCallback onVenuesSelected;

  /// Navigates to the hosted Privacy Notice page.
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
        label: context.l10n.landingHeaderFoundingFriends,
        onSelected: onFoundingFriendsSelected,
      ),
      (
        label: context.l10n.landingHeaderForVenues,
        onSelected: onVenuesSelected,
      ),
    ];
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    if (isMobile) {
      return ColoredBox(
        color: AppColors.beigeAccent,
        child: MobileFooter(
          items: navigationItems,
          email: contactEmail,
          privacyNoticeLabel: context.l10n.privacyNoticeNavigationLabel,
          onPrivacyNoticeSelected: onPrivacyNoticeSelected,
        ),
      );
    } else {
      return ColoredBox(
        color: AppColors.beigeAccent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : AppSizes.desktopPageWidth;
            final pageGutter = AppSizes.pageGutterFor(availableWidth);
            final verticalPadding = switch (availableWidth) {
              >= 1200 => 88.0,
              >= 600 => 64.0,
              _ => 48.0,
            };

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pageGutter,
                vertical: verticalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.maxContentWidth,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FooterLogoAndNavigation(items: navigationItems),
                      SizedBox(height: availableWidth < 600 ? 48 : 80),
                      const FooterEmail(email: contactEmail),
                      const SizedBox(height: 24),
                      FooterPrivacyNoticeLink(
                        label: context.l10n.privacyNoticeNavigationLabel,
                        onSelected: onPrivacyNoticeSelected,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
