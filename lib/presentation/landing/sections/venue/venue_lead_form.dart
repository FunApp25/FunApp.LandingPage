import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_form_messages.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Editable presentation for the established venue-lead BLoC workflow.
final class VenueLeadForm extends StatefulWidget {
  /// Creates the venue lead form for the current [state].
  const VenueLeadForm({
    required this.state,
    required this.submissionFailure,
    super.key,
  });

  /// Current application-owned form state.
  final VenueLeadFormState state;

  /// Current provider-neutral operational failure, when present.
  final AppFailure? submissionFailure;

  @override
  State<VenueLeadForm> createState() => _VenueLeadFormState();
}

final class _VenueLeadFormState extends State<VenueLeadForm> {
  final _venueNameController = TextEditingController();
  final _venueTypeController = TextEditingController();
  final _chainStatusController = TextEditingController();
  final _venueCountController = TextEditingController();
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
    _chainStatusController.dispose();
    _venueCountController.dispose();
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
    final failure = widget.submissionFailure;

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
        _field(
          key: const Key('venueLeadChainStatusField'),
          controller: _chainStatusController,
          label: l10n.venueLeadOptionalFieldLabel(
            l10n.venueLeadChainStatusLabel,
          ),
          error: lead.chainStatus.fold(() => null, _errorFor),
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.chainStatusChanged(value),
          ),
        ),
        _fieldGap,
        _field(
          key: const Key('venueLeadVenueCountField'),
          controller: _venueCountController,
          label: l10n.venueLeadOptionalFieldLabel(
            l10n.venueLeadVenueCountLabel,
          ),
          error: lead.venueCount.fold(() => null, _errorFor),
          keyboardType: TextInputType.number,
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.venueCountChanged(value),
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
        if (failure != null) ...[
          const SizedBox(height: 24),
          Semantics(
            key: const Key('venueLeadSubmissionFailure'),
            container: true,
            liveRegion: true,
            child: Text(
              venueLeadSubmissionFailureMessage(l10n, failure),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('venueLeadSubmitButton'),
          onPressed: state.isSubmitting
              ? null
              : () => context.read<VenueLeadFormBloc>().add(
                  const VenueLeadFormEvent.submitted(),
                ),
          child: state.isSubmitting
              ? Semantics(
                  key: const Key('venueLeadSubmissionProgress'),
                  label: l10n.venueLeadSubmitting,
                  liveRegion: true,
                  excludeSemantics: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.venueLeadSubmitting),
                    ],
                  ),
                )
              : Text(l10n.venueLeadSubmit),
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
    TextInputType? keyboardType,
    TextInputAction textInputAction = TextInputAction.next,
  }) => TextField(
    key: key,
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      errorText: error,
      border: const OutlineInputBorder(),
    ),
    keyboardType: keyboardType,
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
