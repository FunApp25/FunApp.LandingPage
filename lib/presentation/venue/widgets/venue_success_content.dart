import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_email.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Full-page Venue confirmation content from Figma nodes `2733:2857` and
/// `2733:3031`.
final class VenueSuccessContent extends StatefulWidget {
  /// Creates the confirmed Venue submission presentation.
  const VenueSuccessContent({required this.mobile, super.key});

  /// Whether to use the approved mobile geometry and typography.
  final bool mobile;

  @override
  State<VenueSuccessContent> createState() => _VenueSuccessContentState();
}

final class _VenueSuccessContentState extends State<VenueSuccessContent> {
  final _headingFocusNode = FocusNode(debugLabel: 'venueSuccessHeading');
  var _headingHasFocus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _headingFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _headingFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final headingStyle = LandingTextStyles.heroHeadline.copyWith(
      fontSize: widget.mobile ? 36 : 60,
      height: widget.mobile ? 46 / 36 : 70 / 60,
      letterSpacing: widget.mobile ? -1.08 : -1.8,
    );
    final emphasisStyle = LandingTextStyles.heroHeadlineEmphasis.copyWith(
      fontSize: widget.mobile ? 36 : 60,
      height: widget.mobile ? 46 / 36 : 70 / 60,
      letterSpacing: widget.mobile ? -1.08 : -1.8,
    );
    final fullHeading =
        '${l10n.venueSuccessHeadingLeading} '
        '${l10n.venueSuccessHeadingEmphasis}';

    return ConstrainedBox(
      key: const Key('venueSuccessContent'),
      constraints: BoxConstraints(
        minHeight: widget.mobile ? 332 : 478,
      ),
      child: Padding(
        key: const Key('venueSuccessCardPadding'),
        padding: EdgeInsets.symmetric(
          horizontal: widget.mobile ? 16 : 40,
          vertical: widget.mobile ? 80 : 128,
        ),
        child: Center(
          child: ConstrainedBox(
            key: const Key('venueSuccessTextGroup'),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionEyebrow(
                  label: l10n.venueSuccessEyebrow.toUpperCase(),
                  glyphAsset: widget.mobile
                      ? AppAssets.venuePageEyebrowMobile
                      : AppAssets.heroEyebrowGlyph,
                  foregroundColor: AppColors.blueMain,
                  glyphSize: Size(18, widget.mobile ? 16 : 12),
                  glyphKey: const Key('venueSuccessEyebrowGlyph'),
                  alignment: MainAxisAlignment.center,
                  crossAxisAlignment: widget.mobile
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  spacing: widget.mobile ? 8 : 10,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Focus(
                  key: const Key('venueSuccessHeadingFocus'),
                  focusNode: _headingFocusNode,
                  onFocusChange: (hasFocus) {
                    if (mounted && hasFocus != _headingHasFocus) {
                      setState(() => _headingHasFocus = hasFocus);
                    }
                  },
                  child: Semantics(
                    key: const Key('venueSuccessHeadingSemantics'),
                    container: true,
                    header: true,
                    liveRegion: true,
                    focusable: true,
                    focused: _headingHasFocus,
                    label: fullHeading,
                    excludeSemantics: true,
                    child: Text.rich(
                      TextSpan(
                        text: '${l10n.venueSuccessHeadingLeading} ',
                        style: headingStyle,
                        children: [
                          TextSpan(
                            text: l10n.venueSuccessHeadingEmphasis,
                            style: emphasisStyle,
                          ),
                        ],
                      ),
                      key: const Key('venueSuccessHeading'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: widget.mobile ? 14 : 16),
                const Center(
                  child: FooterEmail(
                    email: LandingFooter.contactEmail,
                    semanticKey: Key('venueSuccessEmailSemantics'),
                    envelopeKey: Key('venueSuccessEnvelope'),
                    textKey: Key('venueSuccessEmailText'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
