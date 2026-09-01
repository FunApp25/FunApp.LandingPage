import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/welcome/welcome_statement_content.dart';

/// Closing welcome statement from Figma node `2190:1638`.
final class WelcomeStatementSection extends StatelessWidget {
  /// Creates the welcome-statement section.
  const WelcomeStatementSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.beigeAccent,
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
              constraints: const BoxConstraints(maxWidth: 764),
              child: WelcomeStatementContent(
                statementSize: AppSizes.statementHeadingSizeFor(
                  availableWidth,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
