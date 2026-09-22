import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/horizontal_header.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/intermediate_header.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/landing_mobile_menu.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/mobile_header.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/narrow_header.dart';

/// Adaptive landing header from desktop node `2190:1568` and mobile node
/// `2269:1100`.
final class LandingHeader extends StatefulWidget {
  /// Creates the landing-page header.
  const LandingHeader({
    required this.onOurBeliefSelected,
    required this.onFoundingFriendsSelected,
    required this.onVenuesSelected,
    this.onContactSelected,
    super.key,
  });

  /// Scrolls to the hero section.
  final VoidCallback onOurBeliefSelected;

  /// Scrolls to the Founding Friends section.
  final VoidCallback onFoundingFriendsSelected;

  /// Scrolls to the venue section.
  final VoidCallback onVenuesSelected;

  /// Opens the existing interested-user Coming Soon dialog.
  final VoidCallback? onContactSelected;

  // The complete desktop row needs this width in every supported locale.
  static const _horizontalCompositionWidth = 1080.0;

  // Below this width, four localized labels are more stable in two rows.
  static const _intermediateCompositionWidth = 620.0;

  /// Outer viewport boundary for the mobile header and menu UX.
  static const mobileUxBreakpoint = 600.0;

  @override
  State<LandingHeader> createState() => _LandingHeaderState();
}

final class _LandingHeaderState extends State<LandingHeader> {
  final FocusNode _menuFocusNode = FocusNode(
    debugLabel: 'landingMobileMenuButton',
  );
  RawDialogRoute<int>? _menuRoute;
  NavigatorState? _menuNavigator;
  var _isMenuOpen = false;
  var _restoreMenuFocus = true;
  var _resizeDismissScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final usesMobileUx =
        MediaQuery.sizeOf(context).width < LandingHeader.mobileUxBreakpoint;
    if (!usesMobileUx && _isMenuOpen && !_resizeDismissScheduled) {
      _resizeDismissScheduled = true;
      _restoreMenuFocus = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resizeDismissScheduled = false;
        final route = _menuRoute;
        final navigator = _menuNavigator;
        if (mounted && route != null && route.isCurrent && navigator != null) {
          navigator.pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _menuFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openMobileMenu(
    List<HeaderNavigationItemData> navigationItems,
    String contactLabel,
    String closeSemanticLabel,
  ) async {
    final usesMobileUx =
        MediaQuery.sizeOf(context).width < LandingHeader.mobileUxBreakpoint;
    if (!_isMenuOpen && usesMobileUx) {
      setState(() => _isMenuOpen = true);
      _restoreMenuFocus = true;
      final navigator = Navigator.of(context, rootNavigator: true);
      late final RawDialogRoute<int> route;
      route = RawDialogRoute<int>(
        barrierDismissible: false,
        barrierColor: AppColors.lightForeground,
        transitionDuration: Duration.zero,
        requestFocus: true,
        traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            LandingMobileMenu(
              navigationItems: navigationItems,
              contactLabel: contactLabel,
              closeSemanticLabel: closeSemanticLabel,
              onClose: navigator.pop,
              onItemSelected: navigator.pop,
              onContactSelected: () => navigator.pop(-1),
            ),
      );
      _menuNavigator = navigator;
      _menuRoute = route;

      final selectedIndex = await navigator.push(route);
      if (mounted) {
        final shouldRestoreFocus =
            _restoreMenuFocus &&
            MediaQuery.sizeOf(context).width < LandingHeader.mobileUxBreakpoint;
        _menuRoute = null;
        _menuNavigator = null;
        setState(() => _isMenuOpen = false);
        if (shouldRestoreFocus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _menuFocusNode.context != null) {
              _menuFocusNode.requestFocus();
            }
          });
        }
        if (selectedIndex != null &&
            selectedIndex >= 0 &&
            selectedIndex < navigationItems.length) {
          navigationItems[selectedIndex].onSelected();
        } else if (selectedIndex == -1) {
          widget.onContactSelected?.call();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems = <HeaderNavigationItemData>[
      (
        label: context.l10n.landingHeaderOurBelief,
        onSelected: widget.onOurBeliefSelected,
      ),
      (
        label: context.l10n.landingHeaderFoundingFriends,
        onSelected: widget.onFoundingFriendsSelected,
      ),
      (
        label: context.l10n.landingHeaderForVenues,
        onSelected: widget.onVenuesSelected,
      ),
    ];
    final outerWidth = MediaQuery.sizeOf(context).width;
    final usesMobileUx = outerWidth < LandingHeader.mobileUxBreakpoint;

    return DecoratedBox(
      key: const Key('landingHeaderBoundary'),
      decoration: BoxDecoration(
        color: AppColors.lightForeground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.warmCharcoal.withValues(alpha: 0.16),
          ),
        ),
      ),
      child: usesMobileUx
          ? MobileHeader(
              contactLabel: context.l10n.landingHeaderContactUs,
              onContactSelected: widget.onContactSelected,
              menuSemanticLabel: context.l10n.landingOpenNavigationMenu,
              isMenuExpanded: _isMenuOpen,
              menuFocusNode: _menuFocusNode,
              onMenuPressed: () => _openMobileMenu(
                navigationItems,
                context.l10n.landingHeaderContactUs,
                context.l10n.landingCloseNavigationMenu,
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.hasBoundedWidth
                    ? constraints.maxWidth
                    : AppSizes.desktopPageWidth;
                final pageGutter = AppSizes.pageGutterFor(availableWidth);

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: pageGutter),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSizes.maxContentWidth,
                      ),
                      child: LayoutBuilder(
                        builder: (context, contentConstraints) {
                          final b =
                              MediaQuery.textScalerOf(context).scale(16) / 16;
                          final usesHorizontalComposition =
                              contentConstraints.maxWidth >=
                              LandingHeader._horizontalCompositionWidth *
                                  math.max(
                                    1.0,
                                    b,
                                  );
                          final usesIntermediateComposition =
                              contentConstraints.maxWidth >=
                              LandingHeader._intermediateCompositionWidth;
                          final verticalPadding = usesHorizontalComposition
                              ? 13.0
                              : usesIntermediateComposition
                              ? 8.0
                              : 4.0;

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: verticalPadding,
                            ),
                            child: usesHorizontalComposition
                                ? HorizontalHeader(
                                    navigationItems: navigationItems,
                                    contactLabel:
                                        context.l10n.landingHeaderContactUs,
                                    onContactSelected: widget.onContactSelected,
                                  )
                                : usesIntermediateComposition
                                ? IntermediateHeader(
                                    navigationItems: navigationItems,
                                    contactLabel:
                                        context.l10n.landingHeaderContactUs,
                                    onContactSelected: widget.onContactSelected,
                                  )
                                : NarrowHeader(
                                    navigationItems: navigationItems,
                                    contactLabel:
                                        context.l10n.landingHeaderContactUs,
                                    onContactSelected: widget.onContactSelected,
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
