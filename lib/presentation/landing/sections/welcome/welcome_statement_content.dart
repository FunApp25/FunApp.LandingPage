import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Centered copy composition for the welcome statement section.
final class WelcomeStatementContent extends StatelessWidget {
  /// Creates the welcome statement content.
  const WelcomeStatementContent({required this.statementSize, super.key});

  /// Responsive statement font size.
  final double statementSize;

  @override
  Widget build(BuildContext context) {
    final eyebrow = context.l10n.landingWelcomeEyebrow;
    final leading = context.l10n.landingWelcomeStatementLeading;
    final emphasis = context.l10n.landingWelcomeStatementEmphasis;
    final semanticLabel = '$leading $emphasis';
    final letterSpacing = statementSize * -0.01;
    final regularStyle = LandingTextStyles.foundingOfferStatement.copyWith(
      fontSize: statementSize,
      letterSpacing: letterSpacing,
    );
    final emphasisStyle = LandingTextStyles.foundingOfferStatementEmphasis
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
