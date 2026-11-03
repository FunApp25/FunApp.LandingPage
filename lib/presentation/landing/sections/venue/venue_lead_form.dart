import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/value_failure.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_text_field.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_chain_status_control.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_form_messages.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_privacy_disclosure.dart';

/// Editable presentation for the established venue-lead BLoC workflow.
final class VenueLeadForm extends StatefulWidget {
  /// Creates the venue lead form for the current [state].
  const VenueLeadForm({
    required this.state,
    required this.onPrivacyNoticeSelected,
    super.key,
  });

  /// Current application-owned form state.
  final VenueLeadFormState state;

  /// Opens the hosted Privacy Notice in a separate browser context.
  final VoidCallback onPrivacyNoticeSelected;

  @override
  State<VenueLeadForm> createState() => _VenueLeadFormState();
}

final class _VenueLeadFormState extends State<VenueLeadForm> {
  final _venueNameController = TextEditingController();
  final _venueTypeController = TextEditingController();
  final _venueCountController = TextEditingController();
  final _venueCountFocusNode = FocusNode();
  final _venueCapacityController = TextEditingController();
  final _websiteController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _venueNameController.dispose();
    _venueTypeController.dispose();
    _venueCountController.dispose();
    _venueCountFocusNode.dispose();
    _venueCapacityController.dispose();
    _websiteController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lead = widget.state.lead;
    final chainStatus = lead.chainStatus.fold<String?>(
      () => null,
      (value) => value.value.fold((failure) => null, (value) => value),
    );
    final isChain = chainStatus == VenueChainStatusControl.chainValue;

