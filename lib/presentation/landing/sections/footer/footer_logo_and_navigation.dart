import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_navigation_item.dart';

/// Footer wordmark and in-page navigation composition.
final class FooterLogoAndNavigation extends StatelessWidget {
  /// Creates the footer logo and navigation composition.
  const FooterLogoAndNavigation({
    required this.items,
    this.navigationSpacing = 16,
    this.navigationRunSpacing = 8,
    this.horizontal = false,
    super.key,
  });

  /// Footer navigation items in display order.
  final List<FooterNavigationItemData> items;

  /// Horizontal space between footer navigation controls.
  final double navigationSpacing;

  /// Vertical space between wrapped footer navigation controls.
  final double navigationRunSpacing;

  /// Whether the logo and navigation share the desktop top row.
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final logo = FunAppLogo(
      width: AppSizes.footerWordmarkWidth,
      height: AppSizes.footerWordmarkHeight,
      variant: FunAppLogoVariant.landingV2,
      semanticLabel: context.l10n.brandName,
      excludeFromSemantics: false,
      svgKey: const Key('footerLogoAsset'),
    );
    final navigation = Wrap(
      key: const Key('footerNavigationWrap'),
      alignment: WrapAlignment.center,
      spacing: navigationSpacing,
      runSpacing: navigationRunSpacing,
      children: [
        for (var index = 0; index < items.length; index++)
          LandingNavigationItem(
            key: Key('footerNavigationItem$index'),
            label: items[index].label,
            onSelected: items[index].onSelected,
          ),
      ],
    );

    if (horizontal) {
      return Row(
        children: [
          logo,
          const SizedBox(width: 40),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: navigation,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [logo, const SizedBox(height: 32), navigation],
      );
    }
  }
}
