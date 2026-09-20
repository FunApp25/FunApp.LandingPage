import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_action_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_form.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_success.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_dialog.dart';

/// Creates a fresh venue form BLoC.
typedef VenueLeadFormBlocFactory = VenueLeadFormBloc Function();

/// Opens the functional venue-interest dialog.
Future<void> showVenueLeadDialog(
  BuildContext context, {
  required VenueLeadFormBlocFactory createBloc,
  required VoidCallback onPrivacyNoticeSelected,
}) => showLandingDialogRoute<void>(
  context: context,
  barrierLabel: context.l10n.landingDialogClose,
  builder: (context) => BlocProvider(
    create: (_) => createBloc(),
    child: VenueLeadDialog(onPrivacyNoticeSelected: onPrivacyNoticeSelected),
  ),
);

/// Coordinates dialog presentation with the venue form submission state.
final class VenueLeadDialog extends StatelessWidget {
  /// Creates the venue dialog content.
  const VenueLeadDialog({required this.onPrivacyNoticeSelected, super.key});

  /// Opens the notice in another browser context without changing this draft.
  final VoidCallback onPrivacyNoticeSelected;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<VenueLeadFormBloc, VenueLeadFormState>(
        builder: (context, state) {
          final submissionFailure = state.submissionResult.fold<AppFailure?>(
            () => null,
            (result) => result.fold((failure) => failure, (_) => null),
          );
          final submissionSucceeded = state.submissionResult.fold(
            () => false,
            (result) => result.isRight(),
          );
          final closeDialog = state.isSubmitting
              ? null
              : () => Navigator.of(context).pop();
          return PopScope<void>(
            key: const Key('venueLeadDialogPopScope'),
            canPop: !state.isSubmitting,
            child: LandingDialog(
              key: ValueKey(submissionSucceeded),
              semanticLabel: context.l10n.venueLeadDialogTitle,
              closeTooltip: context.l10n.landingDialogClose,
              onClose: closeDialog,
              footer: VenueLeadActionFooter(
                isSubmitting: state.isSubmitting,
                submissionSucceeded: submissionSucceeded,
                hasSubmissionFailure: submissionFailure != null,
                onClose: closeDialog,
                onSubmit: () => context.read<VenueLeadFormBloc>().add(
                  const VenueLeadFormEvent.submitted(),
                ),
              ),
              child: submissionSucceeded
                  ? const VenueLeadSuccess()
                  : VenueLeadForm(
                      state: state,
                      onPrivacyNoticeSelected: onPrivacyNoticeSelected,
                    ),
            ),
          );
        },
      );
}
