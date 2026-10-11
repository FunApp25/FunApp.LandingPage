import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_action_button.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_dropdown.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_row.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_text_field.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_marketing_consent.dart';

/// Shared locally validated field surface for prospective-user sign-ups.
final class UserSignUpForm extends StatefulWidget {
  /// Creates a UI-only sign-up form.
  const UserSignUpForm({
    required this.experience,
    this.onSubmit,
    super.key,
  });

  /// Determines the approved fields and copy.
  final UserSignUpExperience experience;

  /// Optional test/development seam; absent in production.
  final UserSignUpSubmit? onSubmit;

  @override
  State<UserSignUpForm> createState() => _UserSignUpFormState();
}

final class _UserSignUpFormState extends State<UserSignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _usageReasonController = TextEditingController();
  String? _gender;
  String? _country;
  var _marketingConsent = false;

  String get _semanticId => switch (widget.experience) {
    UserSignUpExperience.hereAndNow => 'hereAndNow',
    UserSignUpExperience.foundingFriend => 'foundingFriend',
  };

  bool get _requiresCountry =>
      widget.experience == UserSignUpExperience.foundingFriend;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _usageReasonController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    final callback = widget.onSubmit;
    if (form != null && callback != null && form.validate()) {
      final usageReason = _usageReasonController.text;
      callback(
        UserSignUpDraft(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          age: int.parse(_ageController.text),
          gender: _gender,
          country: _country,
          usageReason: usageReason.isEmpty ? null : usageReason,
          marketingConsent: _marketingConsent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final firstNameLabel = switch (widget.experience) {
      UserSignUpExperience.hereAndNow =>
        l10n.userSignUpHereAndNowFirstNameLabel,
      UserSignUpExperience.foundingFriend =>
        l10n.userSignUpFoundingFriendFirstNameLabel,
    };
    final lastNameLabel = switch (widget.experience) {
      UserSignUpExperience.hereAndNow => l10n.userSignUpHereAndNowLastNameLabel,
      UserSignUpExperience.foundingFriend =>
        l10n.userSignUpFoundingFriendLastNameLabel,
    };
    final usageReasonLabel = switch (widget.experience) {
      UserSignUpExperience.hereAndNow =>
        l10n.userSignUpHereAndNowUsageReasonLabel,
      UserSignUpExperience.foundingFriend =>
        l10n.userSignUpFoundingFriendUsageReasonLabel,
    };
    final marketingCopy = switch (widget.experience) {
      UserSignUpExperience.hereAndNow =>
        l10n.userSignUpHereAndNowMarketingConsent,
      UserSignUpExperience.foundingFriend =>
        l10n.userSignUpFoundingFriendMarketingConsent,
    };
    final ctaLabel = switch (widget.experience) {
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

    return Form(
      key: _formKey,
      child: Column(
        key: Key('userSignUpForm-$_semanticId'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final usesDesktopGrid = constraints.maxWidth >= 760;
              final firstName = _textField(
                key: Key('firstNameField-$_semanticId'),
                controller: _firstNameController,
                label: firstNameLabel,
                placeholder: l10n.userSignUpFirstNamePlaceholder,
                required: true,
                keyboardType: TextInputType.name,
                autofillHints: const [AutofillHints.givenName],
                validator: _requiredValidator,
              );
              final lastName = _textField(
                key: Key('lastNameField-$_semanticId'),
                controller: _lastNameController,
                label: lastNameLabel,
                placeholder: l10n.userSignUpLastNamePlaceholder,
                required: true,
                keyboardType: TextInputType.name,
                autofillHints: const [AutofillHints.familyName],
                validator: _requiredValidator,
              );

              final email = _textField(
                key: Key('emailField-$_semanticId'),
                controller: _emailController,
                label: l10n.userSignUpEmailLabel,
                placeholder: l10n.userSignUpEmailPlaceholder,
                required: true,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: _emailValidator,
              );
              final age = _textField(
                key: Key('ageField-$_semanticId'),
                controller: _ageController,
                label: l10n.userSignUpAgeLabel,
                placeholder: l10n.userSignUpAgePlaceholder,
                required: true,
                keyboardType: TextInputType.number,
                inputFormatters: const [_AsciiDigitsOnlyFormatter()],
                validator: _ageValidator,
              );
              final gender = _dropdownField(
                key: Key('genderField-$_semanticId'),
                label: l10n.userSignUpGenderLabel,
                placeholder: l10n.userSignUpGenderPlaceholder,
                value: _gender,
                options: genderOptions,
                onChanged: (value) => setState(() => _gender = value),
              );
              final country = _requiresCountry
                  ? _dropdownField(
                      key: Key('countryField-$_semanticId'),
                      label: l10n.userSignUpCountryLabel,
                      placeholder: l10n.userSignUpCountryPlaceholder,
                      required: true,
                      value: _country,
                      options: countryOptions,
                      validator: _requiredSelectionValidator,
                      onChanged: (value) => setState(() => _country = value),
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
                    leading: country ?? gender,
                    trailing: country == null ? null : gender,
                    usesDesktopGrid: usesDesktopGrid,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _textField(
            key: Key('usageReasonField-$_semanticId'),
            controller: _usageReasonController,
            label: usageReasonLabel,
            placeholder: l10n.userSignUpUsageReasonPlaceholder,
            minLines: 5,
            maxLines: 7,
            textInputAction: TextInputAction.newline,
            multiline: true,
          ),
          const SizedBox(height: 20),
          UserSignUpMarketingConsent(
            semanticId: _semanticId,
            label: marketingCopy,
            value: _marketingConsent,
            onChanged: (value) => setState(() => _marketingConsent = value),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).width < 600 ? 40 : 64),
          _submitButton(ctaLabel),
        ],
      ),
    );
  }

  Widget _textField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String placeholder,
    bool required = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    String? Function(String?)? validator,
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
      controller: controller,
      label: label,
      semanticLabel: semanticLabel,
      hint: placeholder,
      required: required,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: textInputAction,
      multiline: multiline,
    );
  }

  Widget _dropdownField({
    required Key key,
    required String label,
    required String placeholder,
    required String? value,
    required List<UserSignUpOption> options,
    required ValueChanged<String?> onChanged,
    bool required = false,
    String? Function(String?)? validator,
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
      value: value,
      options: options,
      validator: validator,
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
    onPressed: widget.onSubmit == null ? null : _submit,
  );

  String? _requiredValidator(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      return null;
    } else {
      return context.l10n.userSignUpValidationRequired;
    }
  }

  String? _emailValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) {
      return requiredError;
    } else if (EmailAddress(value!).isValid()) {
      return null;
    } else {
      return context.l10n.userSignUpValidationEmail;
    }
  }

  String? _ageValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) {
      return requiredError;
    } else if (int.tryParse(value!) != null) {
      return null;
    } else {
      return context.l10n.userSignUpValidationInteger;
    }
  }

  String? _requiredSelectionValidator(String? value) =>
      value == null ? context.l10n.userSignUpValidationRequired : null;

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
