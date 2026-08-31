import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/section_eyebrow.dart';

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
              child: _WelcomeStatementContent(
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

final class _WelcomeStatementContent extends StatelessWidget {
  const _WelcomeStatementContent({required this.statementSize});

  final double statementSize;

  @override
  Widget build(BuildContext context) {
    final eyebrow = context.l10n.landingWelcomeEyebrow;
    final leading = context.l10n.landingWelcomeStatementLeading;
    final emphasis = context.l10n.landingWelcomeStatementEmphasis;
    final semanticLabel = '$leading $emphasis';
    final letterSpacing = statementSize * -0.01;
    final regularStyle = AppTextStyles.landingFoundingOfferStatement.copyWith(
      fontSize: statementSize,
      letterSpacing: letterSpacing,
    );
    final emphasisStyle = AppTextStyles.landingFoundingOfferStatementEmphasis
        .copyWith(
          fontSize: statementSize,
          letterSpacing: letterSpacing,
          color: AppColors.warmOrange,
        );

    return Column(
      key: const Key('welcomeStatementContent'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          key: const Key('welcomeEyebrowSemantics'),
          label: eyebrow,
          excludeSemantics: true,
          child: SectionEyebrow(
            label: eyebrow.toUpperCase(),
            glyphAsset: AppAssets.welcomeGlyph,
            foregroundColor: AppColors.blueMain,
            glyphSize: const Size(21, 12),
            alignment: MainAxisAlignment.center,
            textAlign: TextAlign.center,
            glyphKey: const Key('welcomeEyebrowGlyph'),
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 728),
          child: Semantics(
            key: const Key('welcomeStatementSemantics'),
            label: semanticLabel,
            header: true,
            excludeSemantics: true,
            child: Text.rich(
              key: const Key('welcomeStatementText'),
              TextSpan(
                text: '$leading ',
                style: regularStyle,
                children: [
                  TextSpan(text: emphasis, style: emphasisStyle),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
