import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';

/// Optional two-choice presentation for the existing string-valued field.
final class VenueChainStatusControl extends StatefulWidget {
  /// Creates the chain status control.
  const VenueChainStatusControl({
    required this.label,
    required this.independentLabel,
    required this.chainLabel,
    required this.selectedValue,
    required this.onSelected,
    super.key,
  });

  /// Localized field heading.
  final String label;

  /// Localized Independent option.
  final String independentLabel;

  /// Localized Part of a chain option.
  final String chainLabel;

  /// Existing draft value, or null when unanswered.
  final String? selectedValue;

  /// Dispatches the stable existing field value, including empty on deselect.
  final ValueChanged<String> onSelected;

  /// Provider-neutral value sent through the existing BLoC event.
  static const independentValue = 'Independent';

  /// Provider-neutral value sent through the existing BLoC event.
  static const chainValue = 'Part of a chain';

  @override
  State<VenueChainStatusControl> createState() =>
      _VenueChainStatusControlState();
}

final class _VenueChainStatusControlState
    extends State<VenueChainStatusControl> {
  String? _focusedValue;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Column(
      key: const Key('venueLeadChainStatusControl'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.lightForeground,
            border: Border.all(
              color: AppColors.warmCharcoal.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _option(
                  context,
                  key: const Key('venueChainIndependentOption'),
                  value: VenueChainStatusControl.independentValue,
                  label: widget.independentLabel,
                  reduceMotion: reduceMotion,
                ),
                _option(
                  context,
                  key: const Key('venueChainPartOfChainOption'),
                  value: VenueChainStatusControl.chainValue,
                  label: widget.chainLabel,
                  reduceMotion: reduceMotion,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _option(
    BuildContext context, {
    required Key key,
    required String value,
    required String label,
    required bool reduceMotion,
  }) {
    final selected = widget.selectedValue == value;
    final focused = _focusedValue == value;
    return Expanded(
      child: Semantics(
        key: key,
        label: label,
        button: true,
        selected: selected,
        onTap: () => widget.onSelected(selected ? '' : value),
        child: ExcludeSemantics(
          child: InkWell(
            onTap: () => widget.onSelected(selected ? '' : value),
            onFocusChange: (hasFocus) => setState(
              () => _focusedValue = hasFocus ? value : null,
            ),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius - 4),
            child: AnimatedContainer(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 170),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: 48),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.energeticPlum : Colors.transparent,
                border: Border.all(
                  color: focused ? AppColors.warmOrange : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppSizes.cardRadius - 4),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? AppColors.lightForeground
                      : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
