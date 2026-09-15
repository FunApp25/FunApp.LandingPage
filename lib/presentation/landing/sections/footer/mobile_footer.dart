import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_email.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_logo_and_navigation.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_privacy_notice_link.dart';

/// Mobile footer composition from Figma node `2270:3307`.
final class MobileFooter extends StatelessWidget {
  /// Creates the mobile footer composition.
  const MobileFooter({
    required this.items,
    required this.email,
    required this.privacyNoticeLabel,
    required this.onPrivacyNoticeSelected,
    super.key,
  });

  /// Footer navigation items in display order.
  final List<FooterNavigationItemData> items;

  /// Static contact address.
  final String email;

  /// Localized label for the hosted Privacy Notice.
  final String privacyNoticeLabel;

  /// Navigates to the hosted Privacy Notice page.
  final VoidCallback onPrivacyNoticeSelected;

  @override
  Widget build(BuildContext context) => Padding(
    key: const Key('footerMobileLayout'),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.mobileLandingPageGutter,
      vertical: AppSizes.mobileLandingSectionVerticalPadding,
    ),
    child: Column(
      key: const Key('footerMobileContent'),
      mainAxisSize: MainAxisSize.min,
      children: [
        FooterLogoAndNavigation(
          items: items,
          navigationSpacing: 20,
          navigationRunSpacing: 20,
        ),
        const SizedBox(height: 60),
        SizedBox(
          key: const Key('footerMobileDivider'),
          width: double.infinity,
          height: 1,
          child: ColoredBox(
            color: AppColors.warmCharcoal.withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(height: 60),
        FooterEmail(email: email),
        const SizedBox(height: 32),
        FooterPrivacyNoticeLink(
          label: privacyNoticeLabel,
          onSelected: onPrivacyNoticeSelected,
        ),
      ],
    ),
  );
}
