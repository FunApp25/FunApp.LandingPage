import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';

/// Controlled, optional marketing opt-in for a user sign-up form.
final class UserSignUpMarketingConsent extends StatefulWidget {
  /// Creates an accessible marketing-consent row.
  const UserSignUpMarketingConsent({
    required this.semanticId,
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Stable form-specific test and semantics identifier.
  final String semanticId;

  /// Exact approved opt-in copy.
  final String label;

  /// Current explicit opt-in value.
  final bool value;

  /// Reports an independently toggled value.
  final ValueChanged<bool> onChanged;

  @override
  State<UserSignUpMarketingConsent> createState() =>
      _UserSignUpMarketingConsentState();
}

final class _UserSignUpMarketingConsentState
    extends State<UserSignUpMarketingConsent> {
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
    key: Key('marketingConsent-${widget.semanticId}'),
    label: widget.label,
    checked: widget.value,
    onTap: _toggle,
    excludeSemantics: true,
    child: Focus(
      key: Key('marketingConsentFocus-${widget.semanticId}'),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: DecoratedBox(
                    key: Key('marketingConsentVisual-${widget.semanticId}'),
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
                      dimension: 16,
                      child: widget.value
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: AppColors.lightForeground,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.bodyGray,
                      height: 22 / 14,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
