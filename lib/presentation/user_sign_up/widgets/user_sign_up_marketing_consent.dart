import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_checkbox.dart';

/// Controlled, optional marketing opt-in for a user sign-up form.
final class UserSignUpMarketingConsent extends StatelessWidget {
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
  Widget build(BuildContext context) => BrandedFormCheckbox(
    semanticKey: Key('marketingConsent-$semanticId'),
    focusKey: Key('marketingConsentFocus-$semanticId'),
    visualKey: Key('marketingConsentVisual-$semanticId'),
    label: label,
    labelWidget: Text(
      label,
      style: AppTextStyles.bodyFontStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 28 / 18,
        color: AppColors.bodyGray,
      ),
    ),
    value: value,
    onChanged: onChanged,
  );
}
