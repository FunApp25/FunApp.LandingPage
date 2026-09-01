import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/header_navigation_item_data.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/horizontal_header.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/intermediate_header.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/narrow_header.dart';

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
                  final navigationItems = <HeaderNavigationItemData>[
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
                  final verticalPadding = usesHorizontalComposition
                      ? 13.0
                      : usesIntermediateComposition
                      ? 8.0
                      : 4.0;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding),
                    child: usesHorizontalComposition
                        ? HorizontalHeader(
                            navigationItems: navigationItems,
                            contactLabel: context.l10n.landingHeaderContactUs,
                            onContactSelected: onContactSelected,
                          )
                        : usesIntermediateComposition
                        ? IntermediateHeader(
                            navigationItems: navigationItems,
                            contactLabel: context.l10n.landingHeaderContactUs,
                            onContactSelected: onContactSelected,
                          )
                        : NarrowHeader(
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
