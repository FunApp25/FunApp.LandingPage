import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';

/// Presentation-local acknowledgement toggle for the Venue form.
final class VenuePrivacyAcknowledgementCheckbox extends StatefulWidget {
  /// Creates an unchecked acknowledgement toggle.
  const VenuePrivacyAcknowledgementCheckbox({
    required this.semanticLabel,
    super.key,
  });

  /// Accessible name associated with the visible acknowledgement copy.
  final String semanticLabel;

  @override
  State<VenuePrivacyAcknowledgementCheckbox> createState() =>
      _VenuePrivacyAcknowledgementCheckboxState();
}

final class _VenuePrivacyAcknowledgementCheckboxState
    extends State<VenuePrivacyAcknowledgementCheckbox> {
  final _focusNode = FocusNode();
  var _isAcknowledged = false;
  var _isFocused = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isAcknowledged = !_isAcknowledged);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    key: const Key('venuePrivacyAcknowledgementCheckbox'),
    label: widget.semanticLabel,
    checked: _isAcknowledged,
    onTap: _toggle,
    excludeSemantics: true,
    child: Focus(
      key: const Key('venuePrivacyAcknowledgementFocus'),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggle,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(8),
          focusColor: Colors.transparent,
          hoverColor: AppColors.warmOrange.withValues(alpha: 0.06),
          splashColor: AppColors.warmOrange.withValues(alpha: 0.10),
          highlightColor: Colors.transparent,
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: DecoratedBox(
                key: const Key('venuePrivacyAcknowledgementVisual'),
                decoration: BoxDecoration(
                  color: _isAcknowledged
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
                  dimension: 16,
                  child: _isAcknowledged
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: AppColors.lightForeground,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
