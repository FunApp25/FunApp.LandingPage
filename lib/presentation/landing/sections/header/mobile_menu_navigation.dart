import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/mobile_menu_item.dart';

/// Centered destination group from the full-screen mobile landing menu.
final class MobileMenuNavigation extends StatelessWidget {
  /// Creates the mobile menu navigation group.
  const MobileMenuNavigation({
    required this.items,
    required this.onItemSelected,
    super.key,
  });

  /// Localized landing destinations in display order.
  final List<HeaderNavigationItemData> items;

  /// Reports which destination should run after the modal closes.
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('landingMobileMenuNavigation'),
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var index = 0; index < items.length; index++) ...[
        if (index > 0) const SizedBox(height: 22),
        MobileMenuItem(
          key: Key('landingMobileMenuNavigationItem$index'),
          label: items[index].label,
          onSelected: () => onItemSelected(index),
        ),
      ],
    ],
  );
}
