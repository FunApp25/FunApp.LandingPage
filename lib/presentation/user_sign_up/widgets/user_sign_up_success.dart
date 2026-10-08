import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Confirmed Here & Now submission presentation for injected safe states.
final class UserSignUpSuccess extends StatefulWidget {
  /// Creates the branded Here & Now confirmation.
  const UserSignUpSuccess({required this.mobile, super.key});

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

    return ConstrainedBox(
      key: const Key('hereAndNowSuccess'),
      constraints: BoxConstraints(minHeight: widget.mobile ? 332 : 478),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionEyebrow(
                label: l10n.userSignUpHereAndNowEyebrow.toUpperCase(),
                glyphAsset: AppAssets.heroEyebrowGlyph,
                foregroundColor: AppColors.blueMain,
                glyphSize: Size(18, widget.mobile ? 16 : 12),
                alignment: MainAxisAlignment.center,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Focus(
                key: const Key('hereAndNowSuccessHeadingFocus'),
                focusNode: _headingFocusNode,
                onFocusChange: (hasFocus) {
                  if (mounted && hasFocus != _headingHasFocus) {
                    setState(() => _headingHasFocus = hasFocus);
                  }
                },
                child: Semantics(
                  key: const Key('hereAndNowSuccessHeadingSemantics'),
                  container: true,
                  header: true,
                  liveRegion: true,
                  focusable: true,
                  focused: _headingHasFocus,
                  child: Text(
                    l10n.userSignUpHereAndNowSuccessHeading,
                    key: const Key('hereAndNowSuccessHeading'),
                    textAlign: TextAlign.center,
                    style: headingStyle,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.userSignUpHereAndNowSuccessBody,
                key: const Key('hereAndNowSuccessBody'),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyFontStyle(
                  fontSize: widget.mobile ? 16 : 18,
                  fontWeight: FontWeight.w500,
                  height: widget.mobile ? 24 / 16 : 26 / 18,
                  letterSpacing: widget.mobile ? 0.32 : 0.36,
                  color: AppColors.bodyGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
