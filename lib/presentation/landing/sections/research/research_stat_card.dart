import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// One presentation-only statistic card from Figma node `2190:1587`.
final class ResearchStatCard extends StatelessWidget {
  /// Creates a research statistic card.
  const ResearchStatCard({
    required this.value,
    required this.description,
    required this.usesDesktopMinimumHeight,
    super.key,
  });

  /// Horizontal inset shared by the card and mobile-height calculation.
  static const horizontalPadding = 36.0;

  /// Vertical inset shared by the card and mobile-height calculation.
  static const verticalPadding = 32.0;

  /// Minimum separation between the statistic and its explanation.
  static const minimumContentSeparation = 40.0;

  /// Localized percentage value as displayed in Figma.
  final String value;

  /// Localized explanation that follows [value] in reading order.
  final String description;

  /// Whether this card participates in a bounded, coordinated-height layout.
  final bool usesDesktopMinimumHeight;

  @override
  Widget build(BuildContext context) => Semantics(
    key: Key('researchStatCardSemantics-$value'),
    container: true,
    explicitChildNodes: true,
    child: ConstrainedBox(
      key: Key('researchStatCardBounds-$value'),
      // Figma's 404px minimum coordinates multi-column rows and the mobile
      // carousel. An unbounded stacked card follows localized content instead.
      constraints: BoxConstraints(
        minHeight: usesDesktopMinimumHeight ? 404 : 0,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.lightForeground,
          borderRadius: BorderRadius.all(
            Radius.circular(AppSizes.cardRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            mainAxisSize: usesDesktopMinimumHeight
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: usesDesktopMinimumHeight
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                key: Key('researchStatValue-$value'),
                style: LandingTextStyles.statValue,
              ),
              if (!usesDesktopMinimumHeight)
                const SizedBox(height: minimumContentSeparation),
              Text(
                description,
                key: Key('researchStatDescription-$value'),
                style: LandingTextStyles.statBody,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
