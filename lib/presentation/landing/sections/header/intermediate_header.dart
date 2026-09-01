import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_row.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_cta_button.dart';

/// Intermediate two-row composition for the landing header.
final class IntermediateHeader extends StatelessWidget {
  /// Creates the intermediate landing header composition.
  const IntermediateHeader({
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
    key: const Key('landingHeaderIntermediateLayout'),
    children: [
      Row(
        children: [
          const HeaderLogo(),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: LandingCtaButton(
                key: const Key('landingHeaderContactCta'),
                label: contactLabel,
                size: LandingCtaSize.compact,
                onPressed: onContactSelected,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      HeaderNavigationRow(
        items: navigationItems,
        itemSpacing: 4,
        expandItems: true,
      ),
    ],
  );
}
