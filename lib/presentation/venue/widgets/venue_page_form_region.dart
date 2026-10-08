import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_action_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_form.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_success.dart';

/// Preserves the established Venue form workflow within the routed page.
final class VenuePageFormRegion extends StatelessWidget {
  /// Creates the routed Venue form region.
  const VenuePageFormRegion({
    required this.onPrivacyNoticeSelected,
    required this.onSuccessClose,
    super.key,
  });

  /// Opens the authoritative Privacy Notice without replacing the page draft.
  final VoidCallback onPrivacyNoticeSelected;

  /// Leaves the temporary success state using the current page route.
  final VoidCallback onSuccessClose;

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

          return PopScope<void>(
            key: const Key('venuePagePopScope'),
            canPop: !state.isSubmitting,
            child: Column(
              key: const Key('venuePageFormRegion'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (submissionSucceeded)
                  const VenueLeadSuccess()
                else
                  VenueLeadForm(
                    state: state,
                    onPrivacyNoticeSelected: onPrivacyNoticeSelected,
                    showIntroduction: false,
                    alignWithVenuePageDesign: true,
                  ),
                if (submissionSucceeded)
                  const SizedBox(height: 24)
                else
                  LayoutBuilder(
                    builder: (context, constraints) => SizedBox(
                      height: constraints.maxWidth < 600 ? 40 : 64,
                    ),
                  ),
                VenueLeadActionFooter(
                  isSubmitting: state.isSubmitting,
                  submissionSucceeded: submissionSucceeded,
                  hasSubmissionFailure: submissionFailure != null,
                  onClose: state.isSubmitting ? null : onSuccessClose,
                  onSubmit: () => context.read<VenueLeadFormBloc>().add(
                    const VenueLeadFormEvent.submitted(),
                  ),
                  constrainFailureHeight: false,
                  alignWithVenuePageDesign: true,
                ),
              ],
            ),
          );
        },
      );
}
