import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/hero/desktop_hero.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/hero/responsive_hero.dart';

/// Landing-page hero from Figma wrapper node `2190:1569`.
final class HeroSection extends StatelessWidget {
  /// Creates the landing-page hero.
  const HeroSection({super.key});

  // The exact Figma composition needs enough width for its intentionally
  // overlapping copy and clipped artwork regions. Below this constraint the
  // artwork stays top-right while copy clears it vertically.
  static const _wideCompositionWidth = 1280.0;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.lightForeground,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = AppSizes.pageGutterFor(availableWidth);
        final topSpacing = switch (availableWidth) {
          >= 1200 => 24.0,
          >= 600 => 20.0,
          _ => 16.0,
        };

        return Padding(
          padding: EdgeInsets.only(
            left: pageGutter,
            top: topSpacing,
            right: pageGutter,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: LayoutBuilder(
                builder: (context, heroConstraints) {
                  final usesDesktopComposition =
                      heroConstraints.maxWidth >= _wideCompositionWidth;

                  return ClipRRect(
                    key: const Key('heroCard'),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppSizes.cardRadius),
                    ),
                    child: ColoredBox(
                      color: AppColors.beigeAccent,
                      child: usesDesktopComposition
                          ? const DesktopHero()
                          : ResponsiveHero(
                              availableWidth: heroConstraints.maxWidth,
                            ),
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
