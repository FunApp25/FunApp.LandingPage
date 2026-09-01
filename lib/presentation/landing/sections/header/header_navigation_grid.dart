import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_navigation_item.dart';

/// Two-column header navigation composition for narrow layouts.
final class HeaderNavigationGrid extends StatelessWidget {
  /// Creates the narrow header navigation grid.
  const HeaderNavigationGrid({required this.items, super.key});

  /// Navigation items in display order.
  final List<HeaderNavigationItemData> items;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var rowStart = 0; rowStart < items.length; rowStart += 2) ...[
        if (rowStart > 0) const SizedBox(height: 2),
        Row(
          children: [
            for (var index = rowStart; index < rowStart + 2; index++) ...[
              if (index > rowStart) const SizedBox(width: 4),
              Expanded(
                child: LandingNavigationItem(
                  key: Key('landingHeaderNavigationItem$index'),
                  label: items[index].label,
                  onSelected: items[index].onSelected,
                ),
              ),
            ],
          ],
        ),
      ],
    ],
  );
}
