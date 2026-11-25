import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/footer_email.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';

/// Confirmed registration-interest presentation for application success.
final class UserSignUpSuccess extends StatefulWidget {
  /// Creates the branded confirmation for [experience].
  const UserSignUpSuccess({
    required this.experience,
    required this.mobile,
    super.key,
  });

  /// Registration workflow whose submission was confirmed.
  final UserSignUpExperience experience;

  /// Whether the page uses its mobile composition.
  final bool mobile;

  @override
  State<UserSignUpSuccess> createState() => _UserSignUpSuccessState();
}

final class _UserSignUpSuccessState extends State<UserSignUpSuccess> {
  final _headingFocusNode = FocusNode(debugLabel: 'userSignUpSuccessHeading');
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
    final (:heading, :emphasis, :body) = switch (widget.experience) {
      UserSignUpExperience.hereAndNow => (
        heading: l10n.userSignUpHereAndNowSuccessHeading,
        emphasis: l10n.userSignUpHereAndNowSuccessHeadingEmphasis,
        body: l10n.userSignUpHereAndNowSuccessBody,
      ),
      UserSignUpExperience.foundingFriend => (
        heading:
            '${l10n.venueSuccessHeadingLeading} '
            '${l10n.venueSuccessHeadingEmphasis}',
        emphasis: l10n.venueSuccessHeadingEmphasis,
        body: null,
      ),
    };
    final leading = heading.endsWith(emphasis)
        ? heading.substring(0, heading.length - emphasis.length)
        : heading;
    final semanticId = widget.experience.name;

    return ConstrainedBox(
      key: Key('${semanticId}Success'),
      constraints: BoxConstraints(minHeight: widget.mobile ? 426 : 552),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.mobile ? 16 : 40,
          vertical: widget.mobile ? 80 : 128,
        ),
        child: Center(
          child: ConstrainedBox(
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
                  crossAxisAlignment: widget.mobile
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  spacing: widget.mobile ? 8 : 10,
                  alignment: MainAxisAlignment.center,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Focus(
                  key: Key('${semanticId}SuccessHeadingFocus'),
                  focusNode: _headingFocusNode,
                  onFocusChange: (hasFocus) {
                    if (mounted && hasFocus != _headingHasFocus) {
                      setState(() => _headingHasFocus = hasFocus);
                    }
                  },
                  child: Semantics(
                    key: Key('${semanticId}SuccessHeadingSemantics'),
                    container: true,
                    header: true,
                    liveRegion: true,
                    focusable: true,
                    focused: _headingHasFocus,
                    label: heading,
                    excludeSemantics: true,
                    child: Text.rich(
                      TextSpan(
                        text: leading,
                        style: headingStyle,
                        children: [
                          TextSpan(text: emphasis, style: emphasisStyle),
                        ],
                      ),
                      key: Key('${semanticId}SuccessHeading'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (body != null) ...[
                  SizedBox(height: widget.mobile ? 14 : 16),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Text(
                        body,
                        key: Key('${semanticId}SuccessBody'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyFontStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 26 / 18,
                          letterSpacing: 0.36,
                          color: AppColors.bodyGray,
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: widget.mobile ? 16 : 24),
                Center(
                  child: FooterEmail(
                    email: LandingFooter.contactEmail,
                    semanticKey: Key('${semanticId}SuccessEmailSemantics'),
                    envelopeKey: Key('${semanticId}SuccessEnvelope'),
                    textKey: Key('${semanticId}SuccessEmailText'),
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
