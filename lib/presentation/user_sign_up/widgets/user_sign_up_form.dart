import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_action_button.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_dropdown.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_row.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_text_field.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/searchable_country_dropdown.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_marketing_consent.dart';

/// Shared field surface driven by one registration workflow BLoC.
final class UserSignUpForm extends StatelessWidget {
  /// Creates the controlled sign-up form.
  const UserSignUpForm({
    required this.experience,
    required this.gender,
    required this.country,
    required this.marketingConsent,
    required this.isSubmitting,
    required this.submissionSucceeded,
    required this.hasSubmissionFailure,
    required this.firstNameError,
    required this.lastNameError,
    required this.emailError,
    required this.ageError,
    required this.countryError,
    required this.onFirstNameChanged,
    required this.onLastNameChanged,
    required this.onEmailChanged,
    required this.onAgeChanged,
    required this.onGenderChanged,
    required this.onCountryChanged,
    required this.onUsageReasonChanged,
    required this.onMarketingConsentChanged,
    required this.onSubmit,
    super.key,
  });

  /// Determines the approved fields and copy.
  final UserSignUpExperience experience;

  /// Current optional gender selection.
  final String? gender;

  /// Current required Founding Friend country selection.
  final String? country;

  /// Current optional marketing opt-in.
  final bool marketingConsent;

  /// Whether a repository call is in flight.
  final bool isSubmitting;

  /// Whether the current draft has a confirmed successful result.
  final bool submissionSucceeded;

  /// Whether the latest settled attempt failed operationally.
  final bool hasSubmissionFailure;

  /// Validation message for the first name.
  final String? firstNameError;

  /// Validation message for the last name.
  final String? lastNameError;

  /// Validation message for the email address.
  final String? emailError;

  /// Validation message for the integer age input.
  final String? ageError;

  /// Validation message for the required country selection.
  final String? countryError;

  /// Reports a first-name edit.
  final ValueChanged<String> onFirstNameChanged;

  /// Reports a last-name edit.
  final ValueChanged<String> onLastNameChanged;

  /// Reports an email edit.
  final ValueChanged<String> onEmailChanged;

  /// Reports an age edit.
  final ValueChanged<String> onAgeChanged;

  /// Reports a gender selection.
  final ValueChanged<String?> onGenderChanged;

  /// Reports a country selection.
  final ValueChanged<String?> onCountryChanged;

  /// Reports a usage-reason edit.
  final ValueChanged<String> onUsageReasonChanged;

  /// Reports a marketing opt-in change.
  final ValueChanged<bool> onMarketingConsentChanged;

  /// Attempts submission through the owning BLoC.
  final VoidCallback onSubmit;

  String get _semanticId => switch (experience) {
    UserSignUpExperience.hereAndNow => 'hereAndNow',
    UserSignUpExperience.foundingFriend => 'foundingFriend',
  };

  bool get _requiresCountry =>
      experience == UserSignUpExperience.foundingFriend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final firstNameLabel = switch (experience) {
      UserSignUpExperience.hereAndNow =>
        l10n.userSignUpHereAndNowFirstNameLabel,
      UserSignUpExperience.foundingFriend =>
        l10n.userSignUpFoundingFriendFirstNameLabel,
    };
    final lastNameLabel = switch (experience) {
      UserSignUpExperience.hereAndNow => l10n.userSignUpHereAndNowLastNameLabel,
      UserSignUpExperience.foundingFriend =>
        l10n.userSignUpFoundingFriendLastNameLabel,
    };
    final usageReasonLabel = switch (experience) {
      UserSignUpExperience.hereAndNow =>
        l10n.userSignUpHereAndNowUsageReasonLabel,
      UserSignUpExperience.foundingFriend =>
        l10n.userSignUpFoundingFriendUsageReasonLabel,
    };
    final marketingCopy = switch (experience) {
      UserSignUpExperience.hereAndNow =>
        l10n.userSignUpHereAndNowMarketingConsent,
      UserSignUpExperience.foundingFriend =>
        l10n.userSignUpFoundingFriendMarketingConsent,
    };
    final ctaLabel = switch (experience) {
      UserSignUpExperience.hereAndNow => l10n.userSignUpHereAndNowCta,
      UserSignUpExperience.foundingFriend => l10n.userSignUpFoundingFriendCta,
    };
    final genderOptions = <UserSignUpOption>[
      (value: 'Man', label: l10n.userSignUpGenderMan),
      (value: 'Woman', label: l10n.userSignUpGenderWoman),
      (value: 'Non-binary', label: l10n.userSignUpGenderNonBinary),
      (
        value: 'Prefer not to answer',
        label: l10n.userSignUpGenderPreferNotToAnswer,
      ),
    ];
    final countryOptions = _countryOptions(l10n.userSignUpCountryOptionsSource);

