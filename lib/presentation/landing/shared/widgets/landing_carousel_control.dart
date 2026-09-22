import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';

/// One accessible previous or next control for a landing mobile carousel.
final class LandingCarouselControl extends StatefulWidget {
  /// Creates a carousel direction control.
  const LandingCarouselControl({
    required this.semanticLabel,
    required this.onPressed,
    required this.pointsForward,
    super.key,
  });

  /// Localized action label exposed to assistive technology.
  final String semanticLabel;

  /// Invoked when this direction is available, or null at a clamped edge.
  final VoidCallback? onPressed;

  /// Whether the arrow points in the reading direction rather than against it.
  final bool pointsForward;

  @override
  State<LandingCarouselControl> createState() => _LandingCarouselControlState();
}

final class _LandingCarouselControlState extends State<LandingCarouselControl> {
  static const _targetSize = 44.0;
  static const _visualSize = 40.0;
  static const _focusRadius = BorderRadius.all(Radius.circular(22));

  final _focusNode = FocusNode();
  bool _isFocused = false;

  bool get _isEnabled => widget.onPressed != null;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final activates =
        event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space);

    if (activates && _isEnabled) {
      widget.onPressed!();
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }

  void _activate() {
    if (_isEnabled) {
      _focusNode.requestFocus();
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final pointsRight = widget.pointsForward
        ? textDirection == TextDirection.ltr
        : textDirection == TextDirection.rtl;

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: _isEnabled,
      onTap: _isEnabled ? _activate : null,
      excludeSemantics: true,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (value) => setState(() => _isFocused = value),
        onKeyEvent: _handleKeyEvent,
        child: MouseRegion(
          cursor: _isEnabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _isEnabled ? _activate : null,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isFocused
                      ? AppColors.energeticPlum
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: _focusRadius,
              ),
              child: SizedBox.square(
                dimension: _targetSize,
                child: Center(
                  child: DecoratedBox(
                    key: const Key('landingCarouselControlVisual'),
                    decoration: const BoxDecoration(
                      color: AppColors.lightForeground,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: _visualSize,
                      child: Center(
                        child: Transform.rotate(
                          angle: pointsRight ? 0 : 3.141592653589793,
                          child: SvgPicture.asset(
                            AppAssets.carouselArrowRight,
                            key: const Key('landingCarouselControlIcon'),
                            width: 18,
                            height: 15,
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
        ),
      ),
    );
  }
}