    return LayoutBuilder(
      key: const Key('venueLeadForm'),
      builder: (context, constraints) {
        final usesTwoColumns = constraints.maxWidth >= 760;
        final venueName = _figmaField(
          key: const Key('venueLeadVenueNameField'),
          controller: _venueNameController,
          label: l10n.venueLeadVenueNameLabel,
          semanticLabel: l10n.venueLeadRequiredFieldLabel(
            l10n.venueLeadVenueNameLabel,
          ),
          hint: l10n.venueLeadVenueNamePlaceholder,
          required: true,
          error: _errorFor(lead.venueNameValidation),
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.venueNameChanged(value),
          ),
        );
        final venueType = _figmaField(
          key: const Key('venueLeadVenueTypeField'),
          controller: _venueTypeController,
          label: l10n.venueLeadVenueTypeLabel,
          semanticLabel: l10n.venueLeadOptionalFieldLabel(
            l10n.venueLeadVenueTypeLabel,
          ),
          hint: l10n.venueLeadVenueTypePlaceholder,
          error: _errorFor(lead.venueTypeValidation),
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.venueTypeChanged(value),
          ),
        );
        final chainControl = VenueChainStatusControl(
          label: l10n.venueLeadChainStatusLabel,
          placeholder: l10n.venueLeadChainStatusPlaceholder,
          independentLabel: l10n.venueLeadIndependentOption,
          chainLabel: l10n.venueLeadPartOfChainOption,
          selectedValue: chainStatus,
          onSelected: _onChainStatusSelected,
        );
        final venueCount = _figmaField(
          key: const Key('venueLeadVenueCountField'),
          controller: _venueCountController,
          focusNode: _venueCountFocusNode,
          label: l10n.venueLeadVenueCountPageLabel,
          semanticLabel: l10n.venueLeadOptionalFieldLabel(
            l10n.venueLeadVenueCountLabel,
          ),
          hint: l10n.venueLeadVenueCountPlaceholder,
          error: lead.venueCount.fold(
            () => null,
            (value) => _errorFor(value.value, quantity: true),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.venueCountChanged(value),
          ),
        );
        final capacity = _figmaField(
          key: const Key('venueLeadVenueCapacityField'),
          controller: _venueCapacityController,
          label: l10n.venueLeadVenueCapacityLabel,
          semanticLabel: l10n.venueLeadOptionalFieldLabel(
            l10n.venueLeadVenueCapacityLabel,
          ),
          hint: l10n.venueLeadVenueCapacityPlaceholder,
          error: lead.venueCapacity.fold(
            () => null,
            (value) => _errorFor(value.value, quantity: true),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.venueCapacityChanged(value),
          ),
        );
        final website = _figmaField(
          key: const Key('venueLeadWebsiteField'),
          controller: _websiteController,
          label: l10n.venueLeadWebsiteLabel,
          semanticLabel: l10n.venueLeadRequiredFieldLabel(
            l10n.venueLeadWebsiteLabel,
          ),
          hint: l10n.venueLeadWebsitePlaceholder,
          required: true,
          error: _errorFor(lead.websiteValidation),
          keyboardType: TextInputType.url,
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.websiteChanged(value),
          ),
        );
        final firstName = _figmaField(
          key: const Key('venueLeadFirstNameField'),
          controller: _firstNameController,
          label: l10n.venueLeadFirstNameLabel,
          semanticLabel: l10n.venueLeadRequiredFieldLabel(
            l10n.venueLeadFirstNameLabel,
          ),
          hint: l10n.venueLeadFirstNamePlaceholder,
          required: true,
          error: _errorFor(lead.firstNameValidation),
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.firstNameChanged(value),
          ),
        );
        final lastName = _figmaField(
          key: const Key('venueLeadLastNameField'),
          controller: _lastNameController,
          label: l10n.venueLeadLastNameLabel,
          semanticLabel: l10n.venueLeadRequiredFieldLabel(
            l10n.venueLeadLastNameLabel,
          ),
          hint: l10n.venueLeadLastNamePlaceholder,
          required: true,
          error: _errorFor(lead.lastNameValidation),
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.lastNameChanged(value),
          ),
        );
        final role = _figmaField(
          key: const Key('venueLeadRoleField'),
          controller: _roleController,
          label: l10n.venueLeadRoleLabel,
          semanticLabel: l10n.venueLeadRequiredFieldLabel(
            l10n.venueLeadRoleLabel,
          ),
          hint: l10n.venueLeadRolePlaceholder,
          required: true,
          error: _errorFor(lead.roleValidation),
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.roleChanged(value),
          ),
        );
        final email = _figmaField(
          key: const Key('venueLeadEmailField'),
          controller: _emailController,
          label: l10n.venueLeadEmailLabel,
          semanticLabel: l10n.venueLeadRequiredFieldLabel(
            l10n.venueLeadEmailLabel,
          ),
          hint: l10n.venueLeadEmailPlaceholder,
          required: true,
          error: _errorFor(lead.emailValidation),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.emailChanged(value),
          ),
        );
        final phone = _figmaField(
          key: const Key('venueLeadPhoneNumberField'),
          controller: _phoneNumberController,
          label: l10n.venueLeadPhoneNumberLabel,
          semanticLabel: l10n.venueLeadOptionalFieldLabel(
            l10n.venueLeadPhoneNumberLabel,
          ),
          hint: l10n.venueLeadPhoneNumberPlaceholder,
          error: _errorFor(lead.phoneNumberValidation),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.phoneNumberChanged(value),
          ),
        );
        final disclosure = VenuePrivacyDisclosure(
          statement: l10n.venueLeadPrivacyDisclosure,
          privacyNoticeLabel: l10n.venueLeadPrivacyNoticeLinkLabel,
          onPrivacyNoticeSelected: widget.onPrivacyNoticeSelected,
        );

        if (usesTwoColumns) {
          return Column(
            key: const Key('venueLeadTwoColumnLayout'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _figmaRow(
                key: const Key('venueLeadDesktopRow1'),
                leading: venueName,
                trailing: venueType,
              ),
              _fieldGap,
              _figmaRow(
                key: const Key('venueLeadDesktopRow2'),
                leading: chainControl,
                trailing: _animatedVenueCount(
                  visible: isChain,
                  field: venueCount,
                ),
              ),
              _fieldGap,
              _figmaRow(
                key: const Key('venueLeadDesktopRow3'),
                leading: capacity,
                trailing: website,
              ),
              _fieldGap,
              _figmaRow(
                key: const Key('venueLeadDesktopRow4'),
                leading: firstName,
                trailing: lastName,
              ),
              _fieldGap,
              _figmaRow(
                key: const Key('venueLeadDesktopRow5'),
                leading: role,
                trailing: email,
              ),
              _fieldGap,
              _figmaRow(
                key: const Key('venueLeadDesktopRow6'),
                leading: phone,
              ),
              _fieldGap,
              disclosure,
            ],
          );
        } else {
          return Column(
            key: const Key('venueLeadOneColumnLayout'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              venueName,
              _fieldGap,
              venueType,
              _fieldGap,
              chainControl,
              _animatedVenueCount(
                visible: isChain,
                field: venueCount,
                includeLeadingGap: true,
              ),
              _fieldGap,
              capacity,
              _fieldGap,
              website,
              _fieldGap,
              firstName,
              _fieldGap,
              lastName,
              _fieldGap,
              role,
              _fieldGap,
              email,
              _fieldGap,
              phone,
              _fieldGap,
              disclosure,
            ],
          );
        }
      },
    );
  }

  Widget _figmaRow({
    required Key key,
    required Widget leading,
    Widget? trailing,
  }) => Row(
    key: key,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: leading),
      const SizedBox(width: 16),
      Expanded(child: trailing ?? const SizedBox.shrink()),
    ],
  );

  Widget _animatedVenueCount({
    required bool visible,
    required Widget field,
    bool includeLeadingGap = false,
  }) {
    final content = visible
        ? Padding(
            padding: EdgeInsets.only(top: includeLeadingGap ? 16 : 0),
            child: field,
          )
        : const SizedBox.shrink();
    if (MediaQuery.disableAnimationsOf(context)) {
      return content;
    } else {
      return ClipRect(
        child: AnimatedSize(
          key: const Key('venueLeadVenueCountAnimation'),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: content,
        ),
      );
    }
  }

  void _onChainStatusSelected(String value) {
    context.read<VenueLeadFormBloc>().add(
      VenueLeadFormEvent.chainStatusChanged(value),
    );
    if (value != VenueChainStatusControl.chainValue) {
      if (_venueCountFocusNode.hasFocus) {
        _venueCountFocusNode.unfocus();
      }
      _venueCountController.clear();
      context.read<VenueLeadFormBloc>().add(
        const VenueLeadFormEvent.venueCountChanged(''),
      );
    }
  }

  static const _fieldGap = SizedBox(height: 16);

  String? _errorFor<T>(
    Either<ValueFailure<dynamic>, T> value, {
    bool quantity = false,
  }) {
    if (widget.state.hasAttemptedSubmit) {
      return venueLeadValidationMessage(
        context.l10n,
        value,
        quantity: quantity,
      );
    } else {
      return null;
    }
  }

  Widget _figmaField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String semanticLabel,
    required String hint,
    required String? error,
    required ValueChanged<String> onChanged,
    bool required = false,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction textInputAction = TextInputAction.next,
  }) => BrandedFormTextField(
    fieldKey: key,
    controller: controller,
    label: label,
    semanticLabel: semanticLabel,
    hint: hint,
    errorText: error,
    required: required,
    focusNode: focusNode,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    textInputAction: textInputAction,
    onChanged: onChanged,
  );
}
