import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Eyebrow and heading for the connection section.
final class ConnectionTitle extends StatelessWidget {
  /// Creates the connection title.
  const ConnectionTitle({required this.headingSize, super.key});

  /// Responsive heading font size.
  final double headingSize;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionEyebrow(
        label: context.l10n.landingConnectionEyebrow,
        glyphAsset: AppAssets.roundedSparkleDiamond,
        foregroundColor: AppColors.warmOrange,
        glyphSize: const Size.square(12),
        glyphKey: const Key('connectionEyebrowGlyph'),
      ),
      const SizedBox(height: 16),
      Semantics(
        key: const Key('connectionHeadingSemantics'),
        label: context.l10n.landingConnectionHeading,
        header: true,
        excludeSemantics: true,
        child: Text(
          context.l10n.landingConnectionHeading,
          style: LandingTextStyles.sectionHeading.copyWith(
            fontSize: headingSize,
            letterSpacing: headingSize * -0.01,
          ),
        ),
      ),
    ],
  );
}
