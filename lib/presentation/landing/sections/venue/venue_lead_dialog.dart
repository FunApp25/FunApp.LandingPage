import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_form.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_success.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_dialog.dart';

/// Creates a fresh venue form BLoC.
typedef VenueLeadFormBlocFactory = VenueLeadFormBloc Function();

/// User-selected destination after the venue dialog closes.
enum VenueLeadDialogResult {
  /// The user selected the hosted Privacy Notice.
  privacyNotice,
}

/// Opens the functional venue-interest dialog.
Future<VenueLeadDialogResult?> showVenueLeadDialog(
  BuildContext context, {
  required VenueLeadFormBlocFactory createBloc,
}) => showDialog<VenueLeadDialogResult>(
  context: context,
  barrierLabel: context.l10n.landingDialogClose,
  builder: (context) => BlocProvider(
    create: (_) => createBloc(),
    child: const VenueLeadDialog(),
  ),
);

/// Coordinates dialog presentation with the venue form submission state.
final class VenueLeadDialog extends StatelessWidget {
  /// Creates the venue dialog content.
  const VenueLeadDialog({super.key});

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
          final openPrivacyNotice = state.isSubmitting
              ? null
              : () => Navigator.of(
                  context,
                ).pop(VenueLeadDialogResult.privacyNotice);

          return PopScope<VenueLeadDialogResult>(
            key: const Key('venueLeadDialogPopScope'),
            canPop: !state.isSubmitting,
            child: LandingDialog(
              semanticLabel: context.l10n.venueLeadDialogTitle,
              closeTooltip: context.l10n.landingDialogClose,
              onClose: closeDialog,
              child: submissionSucceeded
                  ? VenueLeadSuccess(onClose: closeDialog!)
                  : VenueLeadForm(
                      state: state,
                      submissionFailure: submissionFailure,
                      onPrivacyNoticeSelected: openPrivacyNotice,
                    ),
            ),
          );
        },
      );
}
