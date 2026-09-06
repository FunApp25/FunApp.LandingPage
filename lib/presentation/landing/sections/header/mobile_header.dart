import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/mobile_menu_control.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_cta_button.dart';

/// Compact landing header used below the 600px mobile-UX boundary.
final class MobileHeader extends StatelessWidget {
  /// Creates the compact mobile landing header.
  const MobileHeader({
    required this.contactLabel,
    required this.onContactSelected,
    required this.menuSemanticLabel,
    required this.isMenuExpanded,
    required this.menuFocusNode,
    required this.onMenuPressed,
    super.key,
  });

  /// Localized Contact Us label.
  final String contactLabel;

  /// Reserved for the intentionally deferred Contact Us behavior.
  final VoidCallback? onContactSelected;

  /// Localized menu-button semantic label.
  final String menuSemanticLabel;

  /// Whether the full-screen menu is currently open.
  final bool isMenuExpanded;

  /// Focus node retained so focus can return after menu dismissal.
  final FocusNode menuFocusNode;

  /// Opens the full-screen mobile menu.
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const Key('landingHeaderMobileLayout'),
    height: 70,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final interpolation = ((constraints.maxWidth - 320) / 70).clamp(
          0.0,
          1.0,
        );
        final contactHorizontalPadding = 12 + (8 * interpolation);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const HeaderLogo(),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: LandingCtaButton(
                    key: const Key('landingHeaderContactCta'),
                    label: contactLabel,
                    size: LandingCtaSize.compact,
                    compactHorizontalPadding: contactHorizontalPadding,
                    onPressed: onContactSelected,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              MobileMenuControl(
                key: const Key('landingMobileMenuButton'),
                semanticLabel: menuSemanticLabel,
                iconAsset: AppAssets.mobileMenu,
                expanded: isMenuExpanded,
                focusNode: menuFocusNode,
                onPressed: onMenuPressed,
              ),
            ],
          ),
        );
      },
    ),
  );
}
