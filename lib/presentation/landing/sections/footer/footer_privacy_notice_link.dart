import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Accessible footer link to the hosted Privacy Notice page.
final class FooterPrivacyNoticeLink extends StatefulWidget {
  /// Creates the footer Privacy Notice link.
  const FooterPrivacyNoticeLink({
    required this.label,
    required this.onSelected,
    super.key,
  });

  /// Localized visible and semantic label.
  final String label;

  /// Opens the hosted Privacy Notice in a separate tab.
  final VoidCallback onSelected;

  @override
  State<FooterPrivacyNoticeLink> createState() =>
      _FooterPrivacyNoticeLinkState();
}

final class _FooterPrivacyNoticeLinkState
    extends State<FooterPrivacyNoticeLink> {
  static const _minimumTargetHeight = 44.0;
  static const _horizontalPadding = 12.0;
  static const _radius = BorderRadius.all(Radius.circular(10));

  bool _isFocused = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final backgroundColor = _isFocused
        ? AppColors.energeticPlum.withValues(alpha: 0.08)
        : _isHovered
        ? AppColors.energeticPlum.withValues(alpha: 0.06)
        : Colors.transparent;
    final hoverDuration = LandingMotion.duration(
      disableAnimations: disableAnimations || _isFocused,
      normalDuration: LandingMotion.fastDuration,
    );

    return Semantics(
      key: const Key('footerPrivacyNoticeLink'),
      label: widget.label,
      link: true,
      onTap: widget.onSelected,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isFocused ? AppColors.energeticPlum : Colors.transparent,
              width: 2,
            ),
            borderRadius: _radius,
          ),
          position: DecorationPosition.foreground,
          child: AnimatedContainer(
            duration: hoverDuration,
            curve: LandingMotion.standardCurve,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: _radius,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onSelected,
                onHover: (value) => setState(() => _isHovered = value),
                onFocusChange: (value) => setState(() => _isFocused = value),
                mouseCursor: SystemMouseCursors.click,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                borderRadius: _radius,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: _minimumTargetHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _horizontalPadding,
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: LandingTextStyles.headerNavigation.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