    return Column(
      key: Key('userSignUpForm-$_semanticId'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final usesDesktopGrid = constraints.maxWidth >= 760;
            final firstName = _textField(
              context: context,
              key: Key('firstNameField-$_semanticId'),
              label: firstNameLabel,
              placeholder: l10n.userSignUpFirstNamePlaceholder,
              required: true,
              errorText: firstNameError,
              keyboardType: TextInputType.name,
              autofillHints: const [AutofillHints.givenName],
              onChanged: onFirstNameChanged,
            );
            final lastName = _textField(
              context: context,
              key: Key('lastNameField-$_semanticId'),
              label: lastNameLabel,
              placeholder: l10n.userSignUpLastNamePlaceholder,
              required: true,
              errorText: lastNameError,
              keyboardType: TextInputType.name,
              autofillHints: const [AutofillHints.familyName],
              onChanged: onLastNameChanged,
            );
            final email = _textField(
              context: context,
              key: Key('emailField-$_semanticId'),
              label: l10n.userSignUpEmailLabel,
              placeholder: l10n.userSignUpEmailPlaceholder,
              required: true,
              errorText: emailError,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              onChanged: onEmailChanged,
            );
            final age = _textField(
              context: context,
              key: Key('ageField-$_semanticId'),
              label: l10n.userSignUpAgeLabel,
              placeholder: l10n.userSignUpAgePlaceholder,
              required: true,
              errorText: ageError,
              keyboardType: TextInputType.number,
              inputFormatters: const [_AsciiDigitsOnlyFormatter()],
              onChanged: onAgeChanged,
            );
            final genderField = _dropdownField(
              context: context,
              key: Key('genderField-$_semanticId'),
              label: l10n.userSignUpGenderLabel,
              placeholder: l10n.userSignUpGenderPlaceholder,
              value: gender,
              options: genderOptions,
              onChanged: onGenderChanged,
            );
            final countryField = _requiresCountry
                ? SearchableCountryDropdown(
                    fieldKey: Key('countryField-$_semanticId'),
                    label: l10n.userSignUpCountryLabel,
                    semanticLabel: l10n.userSignUpRequiredFieldSemantics(
                      l10n.userSignUpCountryLabel,
                    ),
                    placeholder: l10n.userSignUpCountryPlaceholder,
                    noResultsLabel: l10n.userSignUpCountryNoResults,
                    errorText: countryError,
                    value: country,
                    options: countryOptions,
                    onChanged: onCountryChanged,
                  )
                : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _fieldPair(
                  rowKey: Key('nameFieldsRow-$_semanticId'),
                  columnKey: Key('nameFieldsColumn-$_semanticId'),
                  leading: firstName,
                  trailing: lastName,
                  usesDesktopGrid: usesDesktopGrid,
                ),
                const SizedBox(height: 16),
                _fieldPair(
                  rowKey: Key('contactFieldsRow-$_semanticId'),
                  columnKey: Key('contactFieldsColumn-$_semanticId'),
                  leading: email,
                  trailing: age,
                  usesDesktopGrid: usesDesktopGrid,
                ),
                const SizedBox(height: 16),
                _fieldPair(
                  rowKey: Key('demographicFieldsRow-$_semanticId'),
                  columnKey: Key('demographicFieldsColumn-$_semanticId'),
                  leading: countryField ?? genderField,
                  trailing: countryField == null ? null : genderField,
                  usesDesktopGrid: usesDesktopGrid,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _textField(
          context: context,
          key: Key('usageReasonField-$_semanticId'),
          label: usageReasonLabel,
          placeholder: l10n.userSignUpUsageReasonPlaceholder,
          minLines: 5,
          maxLines: 7,
          textInputAction: TextInputAction.newline,
          multiline: true,
          onChanged: onUsageReasonChanged,
        ),
        const SizedBox(height: 20),
        UserSignUpMarketingConsent(
          semanticId: _semanticId,
          label: marketingCopy,
          value: marketingConsent,
          onChanged: onMarketingConsentChanged,
        ),
        SizedBox(height: MediaQuery.sizeOf(context).width < 600 ? 40 : 64),
        if (hasSubmissionFailure) ...[
          Semantics(
            key: Key('userSignUpSubmissionFailure-$_semanticId'),
            container: true,
            liveRegion: true,
            child: Text(
              l10n.venueLeadSubmissionFailure,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (isSubmitting) ...[
          Semantics(
            key: Key('userSignUpSubmissionProgress-$_semanticId'),
            container: true,
            liveRegion: true,
            label: l10n.venueLeadSubmitting,
            child: const LinearProgressIndicator(
              color: AppColors.energeticPlum,
              backgroundColor: AppColors.beigeAccent,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _submitButton(ctaLabel),
      ],
    );
  }

  Widget _textField({
    required BuildContext context,
    required Key key,
    required String label,
    required String placeholder,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool required = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    int minLines = 1,
    int maxLines = 1,
    TextInputAction textInputAction = TextInputAction.next,
    bool multiline = false,
  }) {
    final semanticLabel = required
        ? context.l10n.userSignUpRequiredFieldSemantics(label)
        : context.l10n.userSignUpOptionalFieldSemantics(label);

    return BrandedFormTextField(
      fieldKey: key,
      label: label,
      semanticLabel: semanticLabel,
      hint: placeholder,
      errorText: errorText,
      required: required,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: textInputAction,
      multiline: multiline,
      onChanged: onChanged,
    );
  }

  Widget _dropdownField({
    required BuildContext context,
    required Key key,
    required String label,
    required String placeholder,
    required String? value,
    required List<UserSignUpOption> options,
    required ValueChanged<String?> onChanged,
    String? errorText,
    bool required = false,
  }) {
    final semanticLabel = required
        ? context.l10n.userSignUpRequiredFieldSemantics(label)
        : context.l10n.userSignUpOptionalFieldSemantics(label);

    return BrandedFormDropdown<String>(
      fieldKey: key,
      label: label,
      semanticLabel: semanticLabel,
      placeholder: placeholder,
      required: required,
      errorText: errorText,
      value: value,
      options: options,
      onChanged: onChanged,
    );
  }

  Widget _fieldPair({
    required Key rowKey,
    required Key columnKey,
    required Widget leading,
    required Widget? trailing,
    required bool usesDesktopGrid,
  }) => BrandedFormRow(
    rowKey: rowKey,
    columnKey: columnKey,
    leading: leading,
    trailing: trailing,
    horizontal: usesDesktopGrid,
  );

  Widget _submitButton(String label) => BrandedFormActionButton(
    buttonKey: Key('userSignUpSubmit-$_semanticId'),
    arrowKey: Key('userSignUpSubmitArrow-$_semanticId'),
    label: label,
    onPressed: isSubmitting || submissionSucceeded ? null : onSubmit,
    disabledBackgroundColor: AppColors.warmOrange.withValues(alpha: 0.45),
  );

  static List<UserSignUpOption> _countryOptions(String source) => [
    for (final entry in source.split('\n'))
      if (entry.split('\t') case [final value, final label])
        (value: value, label: label),
  ];
}

final class _AsciiDigitsOnlyFormatter extends TextInputFormatter {
  const _AsciiDigitsOnlyFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => FilteringTextInputFormatter.digitsOnly.formatEditUpdate(
    oldValue,
    newValue,
  );
}
