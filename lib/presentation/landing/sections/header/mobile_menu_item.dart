import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Accessible destination control used by the full-screen mobile menu.
final class MobileMenuItem extends StatefulWidget {
  /// Creates a mobile menu destination.
  const MobileMenuItem({
    required this.label,
    required this.onSelected,
    super.key,
  });

  /// Localized visible and semantic label.
  final String label;

  /// Closes the menu with this destination selected.
  final VoidCallback onSelected;

  @override
  State<MobileMenuItem> createState() => _MobileMenuItemState();
}

final class _MobileMenuItemState extends State<MobileMenuItem> {
  static const _minimumTargetHeight = 44.0;
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
      label: widget.label,
      container: true,
      button: true,
      onTap: widget.onSelected,
      excludeSemantics: true,
      child: DecoratedBox(
        key: const Key('mobileMenuItemVisualSurface'),
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
              excludeFromSemantics: true,
              mouseCursor: SystemMouseCursors.click,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              borderRadius: _radius,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: _minimumTargetHeight,
                  minWidth: double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      widget.label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: LandingTextStyles.mobileMenuNavigation,
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
