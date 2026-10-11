import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';

/// Shared Figma-aligned text-field presentation for public forms.
final class BrandedFormTextField extends StatelessWidget {
  /// Creates a branded single-line or multiline form field.
  const BrandedFormTextField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.semanticLabel,
    required this.hint,
    this.onChanged,
    this.validator,
    this.errorText,
    this.required = false,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.autofillHints,
    this.minLines = 1,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    this.multiline = false,
    super.key,
  });

  /// Stable key applied to the editable control.
  final Key fieldKey;

  /// Caller-owned draft controller.
  final TextEditingController controller;

  /// Visible field label.
  final String label;

  /// Accessible label including requiredness.
  final String semanticLabel;

  /// Placeholder shown while the draft is empty.
  final String hint;

  /// Reports draft changes to the owning workflow.
  final ValueChanged<String>? onChanged;

  /// Optional form validation callback.
  final String? Function(String?)? validator;

  /// Optional externally coordinated validation error.
  final String? errorText;

  /// Whether to append a visible required marker.
  final bool required;

  /// Optional caller-owned focus node.
  final FocusNode? focusNode;

  /// Platform keyboard configuration.
  final TextInputType? keyboardType;

  /// Input restrictions applied before draft changes are reported.
  final List<TextInputFormatter>? inputFormatters;

  /// Browser autofill roles for the field.
  final Iterable<String>? autofillHints;

  /// Minimum number of editable lines.
  final int minLines;

  /// Maximum number of editable lines.
  final int maxLines;

  /// Keyboard action and focus-traversal behavior.
  final TextInputAction textInputAction;

  /// Whether to use the rectangular multiline radius.
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final radius = multiline ? 16.0 : AppSizes.pillRadius;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide.none,
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.cherryRed, width: 2),
    );
    final inputStyle = AppTextStyles.bodyFontStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.bodyGray,
    );

    final decoration = InputDecoration(
      hintText: hint,
      hintStyle: inputStyle,
      errorText: errorText,
      errorMaxLines: 3,
      errorStyle: AppTextStyles.bodyFontStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: AppColors.cherryRed,
      ),
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
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(
          color: AppColors.warmOrange,
          width: 2,
        ),
      ),
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
    );
    void handleSubmitted(String value) {
      if (textInputAction == TextInputAction.next) {
        FocusScope.of(context).nextFocus();
      }
    }

    final field = validator == null
        ? TextField(
            key: fieldKey,
            controller: controller,
            focusNode: focusNode,
            style: inputStyle,
            decoration: decoration,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            autofillHints: autofillHints,
            minLines: minLines,
            maxLines: maxLines,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onSubmitted: handleSubmitted,
          )
        : TextFormField(
            key: fieldKey,
            controller: controller,
            focusNode: focusNode,
            style: inputStyle,
            decoration: decoration,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            autofillHints: autofillHints,
            validator: validator,
            minLines: minLines,
            maxLines: maxLines,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onFieldSubmitted: handleSubmitted,
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
              color: errorText == null
                  ? AppColors.warmCharcoal
                  : AppColors.cherryRed,
            ),
          ),
          const SizedBox(height: 4),
          field,
        ],
      ),
    );
  }
}
