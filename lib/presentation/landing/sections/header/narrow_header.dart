import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_grid.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_cta_button.dart';

/// Narrow stacked composition for the landing header.
final class NarrowHeader extends StatelessWidget {
  /// Creates the narrow landing header composition.
  const NarrowHeader({
    required this.onLogoSelected,
    required this.navigationItems,
    required this.contactLabel,
    required this.onContactSelected,
    super.key,
  });

  /// Returns to the top of the landing page.
  final VoidCallback onLogoSelected;

  /// Header navigation items in display order.
  final List<HeaderNavigationItemData> navigationItems;

  /// Localized queue-sign-up label.
  final String contactLabel;

  /// Opens the Here & Now queue-sign-up route.
  final VoidCallback? onContactSelected;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('landingHeaderNarrowLayout'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: HeaderLogo(onSelected: onLogoSelected),
      ),
      HeaderNavigationGrid(items: navigationItems),
      const SizedBox(height: 2),
      Center(
        child: LandingCtaButton(
          key: const Key('landingHeaderContactCta'),
          label: contactLabel,
          size: LandingCtaSize.compact,
          onPressed: onContactSelected,
        ),
      ),
    ],
  );
}
