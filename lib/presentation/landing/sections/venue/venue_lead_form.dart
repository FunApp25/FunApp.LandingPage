import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/value_object.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_text_field.dart';
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
    this.showIntroduction = true,
    this.alignWithVenuePageDesign = false,
    super.key,
  });

  /// Current application-owned form state.
  final VenueLeadFormState state;

  /// Opens the hosted Privacy Notice in a separate browser context.
  final VoidCallback onPrivacyNoticeSelected;

  /// Whether to render the legacy dialog-specific title and supporting copy.
  final bool showIntroduction;

  /// Whether to use the approved routed Venue-page field composition.
  final bool alignWithVenuePageDesign;

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
    if (widget.alignWithVenuePageDesign) {
      return _buildVenuePageForm(context);
    } else {
      return _buildLegacyForm(context);
    }
  }

  Widget _buildVenuePageForm(BuildContext context) {
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
          error: _errorFor(lead.venueName),
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
          error: lead.venueType.fold(() => null, _errorFor),
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
          alignWithVenuePageDesign: true,
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
          error: lead.venueCount.fold(() => null, _errorFor),
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
          error: lead.venueCapacity.fold(() => null, _errorFor),
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
          error: _errorFor(lead.website),
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
          error: _errorFor(lead.firstName),
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
          error: _errorFor(lead.lastName),
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
          error: _errorFor(lead.role),
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
          error: _errorFor(lead.email),
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
          error: lead.phoneNumber.fold(() => null, _errorFor),
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
          showAcknowledgementCheckbox: true,
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

  Widget _buildLegacyForm(BuildContext context) {
    final l10n = context.l10n;
    final lead = widget.state.lead;
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
              _legacyField(
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
        if (widget.showIntroduction) ...[
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
        ],
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
              _legacyField(
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
              _legacyField(
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
                onSelected: _onChainStatusSelected,
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
              _legacyField(
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
              _legacyField(
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
        _legacyField(
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
        _legacyField(
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
        _legacyField(
          key: const Key('venueLeadRoleField'),
          controller: _roleController,
          label: l10n.venueLeadRequiredFieldLabel(l10n.venueLeadRoleLabel),
          error: _errorFor(lead.role),
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.roleChanged(value),
          ),
        ),
        _fieldGap,
        _legacyField(
          key: const Key('venueLeadEmailField'),
          controller: _emailController,
          label: l10n.venueLeadRequiredFieldLabel(l10n.venueLeadEmailLabel),
          error: _errorFor(lead.email),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => context.read<VenueLeadFormBloc>().add(
            VenueLeadFormEvent.emailChanged(value),
          ),
        ),
        _fieldGap,
        _legacyField(
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
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );

  String? _errorFor<T>(ValueObject<T> value) {
    if (widget.state.hasAttemptedSubmit) {
      return venueLeadValidationMessage(context.l10n, value);
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

  Widget _legacyField({
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
