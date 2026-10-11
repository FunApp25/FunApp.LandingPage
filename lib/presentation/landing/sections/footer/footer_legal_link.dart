import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Accessible footer link for an established or review-only legal route.
final class FooterLegalLink extends StatefulWidget {
  /// Creates a footer legal link.
  const FooterLegalLink({
    required this.semanticKey,
    required this.label,
    required this.onSelected,
    super.key,
  });

  /// Stable key for the exposed link semantics.
  final Key semanticKey;

  /// Localized visible and accessible label.
  final String label;

  /// Opens the established or explicitly review-only destination.
  final VoidCallback onSelected;

  @override
  State<FooterLegalLink> createState() => _FooterLegalLinkState();
}

final class _FooterLegalLinkState extends State<FooterLegalLink> {
  static const _radius = BorderRadius.all(Radius.circular(4));

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
      key: widget.semanticKey,
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
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: LandingTextStyles.footerLegal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
