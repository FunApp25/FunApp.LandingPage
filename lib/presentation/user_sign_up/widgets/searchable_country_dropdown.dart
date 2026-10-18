import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';

/// Founding Friend country selector with localized, case-insensitive filtering.
final class SearchableCountryDropdown extends StatefulWidget {
  /// Creates a searchable selector backed by stable HubSpot country values.
  const SearchableCountryDropdown({
    required this.fieldKey,
    required this.label,
    required this.semanticLabel,
    required this.placeholder,
    required this.noResultsLabel,
    required this.value,
    required this.options,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  /// Stable key applied to the editable selector.
  final Key fieldKey;

  /// Visible field label.
  final String label;

  /// Accessible label including requiredness.
  final String semanticLabel;

  /// Visible prompt before a search or selection is made.
  final String placeholder;

  /// Localized message shown and announced when filtering finds no countries.
  final String noResultsLabel;

  /// Current stable HubSpot country value.
  final String? value;

  /// Stable values paired with localized display labels.
  final List<UserSignUpOption> options;

  /// Reports a selected stable value, or clears an edited prior selection.
  final ValueChanged<String?> onChanged;

  /// Externally coordinated validation error.
  final String? errorText;

  @override
  State<SearchableCountryDropdown> createState() =>
      _SearchableCountryDropdownState();
}

final class _SearchableCountryDropdownState
    extends State<SearchableCountryDropdown> {
  static const _popupMaxHeight = 360.0;
  static const _popupBorderRadius = BorderRadius.all(Radius.circular(16));

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
    _controller.text = _labelFor(widget.value) ?? '';
    _controller.addListener(_clearSelectionAfterSearchEdit);
  }

  @override
  void didUpdateWidget(SearchableCountryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _selectedValue) {
      _selectedValue = widget.value;
      _setControllerText(_labelFor(widget.value) ?? '');
    } else if (widget.value != null && oldWidget.options != widget.options) {
      _setControllerText(_labelFor(widget.value) ?? '');
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_clearSelectionAfterSearchEdit)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

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
    final entries = [
      for (final option in widget.options)
        DropdownMenuEntry<String>(
          value: option.value,
          label: option.label,
          labelWidget: Text(
            option.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ];

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.label}*',
            style: AppTextStyles.bodyFontStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: widget.errorText == null
                  ? AppColors.warmCharcoal
                  : AppColors.cherryRed,
            ),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) => DropdownMenu<String>(
              key: widget.fieldKey,
              controller: _controller,
              focusNode: _focusNode,
              initialSelection: widget.value,
              width: constraints.maxWidth,
              menuHeight: _popupMaxHeight,
              enableFilter: true,
              requestFocusOnTap: true,
              hintText: widget.placeholder,
              errorText: widget.errorText,
              textStyle: inputStyle,
              textInputAction: TextInputAction.next,
              trailingIcon: _caret(),
              selectedTrailingIcon: _caret(),
              inputDecorationTheme: InputDecorationTheme(
                hintStyle: inputStyle,
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
              menuStyle: const MenuStyle(
                maximumSize: WidgetStatePropertyAll(
                  Size(double.infinity, _popupMaxHeight),
                ),
                backgroundColor: WidgetStatePropertyAll(
                  AppColors.lightForeground,
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: _popupBorderRadius),
                ),
              ),
              filterCallback: _filterEntries,
              searchCallback: (filteredEntries, query) {
                if (filteredEntries.isNotEmpty &&
                    filteredEntries.first.enabled) {
                  return 0;
                } else {
                  return null;
                }
              },
              dropdownMenuEntries: entries,
              onSelected: (value) {
                if (value != null) {
                  _selectedValue = value;
                  widget.onChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuEntry<String>> _filterEntries(
    List<DropdownMenuEntry<String>> entries,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    final matches = normalizedQuery.isEmpty
        ? entries
        : entries
              .where(
                (entry) => entry.label.toLowerCase().contains(normalizedQuery),
              )
              .toList(growable: false);

    if (matches.isNotEmpty) {
      return matches;
    } else {
      return [
        DropdownMenuEntry<String>(
          value: '',
          label: widget.noResultsLabel,
          enabled: false,
          labelWidget: Semantics(
            key: const Key('countrySearchNoResults'),
            container: true,
            liveRegion: true,
            label: widget.noResultsLabel,
            child: ExcludeSemantics(child: Text(widget.noResultsLabel)),
          ),
        ),
      ];
    }
  }

  Widget _caret() => SizedBox.square(
    dimension: 20,
    child: Center(
      child: SvgPicture.asset(
        AppAssets.venueCaretDown,
        width: 14,
        height: 8,
        excludeFromSemantics: true,
      ),
    ),
  );

  String? _labelFor(String? value) {
    for (final option in widget.options) {
      if (option.value == value) {
        return option.label;
      }
    }
    return null;
  }

  void _clearSelectionAfterSearchEdit() {
    final editedText = _controller.text;
    scheduleMicrotask(() {
      final selectedLabel = _labelFor(_selectedValue);
      if (mounted &&
          editedText == _controller.text &&
          _selectedValue != null &&
          editedText != selectedLabel) {
        _selectedValue = null;
        widget.onChanged(null);
      }
    });
  }

  void _setControllerText(String text) {
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }
}
