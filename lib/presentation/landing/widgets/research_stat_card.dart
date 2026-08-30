import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';

/// One presentation-only statistic card from Figma node `2190:1587`.
final class ResearchStatCard extends StatelessWidget {
  /// Creates a research statistic card.
  const ResearchStatCard({
    required this.value,
    required this.description,
    super.key,
  });

  /// Localized percentage value as displayed in Figma.
  final String value;

  /// Localized explanation that follows [value] in reading order.
  final String description;

  @override
  Widget build(BuildContext context) => Semantics(
    key: Key('researchStatCardSemantics-$value'),
    container: true,
    explicitChildNodes: true,
    child: ConstrainedBox(
      // Figma's English desktop cards are 404px tall. Treat that as a
      // minimum so narrower cards and longer translations can grow naturally.
      constraints: const BoxConstraints(minHeight: 404),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.lightForeground,
          borderRadius: BorderRadius.all(
            Radius.circular(AppSizes.cardRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 36,
            vertical: 32,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                key: Key('researchStatValue-$value'),
                style: AppTextStyles.landingStatValue,
              ),
              Text(
                description,
                key: Key('researchStatDescription-$value'),
                style: AppTextStyles.landingStatBody,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
