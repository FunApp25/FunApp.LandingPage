import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_navigation_item.dart';

/// Landing-page footer from Figma node `2190:1664`.
final class LandingFooter extends StatelessWidget {
  /// Creates the landing footer.
  const LandingFooter({
    required this.onOurBeliefSelected,
    required this.onMembershipSelected,
    required this.onFoundingFriendsSelected,
    required this.onVenuesSelected,
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

  /// Visible contact address whose interaction remains intentionally deferred.
  static const contactEmail = 'info@funapp.world';

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.beigeAccent,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = AppSizes.pageGutterFor(availableWidth);
        final verticalPadding =
            (availableWidth * (88 / AppSizes.desktopPageWidth)).clamp(
              64.0,
              88.0,
            );
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

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: pageGutter,
            vertical: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FooterLogoAndNavigation(items: navigationItems),
                  const SizedBox(height: 80),
                  const _FooterEmail(),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

final class _FooterLogoAndNavigation extends StatelessWidget {
  const _FooterLogoAndNavigation({required this.items});

  final List<_NavigationItem> items;

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

typedef _NavigationItem = ({String label, VoidCallback onSelected});

final class _FooterEmail extends StatelessWidget {
  const _FooterEmail();

  @override
  Widget build(BuildContext context) => Semantics(
    key: const Key('footerEmailSemantics'),
    label: LandingFooter.contactEmail,
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.yellowAccent,
            borderRadius: BorderRadius.all(
              Radius.circular(AppSizes.pillRadius),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              AppAssets.footerEnvelope,
              key: const Key('footerEnvelope'),
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.blueMain,
                BlendMode.srcIn,
              ),
              excludeFromSemantics: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            LandingFooter.contactEmail,
            key: const Key('footerEmailText'),
            style: AppTextStyles.landingFooterEmail,
          ),
        ),
      ],
    ),
  );
}
