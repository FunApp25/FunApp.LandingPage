import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_navigation_item.dart';

/// One-row header navigation composition.
final class HeaderNavigationRow extends StatelessWidget {
  /// Creates a header navigation row.
  const HeaderNavigationRow({
    required this.items,
    required this.itemSpacing,
    this.expandItems = false,
    super.key,
  });

  /// Navigation items in display order.
  final List<HeaderNavigationItemData> items;

  /// Horizontal gap between navigation items.
  final double itemSpacing;

  /// Whether each item expands to share available width.
  final bool expandItems;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < items.length; index++) ...[
        if (index > 0) SizedBox(width: itemSpacing),
        if (expandItems) Expanded(child: _item(index)) else _item(index),
      ],
    ],
  );

  Widget _item(int index) => LandingNavigationItem(
    key: Key('landingHeaderNavigationItem$index'),
    label: items[index].label,
    onSelected: items[index].onSelected,
  );
}
