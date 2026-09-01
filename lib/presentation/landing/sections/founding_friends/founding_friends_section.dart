import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_promotional_card.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_scroll_reveal.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';

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
        final contentWidth = (availableWidth - (pageGutter * 2)).clamp(
          0.0,
          AppSizes.maxContentWidth,
        );
        final initialDistance = contentWidth < 780 ? 12.0 : 20.0;

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
              child: LandingScrollReveal(
                key: const Key('foundingFriendsReveal'),
                duration: LandingMotion.revealDuration,
                transitionBuilder: (context, progress, child) {
                  final easedProgress = LandingMotion.standardCurve.transform(
                    progress,
                  );

                  return Transform.translate(
                    key: const Key('foundingFriendsRevealTransform'),
                    offset: Offset(
                      initialDistance * (1 - easedProgress),
                      0,
                    ),
                    child: Opacity(
                      key: const Key('foundingFriendsRevealOpacity'),
                      opacity: 0.2 + (0.8 * easedProgress),
                      alwaysIncludeSemantics: true,
                      child: child,
                    ),
                  );
                },
                child: LandingPromotionalCard(
                  variant: LandingPromotionalCardVariant.foundingFriends,
                  heading: context.l10n.landingFoundingFriendsHeading,
                  bodyParagraphs: [
                    context.l10n.landingFoundingFriendsBodyFirst,
                    context.l10n.landingFoundingFriendsBodySecond,
                  ],
                  ctaLabel: context.l10n.landingFoundingFriendsCta,
                  imageSemanticLabel:
                      context.l10n.landingFoundingFriendsImageDescription,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
