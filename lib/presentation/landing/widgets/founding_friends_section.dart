import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_cta_button.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_promotional_card.dart';

/// Founding Friends promotional content from Figma node `2190:1620`.
final class FoundingFriendsSection extends StatelessWidget {
  /// Creates the Founding Friends section.
  const FoundingFriendsSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.lightForeground,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = AppSizes.pageGutterFor(availableWidth);
        final verticalPadding = AppSizes.sectionVerticalPaddingFor(
          availableWidth,
        );

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
              child: LandingPromotionalCard(
                semanticId: 'foundingFriends',
                heading: context.l10n.landingFoundingFriendsHeading,
                bodyParagraphs: [
                  context.l10n.landingFoundingFriendsBodyFirst,
                  context.l10n.landingFoundingFriendsBodySecond,
                ],
                ctaLabel: context.l10n.landingFoundingFriendsCta,
                ctaAppearance: LandingCtaAppearance.brandBlue,
                backgroundColor: AppColors.yellowAccent,
                foregroundColor: AppColors.textPrimary,
                imageAsset: AppAssets.foundingFriendsGroup,
                imageSemanticLabel:
                    context.l10n.landingFoundingFriendsImageDescription,
                imageSide: PromotionalImageSide.trailing,
                desktopHeight: 586,
                desktopContentWidth: 494,
                desktopLeadingInset: 128,
                desktopGap: 94,
                desktopImageSlotWidth: 644,
                desktopTrailingInset: 0,
                desktopImageAlignment: Alignment.centerLeft,
              ),
            ),
          ),
        );
      },
    ),
  );
}
