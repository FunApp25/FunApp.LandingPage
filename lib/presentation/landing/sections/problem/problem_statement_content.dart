import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Centered copy composition for the problem statement section.
final class ProblemStatementContent extends StatelessWidget {
  /// Creates the problem statement content.
  const ProblemStatementContent({required this.statementSize, super.key});

  /// Responsive statement font size.
  final double statementSize;

  @override
  Widget build(BuildContext context) {
    final leading = context.l10n.landingProblemStatementLeading;
    final emphasis = context.l10n.landingProblemStatementEmphasis;
    final trailing = context.l10n.landingProblemStatementTrailing;
    final semanticLabel = '$leading$emphasis$trailing';
    final letterSpacing = statementSize * -0.01;
    final regularStyle = LandingTextStyles.problemStatement.copyWith(
      fontSize: statementSize,
      letterSpacing: letterSpacing,
    );
    final emphasisStyle = LandingTextStyles.problemStatementEmphasis.copyWith(
      fontSize: statementSize,
      letterSpacing: letterSpacing,
    );

    return Column(
      key: const Key('problemStatementContent'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionEyebrow(
          label: context.l10n.landingProblemEyebrow,
          glyphAsset: AppAssets.fiveDiagonalOvals,
          foregroundColor: AppColors.energeticPlum,
          glyphSize: const Size(34, 12),
          alignment: MainAxisAlignment.center,
          textAlign: TextAlign.center,
          glyphKey: const Key('problemEyebrowGlyph'),
        ),
        const SizedBox(height: 24),
        Semantics(
          key: const Key('problemStatementSemantics'),
          label: semanticLabel,
          header: true,
          excludeSemantics: true,
          child: Text.rich(
            key: const Key('problemStatementText'),
            TextSpan(
              text: leading,
              style: regularStyle,
              children: [
                TextSpan(text: emphasis, style: emphasisStyle),
                TextSpan(text: trailing),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
