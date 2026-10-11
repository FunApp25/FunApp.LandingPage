import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';

/// Shared accessible checkbox whose hover paint stays on the control itself.
final class BrandedFormCheckbox extends StatefulWidget {
  /// Creates a controlled branded checkbox and associated label.
  const BrandedFormCheckbox({
    required this.semanticKey,
    required this.focusKey,
    required this.visualKey,
    required this.label,
    required this.value,
    required this.onChanged,
    this.labelWidget,
    this.preserveLabelSemantics = false,
    super.key,
  });

  /// Stable key for the combined checkbox semantics node.
  final Key semanticKey;

  /// Stable key for the keyboard-focus owner.
  final Key focusKey;

  /// Stable key for the 20px visible checkbox.
  final Key visualKey;

  /// Accessible and default visible label.
  final String label;

  /// Current controlled checked state.
  final bool value;

  /// Reports a mouse, touch, keyboard, or semantics state change.
  final ValueChanged<bool> onChanged;

  /// Optional rich visible label, while [label] remains the accessible name.
  final Widget? labelWidget;

  /// Whether rich descendant semantics, such as an inline link, stay exposed.
  final bool preserveLabelSemantics;

  @override
  State<BrandedFormCheckbox> createState() => _BrandedFormCheckboxState();
}

final class _BrandedFormCheckboxState extends State<BrandedFormCheckbox> {
  final _focusNode = FocusNode();
  var _isFocused = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    key: widget.semanticKey,
    label: widget.label,
    container: widget.preserveLabelSemantics,
    explicitChildNodes: widget.preserveLabelSemantics,
    checked: widget.value,
    onTap: _toggle,
    excludeSemantics: !widget.preserveLabelSemantics,
    child: Focus(
      key: widget.focusKey,
      focusNode: _focusNode,
      canRequestFocus: true,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      onKeyEvent: (node, event) {
        final activatesCheckbox =
            event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter ||
                event.logicalKey == LogicalKeyboardKey.space);
        if (activatesCheckbox) {
          _toggle();
          return KeyEventResult.handled;
        } else {
          return KeyEventResult.ignored;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.square(
              dimension: 44,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: ValueKey<String>(
                    'brandedCheckboxControl-${widget.semanticKey}',
                  ),
                  onTap: _toggle,
                  mouseCursor: SystemMouseCursors.click,
                  borderRadius: BorderRadius.circular(8),
                  focusColor: Colors.transparent,
                  hoverColor: AppColors.warmOrange.withValues(alpha: 0.06),
                  splashColor: AppColors.warmOrange.withValues(alpha: 0.10),
                  highlightColor: Colors.transparent,
                  child: Center(
                    child: DecoratedBox(
                      key: widget.visualKey,
                      decoration: BoxDecoration(
                        color: widget.value
                            ? AppColors.warmOrange
                            : Colors.transparent,
                        border: Border.all(
                          color: _isFocused
                              ? AppColors.energeticPlum
                              : AppColors.warmOrange,
                          width: _isFocused ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SizedBox.square(
                        dimension: 20,
                        child: widget.value
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.lightForeground,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child:
                      widget.labelWidget ??
                      Text(
                        widget.label,
                        style: AppTextStyles.bodyFontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 22 / 14,
                          color: AppColors.bodyGray,
                        ),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
