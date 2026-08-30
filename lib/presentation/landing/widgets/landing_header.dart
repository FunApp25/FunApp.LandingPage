import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_cta_button.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_navigation_item.dart';

/// Landing-page header from Figma node `2190:1568`.
final class LandingHeader extends StatelessWidget {
  /// Creates the landing-page header.
  const LandingHeader({
    required this.onOurBeliefSelected,
    required this.onMembershipSelected,
    required this.onFoundingFriendsSelected,
    required this.onVenuesSelected,
    this.onContactSelected,
    super.key,
  });

  /// Scrolls to the hero section.
  final VoidCallback onOurBeliefSelected;

  /// Scrolls to the membership section.
  final VoidCallback onMembershipSelected;

  /// Scrolls to the Founding Friends section.
  final VoidCallback onFoundingFriendsSelected;

  /// Scrolls to the venue section.
  final VoidCallback onVenuesSelected;

  /// Reserved for the intentionally deferred Contact Us behavior.
  final VoidCallback? onContactSelected;

  // Minimum width required by the complete localized horizontal composition.
  // Below it, content wraps without hiding or inventing navigation behavior.
  static const _horizontalCompositionWidth = 1080.0;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.lightForeground,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = AppSizes.pageGutterFor(availableWidth);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: pageGutter,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: LayoutBuilder(
                builder: (context, contentConstraints) {
                  final navigationItems = <_NavigationItem>[
                    (
                      label: context.l10n.landingHeaderOurBelief,
                      onSelected: onOurBeliefSelected,
                    ),
                    (
                      label: context.l10n.landingHeaderMembership,
                      onSelected: onMembershipSelected,
                    ),
                    (
                      label: context.l10n.landingHeaderFoundingFriends,
                      onSelected: onFoundingFriendsSelected,
                    ),
                    (
                      label: context.l10n.landingHeaderForVenues,
                      onSelected: onVenuesSelected,
                    ),
                  ];
                  final usesHorizontalComposition =
                      contentConstraints.maxWidth >=
                      _horizontalCompositionWidth;

                  return usesHorizontalComposition
                      ? _HorizontalHeader(
                          navigationItems: navigationItems,
                          contactLabel: context.l10n.landingHeaderContactUs,
                          onContactSelected: onContactSelected,
                        )
                      : _WrappedHeader(
                          navigationItems: navigationItems,
                          contactLabel: context.l10n.landingHeaderContactUs,
                          onContactSelected: onContactSelected,
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

final class _HorizontalHeader extends StatelessWidget {
  const _HorizontalHeader({
    required this.navigationItems,
    required this.contactLabel,
    required this.onContactSelected,
  });

  final List<_NavigationItem> navigationItems;
  final String contactLabel;
  final VoidCallback? onContactSelected;

  @override
  Widget build(BuildContext context) => Row(
    key: const Key('landingHeaderHorizontalLayout'),
    children: [
      const _HeaderLogo(),
      const Spacer(),
      _NavigationRow(items: navigationItems),
      const SizedBox(width: 56),
      LandingCtaButton(
        key: const Key('landingHeaderContactCta'),
        label: contactLabel,
        size: LandingCtaSize.compact,
        onPressed: onContactSelected,
      ),
    ],
  );
}

final class _WrappedHeader extends StatelessWidget {
  const _WrappedHeader({
    required this.navigationItems,
    required this.contactLabel,
    required this.onContactSelected,
  });

  final List<_NavigationItem> navigationItems;
  final String contactLabel;
  final VoidCallback? onContactSelected;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('landingHeaderWrappedLayout'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _HeaderLogo(),
      const SizedBox(height: 16),
      Wrap(
        spacing: 24,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var index = 0; index < navigationItems.length; index++)
            LandingNavigationItem(
              key: Key('landingHeaderNavigationItem$index'),
              label: navigationItems[index].label,
              onSelected: navigationItems[index].onSelected,
            ),
          LandingCtaButton(
            key: const Key('landingHeaderContactCta'),
            label: contactLabel,
            size: LandingCtaSize.compact,
            onPressed: onContactSelected,
          ),
        ],
      ),
    ],
  );
}

final class _HeaderLogo extends StatelessWidget {
  const _HeaderLogo();

  @override
  Widget build(BuildContext context) => FunAppLogo(
    width: AppSizes.headerWordmarkWidth,
    height: AppSizes.headerWordmarkHeight,
    variant: FunAppLogoVariant.landingV2,
    semanticLabel: context.l10n.brandName,
    excludeFromSemantics: false,
  );
}

final class _NavigationRow extends StatelessWidget {
  const _NavigationRow({required this.items});

  final List<_NavigationItem> items;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < items.length; index++) ...[
        if (index > 0) const SizedBox(width: 40),
        LandingNavigationItem(
          key: Key('landingHeaderNavigationItem$index'),
          label: items[index].label,
          onSelected: items[index].onSelected,
        ),
      ],
    ],
  );
}

typedef _NavigationItem = ({String label, VoidCallback onSelected});
