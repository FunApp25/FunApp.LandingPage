import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';

/// Provides temporary section rhythm while final section content is absent.
///
/// [desktopMinHeight] follows the 1440px Figma frame only as a skeleton aid.
/// Real section content will replace these minimums and determine natural
/// height as each section is implemented.
final class LandingSectionPlaceholder extends StatelessWidget {
  /// Creates a responsive landing-page section placeholder.
  const LandingSectionPlaceholder({
    required this.desktopMinHeight,
    required this.backgroundColor,
    this.padding = EdgeInsets.zero,
    this.maxContentWidth,
    this.child,
    super.key,
  });

  /// Temporary minimum height from the desktop design.
  final double desktopMinHeight;

  /// Section-level background color from Figma.
  final Color backgroundColor;

  /// Optional section inset needed to represent its outer treatment.
  final EdgeInsetsGeometry padding;

  /// Optional maximum width for the section's eventual inner content.
  final double? maxContentWidth;

  /// Optional established content that is safe to show during scaffolding.
  final Widget? child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : AppSizes.desktopPageWidth;
      final widthScale = (width / AppSizes.desktopPageWidth).clamp(0.65, 1.0);

      return ColoredBox(
        color: backgroundColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: desktopMinHeight * widthScale,
          ),
          child: Padding(
            padding: padding,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxContentWidth ?? double.infinity,
                ),
                child: SizedBox(width: double.infinity, child: child),
              ),
            ),
          ),
        ),
      );
    },
  );
}
