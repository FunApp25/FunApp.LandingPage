import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/connection/connection_image.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/connection/connection_introduction.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/connection/mobile_connection_introduction.dart';

/// Alternative connection experience from Figma node `2190:1596`.
final class ConnectionExperienceSection extends StatelessWidget {
  /// Creates the connection-experience section.
  const ConnectionExperienceSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.lightForeground,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final usesMobileComposition = MediaQuery.sizeOf(context).width < 600;
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = usesMobileComposition
            ? AppSizes.mobileLandingPageGutter
            : AppSizes.pageGutterFor(availableWidth);
        final verticalPadding = usesMobileComposition
            ? AppSizes.mobileLandingSectionVerticalPadding
            : AppSizes.sectionVerticalPaddingFor(availableWidth);

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
              child: LayoutBuilder(
                builder: (context, contentConstraints) {
                  final introductionGap = switch (availableWidth) {
                    >= 1200 => 80.0,
                    >= 600 => 64.0,
                    _ => 40.0,
                  };

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (usesMobileComposition)
                        const MobileConnectionIntroduction()
                      else
                        ConnectionIntroduction(
                          availableWidth: contentConstraints.maxWidth,
                          headingSize: AppSizes.sectionHeadingSizeFor(
                            availableWidth,
                          ),
                        ),
                      SizedBox(height: introductionGap),
                      ConnectionImage(
                        usesMobileCrop: usesMobileComposition,
                      ),
                    ],
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
