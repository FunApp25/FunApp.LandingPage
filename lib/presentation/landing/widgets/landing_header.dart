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

  // The complete desktop row needs this width in every supported locale.
  static const _horizontalCompositionWidth = 1080.0;

  // Below this width, four localized labels are more stable in two rows.
  static const _intermediateCompositionWidth = 620.0;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    key: const Key('landingHeaderBoundary'),
    decoration: BoxDecoration(
      color: AppColors.lightForeground,
      border: Border(
        bottom: BorderSide(
          color: AppColors.warmCharcoal.withValues(alpha: 0.16),
        ),
      ),
    ),
    child: LayoutBuilder(
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
                  final usesIntermediateComposition =
                      contentConstraints.maxWidth >=
                      _intermediateCompositionWidth;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: usesHorizontalComposition ? 13 : 8,
                    ),
                    child: usesHorizontalComposition
                        ? _HorizontalHeader(
                            navigationItems: navigationItems,
                            contactLabel: context.l10n.landingHeaderContactUs,
                            onContactSelected: onContactSelected,
                          )
                        : usesIntermediateComposition
                        ? _IntermediateHeader(
                            navigationItems: navigationItems,
                            contactLabel: context.l10n.landingHeaderContactUs,
                            onContactSelected: onContactSelected,
                          )
                        : _NarrowHeader(
                            navigationItems: navigationItems,
                            contactLabel: context.l10n.landingHeaderContactUs,
                            onContactSelected: onContactSelected,
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
      _NavigationRow(items: navigationItems, itemSpacing: 16),
      const SizedBox(width: 44),
      LandingCtaButton(
        key: const Key('landingHeaderContactCta'),
        label: contactLabel,
        size: LandingCtaSize.compact,
        onPressed: onContactSelected,
      ),
    ],
  );
}

final class _IntermediateHeader extends StatelessWidget {
  const _IntermediateHeader({
    required this.navigationItems,
    required this.contactLabel,
    required this.onContactSelected,
  });

  final List<_NavigationItem> navigationItems;
  final String contactLabel;
  final VoidCallback? onContactSelected;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('landingHeaderIntermediateLayout'),
    children: [
      Row(
        children: [
          const _HeaderLogo(),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: LandingCtaButton(
                key: const Key('landingHeaderContactCta'),
                label: contactLabel,
                size: LandingCtaSize.compact,
                onPressed: onContactSelected,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      _NavigationRow(
        items: navigationItems,
        itemSpacing: 4,
        expandItems: true,
      ),
    ],
  );
}

final class _NarrowHeader extends StatelessWidget {
  const _NarrowHeader({
    required this.navigationItems,
    required this.contactLabel,
    required this.onContactSelected,
  });

  final List<_NavigationItem> navigationItems;
  final String contactLabel;
  final VoidCallback? onContactSelected;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('landingHeaderNarrowLayout'),
    children: [
      Row(
        children: [
          const _HeaderLogo(),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: LandingCtaButton(
                key: const Key('landingHeaderContactCta'),
                label: contactLabel,
                size: LandingCtaSize.compact,
                onPressed: onContactSelected,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      _NavigationGrid(items: navigationItems),
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
  const _NavigationRow({
    required this.items,
    required this.itemSpacing,
    this.expandItems = false,
  });

  final List<_NavigationItem> items;
  final double itemSpacing;
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

final class _NavigationGrid extends StatelessWidget {
  const _NavigationGrid({required this.items});

  final List<_NavigationItem> items;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var rowStart = 0; rowStart < items.length; rowStart += 2) ...[
        if (rowStart > 0) const SizedBox(height: 4),
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

typedef _NavigationItem = ({String label, VoidCallback onSelected});
