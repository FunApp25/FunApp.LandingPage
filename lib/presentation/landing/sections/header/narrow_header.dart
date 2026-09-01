import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_grid.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_cta_button.dart';

/// Narrow stacked composition for the landing header.
final class NarrowHeader extends StatelessWidget {
  /// Creates the narrow landing header composition.
  const NarrowHeader({
    required this.navigationItems,
    required this.contactLabel,
    required this.onContactSelected,
    super.key,
  });

  /// Header navigation items in display order.
  final List<HeaderNavigationItemData> navigationItems;

  /// Localized Contact Us label.
  final String contactLabel;

  /// Reserved for the intentionally deferred Contact Us behavior.
  final VoidCallback? onContactSelected;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('landingHeaderNarrowLayout'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Align(
        alignment: Alignment.centerLeft,
        child: HeaderLogo(),
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
