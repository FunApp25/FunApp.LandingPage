import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Text content shared by the wide and responsive hero compositions.
final class HeroContent extends StatelessWidget {
  /// Creates the landing hero content.
  const HeroContent({
    required this.headlineSize,
    required this.supportingStyle,
    super.key,
  });

  /// Responsive headline font size.
  final double headlineSize;

  /// Responsive supporting-copy style.
  final TextStyle supportingStyle;

  @override
  Widget build(BuildContext context) {
    final headlineLeading = context.l10n.landingHeroHeadlineLeading;
    final headlineEmphasis = context.l10n.landingHeroHeadlineEmphasis;
    final headlineLabel = '$headlineLeading $headlineEmphasis';
    final headlineLetterSpacing = headlineSize * -0.03;
    final headlineStyle = LandingTextStyles.heroHeadline.copyWith(
      fontSize: headlineSize,
      letterSpacing: headlineLetterSpacing,
    );
    final emphasisStyle = LandingTextStyles.heroHeadlineEmphasis.copyWith(
      fontSize: headlineSize,
      letterSpacing: headlineLetterSpacing,
    );

    return Column(
      key: const Key('heroContentBounds'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionEyebrow(
          label: context.l10n.landingHeroEyebrow,
          glyphAsset: AppAssets.heroEyebrowGlyph,
          foregroundColor: AppColors.blueMain,
          glyphSize: const Size(18, 12),
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
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.landingHeroSupporting,
          style: supportingStyle,
        ),
      ],
    );
  }
}
