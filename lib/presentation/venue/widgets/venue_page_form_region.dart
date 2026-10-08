import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_action_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_form.dart';

/// Preserves the established Venue form workflow before confirmed success.
final class VenuePageFormRegion extends StatelessWidget {
  /// Creates the routed Venue form region.
  const VenuePageFormRegion({
    required this.onPrivacyNoticeSelected,
    super.key,
  });

  /// Opens the authoritative Privacy Notice without replacing the page draft.
  final VoidCallback onPrivacyNoticeSelected;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<VenueLeadFormBloc, VenueLeadFormState>(
        builder: (context, state) {
          final submissionFailure = state.submissionResult.fold<AppFailure?>(
            () => null,
            (result) => result.fold((failure) => failure, (_) => null),
          );

          return Column(
            key: const Key('venuePageFormRegion'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VenueLeadForm(
                state: state,
                onPrivacyNoticeSelected: onPrivacyNoticeSelected,
                showIntroduction: false,
                alignWithVenuePageDesign: true,
              ),
              LayoutBuilder(
                builder: (context, constraints) => SizedBox(
                  height: constraints.maxWidth < 600 ? 40 : 64,
                ),
              ),
              VenueLeadActionFooter(
                isSubmitting: state.isSubmitting,
                submissionSucceeded: false,
                hasSubmissionFailure: submissionFailure != null,
                onClose: null,
                onSubmit: () => context.read<VenueLeadFormBloc>().add(
                  const VenueLeadFormEvent.submitted(),
                ),
                constrainFailureHeight: false,
                alignWithVenuePageDesign: true,
              ),
            ],
          );
        },
      );
}
