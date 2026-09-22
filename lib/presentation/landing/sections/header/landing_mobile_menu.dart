import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/mobile_menu_control.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/mobile_menu_navigation.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_cta_button.dart';

/// Full-screen presentation-local navigation surface for mobile widths.
final class LandingMobileMenu extends StatefulWidget {
  /// Creates the full-screen mobile landing menu.
  const LandingMobileMenu({
    required this.navigationItems,
    required this.contactLabel,
    required this.closeSemanticLabel,
    required this.onClose,
    required this.onItemSelected,
    required this.onContactSelected,
    super.key,
  });

  /// Localized landing destinations in display order.
  final List<HeaderNavigationItemData> navigationItems;

  /// Localized Contact Us label.
  final String contactLabel;

  /// Localized close-button semantic label.
  final String closeSemanticLabel;

  /// Dismisses the modal without selecting a destination.
  final VoidCallback onClose;

  /// Dismisses the modal with a selected destination.
  final ValueChanged<int> onItemSelected;

  /// Closes the menu before the shared Coming Soon dialog opens.
  final VoidCallback onContactSelected;

  @override
  State<LandingMobileMenu> createState() => _LandingMobileMenuState();
}

final class _LandingMobileMenuState extends State<LandingMobileMenu> {
  final FocusNode _closeFocusNode = FocusNode(
    debugLabel: 'landingMobileMenuClose',
  );

  @override
  void dispose() {
    _closeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
    },
    child: Material(
      key: const Key('landingMobileMenu'),
      color: AppColors.lightForeground,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              key: const Key('landingMobileMenuTopArea'),
              height: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: MobileMenuControl(
                    key: const Key('landingMobileMenuCloseButton'),
                    semanticLabel: widget.closeSemanticLabel,
                    iconAsset: AppAssets.mobileMenuClose,
                    focusNode: _closeFocusNode,
                    autofocus: true,
                    onPressed: widget.onClose,
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  key: const Key('landingMobileMenuNavigationScrollView'),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MobileMenuNavigation(
                          items: widget.navigationItems,
                          onItemSelected: widget.onItemSelected,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              key: const Key('landingMobileMenuContactArea'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: LandingCtaButton(
                  key: const Key('landingMobileMenuContactCta'),
                  label: widget.contactLabel,
                  size: LandingCtaSize.compact,
                  onPressed: widget.onContactSelected,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
