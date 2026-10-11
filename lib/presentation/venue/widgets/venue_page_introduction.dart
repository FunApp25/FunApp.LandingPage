import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Introductory Venue sign-up copy from the approved desktop and mobile frames.
final class VenuePageIntroduction extends StatelessWidget {
  /// Creates the Venue page introduction.
  const VenuePageIntroduction({required this.mobile, super.key});

  /// Whether to use the approved 390px typography and wrapping treatment.
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final headingStyle = LandingTextStyles.heroHeadline.copyWith(
      fontSize: mobile ? 36 : 60,
      height: mobile ? 46 / 36 : 70 / 60,
      letterSpacing: mobile ? -1.08 : -1.8,
    );
    final bodyStyle = AppTextStyles.bodyFontStyle(
      fontSize: mobile ? 16 : 18,
      fontWeight: FontWeight.w500,
      height: mobile ? 24 / 16 : 26 / 18,
      letterSpacing: mobile ? 0.32 : 0.36,
      color: AppColors.bodyGray,
    );

    return ConstrainedBox(
      key: const Key('venuePageIntroduction'),
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionEyebrow(
            label: l10n.venuePageEyebrow.toUpperCase(),
            glyphAsset: mobile
                ? AppAssets.venuePageEyebrowMobile
                : AppAssets.heroEyebrowGlyph,
            foregroundColor: AppColors.blueMain,
            glyphSize: Size(18, mobile ? 16 : 12),
            glyphKey: const Key('venuePageEyebrowGlyph'),
            alignment: MainAxisAlignment.center,
            crossAxisAlignment: mobile
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            spacing: mobile ? 8 : 10,
            textAlign: mobile ? TextAlign.start : TextAlign.center,
          ),
          const SizedBox(height: 14),
          Semantics(
            header: true,
            child: Text(
              l10n.venuePageHeading,
              key: const Key('venuePageHeading'),
              textAlign: TextAlign.center,
              style: headingStyle,
            ),
          ),
          SizedBox(height: mobile ? 14 : 16),
          Text(
            l10n.venuePageIntroFirst,
            key: const Key('venuePageIntroFirst'),
            textAlign: TextAlign.center,
            style: bodyStyle,
          ),
          SizedBox(height: mobile ? 8 : 12),
          Text(
            l10n.venuePageIntroSecond,
            key: const Key('venuePageIntroSecond'),
            textAlign: TextAlign.center,
            style: bodyStyle,
          ),
        ],
      ),
    );
  }
}
