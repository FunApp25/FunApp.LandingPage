import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_row.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_cta_button.dart';

/// Wide horizontal composition for the landing header.
final class HorizontalHeader extends StatelessWidget {
  /// Creates the wide landing header composition.
  const HorizontalHeader({
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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final usesFigmaSpacing = constraints.maxWidth >= 1280;

      if (usesFigmaSpacing) {
        return Row(
          key: const Key('landingHeaderHorizontalLayout'),
          children: [
            const HeaderLogo(),
            const Spacer(),
            HeaderNavigationRow(items: navigationItems, itemSpacing: 16),
            const SizedBox(width: 44),
            LandingCtaButton(
              key: const Key('landingHeaderContactCta'),
              label: contactLabel,
              size: LandingCtaSize.compact,
              onPressed: onContactSelected,
            ),
          ],
        );
      } else {
        return Row(
          key: const Key('landingHeaderHorizontalLayout'),
          children: [
            const HeaderLogo(),
            const SizedBox(width: 20),
            Expanded(
              child: HeaderNavigationRow(
                items: navigationItems,
                itemSpacing: 4,
                expandItems: true,
              ),
            ),
            const SizedBox(width: 20),
            LandingCtaButton(
              key: const Key('landingHeaderContactCta'),
              label: contactLabel,
              size: LandingCtaSize.compact,
              onPressed: onContactSelected,
            ),
          ],
        );
      }
    },
  );
}
