import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Text content shared by all landing Hero compositions.
final class HeroContent extends StatelessWidget {
  /// Creates the landing hero content.
  const HeroContent({
    required this.headlineSize,
    required this.supportingStyle,
    this.headlineLineHeight,
    this.headlineToSupportingSpacing = 16,
    this.textAlign = TextAlign.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    super.key,
  });

  /// Responsive headline font size.
  final double headlineSize;

  /// Responsive supporting-copy style.
  final TextStyle supportingStyle;

  /// Optional responsive headline line height.
  final double? headlineLineHeight;

  /// Spacing between the headline and supporting copy.
  final double headlineToSupportingSpacing;

  /// Alignment of the headline and supporting copy.
  final TextAlign textAlign;

  /// Cross-axis alignment of the complete content group.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final headlineLeading = context.l10n.landingHeroHeadlineLeading;
    final headlineEmphasis = context.l10n.landingHeroHeadlineEmphasis;
    final headlineLabel = '$headlineLeading $headlineEmphasis';
    final headlineLetterSpacing = headlineSize * -0.03;
    final headlineStyle = LandingTextStyles.heroHeadline.copyWith(
      fontSize: headlineSize,
      height: headlineLineHeight == null
          ? null
          : headlineLineHeight! / headlineSize,
      letterSpacing: headlineLetterSpacing,
    );
    final emphasisStyle = LandingTextStyles.heroHeadlineEmphasis.copyWith(
      fontSize: headlineSize,
      height: headlineLineHeight == null
          ? null
          : headlineLineHeight! / headlineSize,
      letterSpacing: headlineLetterSpacing,
    );

    return Column(
      key: const Key('heroContentBounds'),
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionEyebrow(
          label: context.l10n.landingHeroEyebrow,
          glyphAsset: AppAssets.heroEyebrowGlyph,
          foregroundColor: AppColors.blueMain,
          glyphSize: const Size(18, 12),
          alignment: textAlign == TextAlign.center
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          textAlign: textAlign,
          glyphKey: const Key('heroEyebrowGlyph'),
        ),
        const SizedBox(height: 14),
        Semantics(
          key: const Key('heroHeadlineSemantics'),
          label: headlineLabel,
          header: true,
          excludeSemantics: true,
          child: Text.rich(
            key: const Key('heroHeadlineText'),
            TextSpan(
              text: '$headlineLeading ',
              style: headlineStyle,
              children: [
                TextSpan(
                  text: headlineEmphasis,
                  style: emphasisStyle,
                ),
              ],
            ),
            textAlign: textAlign,
          ),
        ),
        SizedBox(height: headlineToSupportingSpacing),
        Text(
          context.l10n.landingHeroSupporting,
          key: const Key('heroSupportingText'),
          textAlign: textAlign,
          style: supportingStyle,
        ),
      ],
    );
  }
}
