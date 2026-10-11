import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';

/// Stable stored value and localized display label for a branded selector.
typedef BrandedFormOption<T> = ({T value, String label});

/// Shared pill-shaped dropdown presentation for public forms.
final class BrandedFormDropdown<T> extends StatelessWidget {
  /// Creates a branded dropdown backed by the caller's stable value type.
  const BrandedFormDropdown({
    required this.fieldKey,
    required this.label,
    required this.semanticLabel,
    required this.placeholder,
    required this.value,
    required this.options,
    required this.onChanged,
    this.validator,
    this.required = false,
    this.caretKey,
    this.optionKeys = const {},
    super.key,
  });

  /// Maximum height of the selector popup before it scrolls.
  static const double popupMaxHeight = 360;

  /// Corner treatment shared by every selector popup.
  static const BorderRadius popupBorderRadius = BorderRadius.all(
    Radius.circular(16),
  );

  /// Stable key applied to the underlying dropdown.
  final Key fieldKey;

  /// Visible field label.
  final String label;

  /// Accessible label including requiredness.
  final String semanticLabel;

  /// Visible value before a selection is made.
  final String placeholder;

  /// Current stable stored value.
  final T? value;

  /// Stable values paired with localized display labels.
  final List<BrandedFormOption<T>> options;

  /// Reports a selected stored value.
  final ValueChanged<T?> onChanged;

  /// Optional form validation callback.
  final String? Function(T?)? validator;

  /// Whether to append a visible required marker.
  final bool required;

  /// Optional stable key for the exact caret asset.
  final Key? caretKey;

  /// Optional stable widget keys indexed by stored values.
  final Map<T, Key> optionKeys;

  @override
  Widget build(BuildContext context) {
    final inputStyle = AppTextStyles.bodyFontStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.bodyGray,
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.pillRadius),
      borderSide: BorderSide.none,
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.pillRadius),
      borderSide: const BorderSide(color: AppColors.cherryRed, width: 2),
    );

    return Semantics(
      label: semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            required ? '$label*' : label,
            style: AppTextStyles.bodyFontStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: AppColors.warmCharcoal,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<T>(
            key: fieldKey,
            initialValue: value,
            isExpanded: true,
            menuMaxHeight: popupMaxHeight,
            borderRadius: popupBorderRadius,
            dropdownColor: AppColors.lightForeground,
            style: inputStyle,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.lightForeground,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.pillRadius),
                borderSide: const BorderSide(
                  color: AppColors.warmOrange,
                  width: 2,
                ),
              ),
              errorBorder: errorBorder,
              focusedErrorBorder: errorBorder,
              errorMaxLines: 3,
              errorStyle: AppTextStyles.bodyFontStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
                color: AppColors.cherryRed,
              ),
            ),
            hint: Text(
              placeholder,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: inputStyle,
            ),
            icon: SizedBox.square(
              dimension: 20,
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.venueCaretDown,
                  key:
                      caretKey ??
                      ValueKey<String>('brandedDropdownCaret-$fieldKey'),
                  width: 14,
                  height: 8,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            items: [
              for (final option in options)
                DropdownMenuItem<T>(
                  key: optionKeys[option.value],
                  value: option.value,
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            validator: validator,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
