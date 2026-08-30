import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';

/// Accessible in-page navigation control shared by the landing header/footer.
final class LandingNavigationItem extends StatefulWidget {
  /// Creates an in-page navigation item.
  const LandingNavigationItem({
    required this.label,
    required this.onSelected,
    super.key,
  });

  /// Localized visible and semantic label.
  final String label;

  /// Scrolls the landing page to the corresponding section.
  final VoidCallback onSelected;

  @override
  State<LandingNavigationItem> createState() => _LandingNavigationItemState();
}

final class _LandingNavigationItemState extends State<LandingNavigationItem> {
  static const _minimumTargetHeight = 44.0;
  static const _horizontalPadding = 12.0;
  static const _radius = BorderRadius.all(Radius.circular(10));

  bool _isFocused = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasVisualState = _isFocused || _isHovered;

    return Semantics(
      label: widget.label,
      button: true,
      onTap: widget.onSelected,
      excludeSemantics: true,
      child: Material(
        key: const Key('landingNavigationVisualSurface'),
        color: hasVisualState
            ? AppColors.energeticPlum.withValues(
                alpha: _isFocused ? 0.08 : 0.06,
              )
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(
            color: _isFocused ? AppColors.energeticPlum : Colors.transparent,
            width: 2,
          ),
        ),
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
            constraints: const BoxConstraints(minHeight: _minimumTargetHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  widget.label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.landingHeaderNavigation,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
