import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_offer/founding_offer_content.dart';

/// Limited-time Founding Friend offer from Figma node `2243:2549`.
final class FoundingOfferSection extends StatelessWidget {
  /// Creates the founding-offer section.
  const FoundingOfferSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: const Key('foundingOfferBackground'),
    color: AppColors.lightForeground,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final usesMobileFidelity = MediaQuery.sizeOf(context).width < 600;
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = usesMobileFidelity
            ? AppSizes.mobileLandingPageGutter
            : AppSizes.pageGutterFor(availableWidth);
        final verticalPadding = usesMobileFidelity
            ? AppSizes.mobileLandingSectionVerticalPadding
            : AppSizes.sectionVerticalPaddingFor(availableWidth);
        final statementSize = usesMobileFidelity
            ? 36.0
            : AppSizes.statementHeadingSizeFor(availableWidth);
        final statementLineHeight = usesMobileFidelity
            ? 46.0
            : statementSize * (60 / 50);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: pageGutter,
            vertical: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 884),
              child: FoundingOfferContent(
                statementSize: statementSize,
                statementLineHeight: statementLineHeight,
              ),
            ),
          ),
        );
      },
    ),
  );
}
