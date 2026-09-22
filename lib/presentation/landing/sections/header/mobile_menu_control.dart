import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';

/// Outlined menu or close control used by the mobile landing navigation.
final class MobileMenuControl extends StatefulWidget {
  /// Creates a mobile menu control.
  const MobileMenuControl({
    required this.semanticLabel,
    required this.iconAsset,
    required this.onPressed,
    this.expanded,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  /// Localized accessible action label.
  final String semanticLabel;

  /// Exact Figma icon asset rendered inside the control.
  final String iconAsset;

  /// Invoked when the control is activated.
  final VoidCallback onPressed;

  /// Optional expanded or collapsed state exposed to assistive technology.
  final bool? expanded;

  /// Focus node used for deterministic transfer and restoration.
  final FocusNode? focusNode;

  /// Whether this control should receive initial route focus.
  final bool autofocus;

  @override
  State<MobileMenuControl> createState() => _MobileMenuControlState();
}

final class _MobileMenuControlState extends State<MobileMenuControl> {
  static const _targetSize = 44.0;
  static const _visualSize = 38.0;
  static const _radius = BorderRadius.all(Radius.circular(AppSizes.pillRadius));

  bool _isFocused = false;

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.semanticLabel,
    container: true,
    button: true,
    expanded: widget.expanded,
    onTap: widget.onPressed,
    excludeSemantics: true,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: _isFocused ? AppColors.energeticPlum : Colors.transparent,
          width: 2,
        ),
        borderRadius: _radius,
      ),
      child: SizedBox.square(
        dimension: _targetSize,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            onTap: widget.onPressed,
            onFocusChange: (value) => setState(() => _isFocused = value),
            excludeFromSemantics: true,
            mouseCursor: SystemMouseCursors.click,
            focusColor: Colors.transparent,
            hoverColor: AppColors.warmOrange.withValues(alpha: 0.06),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: _radius,
            child: Align(
              alignment: Alignment.centerRight,
              child: DecoratedBox(
                key: const Key('mobileMenuControlVisual'),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.warmOrange.withValues(alpha: 0.2),
                  ),
                  borderRadius: _radius,
                ),
                child: SizedBox.square(
                  dimension: _visualSize,
                  child: Center(
                    child: SvgPicture.asset(
                      widget.iconAsset,
                      key: const Key('mobileMenuControlIcon'),
                      width: 20,
                      height: 20,
                      excludeFromSemantics: true,
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
