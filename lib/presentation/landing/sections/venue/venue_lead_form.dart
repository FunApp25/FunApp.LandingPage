import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_chain_status_control.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_form_messages.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_privacy_disclosure.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

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
    final state = widget.state;
    final lead = state.lead;
    final chainStatus = lead.chainStatus.fold<String?>(
      () => null,
      (value) => value.value.fold((failure) => null, (value) => value),
    );
    final isChain = chainStatus == VenueChainStatusControl.chainValue;
    final venueCountContent = isChain
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _fieldGap,
              _field(
                key: const Key('venueLeadVenueCountField'),
                controller: _venueCountController,
                focusNode: _venueCountFocusNode,
                label: l10n.venueLeadOptionalFieldLabel(
                  l10n.venueLeadVenueCountLabel,
                ),
                error: lead.venueCount.fold(() => null, _errorFor),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => context.read<VenueLeadFormBloc>().add(
                  VenueLeadFormEvent.venueCountChanged(value),
                ),
              ),
            ],
          )
        : const SizedBox.shrink();

    return Column(
      key: const Key('venueLeadForm'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.venueLeadDialogTitle,
            key: const Key('venueLeadDialogTitle'),
            style: LandingTextStyles.sectionHeading,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.venueLeadDialogBody,
          style: LandingTextStyles.sectionBody,
        ),
        const SizedBox(height: 32),
        Container(
          key: const Key('venueLeadVenueDetailsGroup'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.beigeAccent,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeading(l10n.venueLeadVenueDetailsHeading),
              const SizedBox(height: 16),
              _field(
                key: const Key('venueLeadVenueNameField'),
                controller: _venueNameController,
                label: l10n.venueLeadRequiredFieldLabel(
                  l10n.venueLeadVenueNameLabel,
                ),
                error: _errorFor(lead.venueName),
                onChanged: (value) => context.read<VenueLeadFormBloc>().add(
                  VenueLeadFormEvent.venueNameChanged(value),
                ),
              ),
              _fieldGap,
              _field(
                key: const Key('venueLeadVenueTypeField'),
                controller: _venueTypeController,
                label: l10n.venueLeadOptionalFieldLabel(
                  l10n.venueLeadVenueTypeLabel,
                ),
                error: lead.venueType.fold(() => null, _errorFor),
                onChanged: (value) => context.read<VenueLeadFormBloc>().add(
                  VenueLeadFormEvent.venueTypeChanged(value),
                ),
              ),
              _fieldGap,
              VenueChainStatusControl(
                label: l10n.venueLeadOptionalFieldLabel(
                  l10n.venueLeadChainStatusLabel,
                ),
                independentLabel: l10n.venueLeadIndependentOption,
                chainLabel: l10n.venueLeadPartOfChainOption,
                selectedValue: chainStatus,
                onSelected: (value) {
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
                },
              ),
              if (MediaQuery.disableAnimationsOf(context))
                venueCountContent
              else
                ClipRect(
                  child: AnimatedSize(
                    key: const Key('venueLeadVenueCountAnimation'),
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.topCenter,
                    child: venueCountContent,
                  ),
                ),
              _fieldGap,
              _field(
                key: const Key('venueLeadVenueCapacityField'),
                controller: _venueCapacityController,
                label: l10n.venueLeadOptionalFieldLabel(
                  l10n.venueLeadVenueCapacityLabel,
                ),
                error: lead.venueCapacity.fold(() => null, _errorFor),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => context.read<VenueLeadFormBloc>().add(
                  VenueLeadFormEvent.venueCapacityChanged(value),
                ),
              ),
              _fieldGap,
              _field(
                key: const Key('venueLeadWebsiteField'),
                controller: _websiteController,
                label: l10n.venueLeadRequiredFieldLabel(
                  l10n.venueLeadWebsiteLabel,
                ),
                error: _errorFor(lead.website),
                keyboardType: TextInputType.url,
                onChanged: (value) => context.read<VenueLeadFormBloc>().add(
                  VenueLeadFormEvent.websiteChanged(value),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _sectionHeading(l10n.venueLeadContactDetailsHeading),
        const SizedBox(height: 16),
        _field(
          key: const Key('venueLeadFirstNameField'),
          controller: _firstNameController,
          label: l10n.venueLeadRequiredFieldLabel(
            l10n.venueLeadFirstNameLabel,
          ),
          error: _errorFor(lead.firstName),
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.firstNameChanged(value),
          ),
        ),
        _fieldGap,
        _field(
          key: const Key('venueLeadLastNameField'),
          controller: _lastNameController,
          label: l10n.venueLeadRequiredFieldLabel(
            l10n.venueLeadLastNameLabel,
          ),
          error: _errorFor(lead.lastName),
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.lastNameChanged(value),
          ),
        ),
        _fieldGap,
        _field(
          key: const Key('venueLeadRoleField'),
          controller: _roleController,
          label: l10n.venueLeadRequiredFieldLabel(
            l10n.venueLeadRoleLabel,
          ),
          error: _errorFor(lead.role),
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.roleChanged(value),
          ),
        ),
        _fieldGap,
        _field(
          key: const Key('venueLeadEmailField'),
          controller: _emailController,
          label: l10n.venueLeadRequiredFieldLabel(
            l10n.venueLeadEmailLabel,
          ),
          error: _errorFor(lead.email),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.emailChanged(value),
          ),
        ),
        _fieldGap,
        _field(
          key: const Key('venueLeadPhoneNumberField'),
          controller: _phoneNumberController,
          label: l10n.venueLeadOptionalFieldLabel(
            l10n.venueLeadPhoneNumberLabel,
          ),
          error: lead.phoneNumber.fold(() => null, _errorFor),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.phoneNumberChanged(value),
          ),
        ),
        const SizedBox(height: 24),
        VenuePrivacyDisclosure(
          statement: l10n.venueLeadPrivacyDisclosure,
          privacyNoticeLabel: l10n.venueLeadPrivacyNoticeLinkLabel,
          onPrivacyNoticeSelected: widget.onPrivacyNoticeSelected,
        ),
      ],
    );
  }

  static const _fieldGap = SizedBox(height: 16);

  Widget _sectionHeading(String text) => Semantics(
    header: true,
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleLarge,
    ),
  );

  String? _errorFor<T>(ValueObject<T> value) {
    if (widget.state.hasAttemptedSubmit) {
      return venueLeadValidationMessage(context.l10n, value);
    } else {
      return null;
    }
  }

  Widget _field({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String? error,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction textInputAction = TextInputAction.next,
  }) => TextField(
    key: key,
    controller: controller,
    focusNode: focusNode,
    decoration: InputDecoration(
      labelText: label,
      errorText: error,
      errorStyle: const TextStyle(color: AppColors.cherryRed),
      labelStyle: TextStyle(
        color: error == null ? AppColors.textPrimary : AppColors.cherryRed,
      ),
      floatingLabelStyle: TextStyle(
        color: error == null ? AppColors.energeticPlum : AppColors.cherryRed,
      ),
      filled: true,
      fillColor: AppColors.lightForeground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        borderSide: const BorderSide(color: AppColors.energeticPlum, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        borderSide: const BorderSide(color: AppColors.cherryRed, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        borderSide: const BorderSide(color: AppColors.cherryRed, width: 2),
      ),
    ),
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    textInputAction: textInputAction,
    autofillHints: null,
    onChanged: onChanged,
    onSubmitted: (_) {
      if (textInputAction == TextInputAction.next) {
        FocusScope.of(context).nextFocus();
      }
    },
  );
}
