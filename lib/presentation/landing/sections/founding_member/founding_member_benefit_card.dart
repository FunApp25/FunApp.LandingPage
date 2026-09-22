import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// One static benefit in the Founding Member explanation section.
final class FoundingMemberBenefitCard extends StatelessWidget {
  /// Creates a Founding Member benefit card.
  const FoundingMemberBenefitCard({
    required this.semanticId,
    required this.iconAsset,
    required this.title,
    required this.body,
    required this.usesCoordinatedHeight,
    super.key,
  });

  /// Stable test identifier that is not displayed.
  final String semanticId;

  /// Exact local Figma SVG for the card.
  final String iconAsset;

  /// Localized benefit title.
  final String title;

  /// Localized benefit explanation.
  final String body;

  /// Whether the card participates in an equal-height multi-column row.
  final bool usesCoordinatedHeight;

  @override
  Widget build(BuildContext context) => Semantics(
    key: Key('foundingMemberCardSemantics-$semanticId'),
    container: true,
    explicitChildNodes: true,
    child: ConstrainedBox(
      key: Key('foundingMemberCardBounds-$semanticId'),
      constraints: BoxConstraints(
        minHeight: usesCoordinatedHeight ? 360 : 0,
      ),
      child: DecoratedBox(
        key: Key('foundingMemberCardSurface-$semanticId'),
        decoration: const BoxDecoration(
          color: AppColors.lightForeground,
          borderRadius: BorderRadius.all(
            Radius.circular(AppSizes.cardRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.yellowAccent,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SvgPicture.asset(
                    iconAsset,
                    key: Key('foundingMemberIcon-$semanticId'),
                    width: 28,
                    height: 28,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              if (!usesCoordinatedHeight) const SizedBox(height: 48),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    key: Key('foundingMemberCardTitleSemantics-$semanticId'),
                    label: title,
                    header: true,
                    excludeSemantics: true,
                    child: Text(
                      title,
                      key: Key('foundingMemberCardTitle-$semanticId'),
                      style: LandingTextStyles.foundingMemberCardTitle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    key: Key('foundingMemberCardBody-$semanticId'),
                    style: LandingTextStyles.compactSectionBody,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
