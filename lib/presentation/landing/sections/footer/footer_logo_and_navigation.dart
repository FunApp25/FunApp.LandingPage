import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_navigation_item.dart';

/// Footer wordmark and in-page navigation composition.
final class FooterLogoAndNavigation extends StatelessWidget {
  /// Creates the footer logo and navigation composition.
  const FooterLogoAndNavigation({required this.items, super.key});

  /// Footer navigation items in display order.
  final List<FooterNavigationItemData> items;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      FunAppLogo(
        width: AppSizes.footerWordmarkWidth,
        height: AppSizes.footerWordmarkHeight,
        variant: FunAppLogoVariant.landingV2,
        semanticLabel: context.l10n.brandName,
        excludeFromSemantics: false,
        svgKey: const Key('footerLogoAsset'),
      ),
      const SizedBox(height: 32),
      Wrap(
        key: const Key('footerNavigationWrap'),
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          for (var index = 0; index < items.length; index++)
            LandingNavigationItem(
              key: Key('footerNavigationItem$index'),
              label: items[index].label,
              onSelected: items[index].onSelected,
            ),
        ],
      ),
    ],
  );
}
