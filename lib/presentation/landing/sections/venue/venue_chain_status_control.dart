import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';

/// Optional two-choice presentation for the existing string-valued field.
final class VenueChainStatusControl extends StatefulWidget {
  /// Creates the chain status control.
  const VenueChainStatusControl({
    required this.label,
    required this.independentLabel,
    required this.chainLabel,
    required this.selectedValue,
    required this.onSelected,
    this.placeholder,
    this.alignWithVenuePageDesign = false,
    super.key,
  });

  /// Localized field heading.
  final String label;

  /// Localized Independent option.
  final String independentLabel;

  /// Localized Part of chain option.
  final String chainLabel;

  /// Existing draft value, or null when unanswered.
  final String? selectedValue;

  /// Dispatches the stable existing field value, including empty on deselect.
  final ValueChanged<String> onSelected;

  /// Localized unselected prompt for the routed-page presentation.
  final String? placeholder;

  /// Whether to use the approved routed-page dropdown treatment.
  final bool alignWithVenuePageDesign;

  /// Provider-neutral value sent through the existing BLoC event.
  static const independentValue = 'Independent';

  /// Provider-neutral value sent through the existing BLoC event.
  static const chainValue = 'Part of chain';

  @override
  State<VenueChainStatusControl> createState() =>
      _VenueChainStatusControlState();
}

final class _VenueChainStatusControlState
    extends State<VenueChainStatusControl> {
  String? _focusedValue;
  var _figmaControlFocused = false;

  @override
  Widget build(BuildContext context) {
    if (widget.alignWithVenuePageDesign) {
      return _buildFigmaControl(context);
    } else {
      return _buildLegacyControl(context);
    }
  }

  Widget _buildFigmaControl(BuildContext context) {
    final selectedLabel = switch (widget.selectedValue) {
      VenueChainStatusControl.independentValue => widget.independentLabel,
      VenueChainStatusControl.chainValue => widget.chainLabel,
      _ => null,
    };
    final displayedValue = selectedLabel ?? widget.placeholder ?? widget.label;
    final valueStyle = AppTextStyles.bodyFontStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.bodyGray,
    );

    return Semantics(
      label: widget.label,
      value: displayedValue,
      child: Column(
        key: const Key('venueLeadChainStatusControl'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            style: AppTextStyles.bodyFontStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: AppColors.warmCharcoal,
            ),
          ),
          const SizedBox(height: 4),
          Focus(
            onFocusChange: (focused) =>
                setState(() => _figmaControlFocused = focused),
            child: PopupMenuButton<String>(
              key: const Key('venueLeadChainStatusMenu'),
              tooltip: widget.label,
              offset: const Offset(0, 8),
              color: AppColors.lightForeground,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              onSelected: (value) => widget.onSelected(
                value == widget.selectedValue ? '' : value,
              ),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  key: const Key('venueChainIndependentOption'),
                  value: VenueChainStatusControl.independentValue,
                  child: Text(widget.independentLabel, style: valueStyle),
                ),
                PopupMenuItem<String>(
                  key: const Key('venueChainPartOfChainOption'),
                  value: VenueChainStatusControl.chainValue,
                  child: Text(widget.chainLabel, style: valueStyle),
                ),
              ],
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.lightForeground,
                  border: Border.all(
                    color: _figmaControlFocused
                        ? AppColors.warmOrange
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.pillRadius),
                ),
                child: SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayedValue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: valueStyle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox.square(
                          dimension: 20,
                          child: Center(
                            child: SvgPicture.asset(
                              AppAssets.venueCaretDown,
                              key: const Key('venueLeadChainStatusCaret'),
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyControl(BuildContext context) {
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
