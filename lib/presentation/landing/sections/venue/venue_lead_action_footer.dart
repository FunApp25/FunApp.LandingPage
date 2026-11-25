import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/core/config/venue_booking_url.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_action_button.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';

/// Independent booking and waitlist actions for the routed Venue form.
final class VenueLeadActionFooter extends StatefulWidget {
  /// Creates the Venue action area.
  const VenueLeadActionFooter({
    required this.isSubmitting,
    required this.hasSubmissionFailure,
    required this.onSubmit,
    super.key,
  });

  /// Whether a repository submission is in flight.
  final bool isSubmitting;

  /// Whether the latest settled submission failed operationally.
  final bool hasSubmissionFailure;

  /// Dispatches a form submission attempt.
  final VoidCallback onSubmit;

  @override
  State<VenueLeadActionFooter> createState() => _VenueLeadActionFooterState();
}

final class _VenueLeadActionFooterState extends State<VenueLeadActionFooter> {
  bool _bookingUnavailable = false;

  void _bookCall() {
    final uri = venueBookingUrl;
    if (uri != null) {
      try {
        launchExternalLinkInNewTab(uri);
      } on Object {
        setState(() => _bookingUnavailable = true);
      }
    } else {
      setState(() => _bookingUnavailable = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      key: const Key('venueLeadActionFooter'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (widget.hasSubmissionFailure)
          _errorMessage(
            context,
            l10n.venueLeadSubmissionFailure,
            key: const Key('venueLeadSubmissionFailure'),
          ),
        if (widget.isSubmitting)
          Semantics(
            key: const Key('venueLeadSubmissionProgress'),
            container: true,
            liveRegion: true,
            label: l10n.venueLeadSubmitting,
            child: const LinearProgressIndicator(
              color: AppColors.energeticPlum,
              backgroundColor: AppColors.beigeAccent,
            ),
          ),
        if (_bookingUnavailable)
          _errorMessage(context, l10n.venueLeadBookingUnavailable),
        LayoutBuilder(
          builder: (context, constraints) {
            final booking = BrandedFormActionButton(
              buttonKey: const Key('venueLeadBookingButton'),
              arrowKey: const Key('venueLeadBookingArrow'),
              label: l10n.venueLeadBookCall,
              foregroundColor: AppColors.warmCharcoal,
              expand: true,
              onPressed: _bookCall,
            );
            final waitlist = BrandedFormActionButton(
              buttonKey: const Key('venueLeadSubmitButton'),
              arrowKey: const Key('venueLeadSubmitArrow'),
              label: l10n.venueLeadJoinWaitlist,
              backgroundColor: AppColors.blueMain,
              disabledBackgroundColor: AppColors.blueMain.withValues(
                alpha: 0.45,
              ),
              expand: true,
              onPressed: widget.isSubmitting ? null : widget.onSubmit,
            );
            if (constraints.maxWidth >= 600) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: booking),
                    const SizedBox(width: 16),
                    Expanded(child: waitlist),
                  ],
                ),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  waitlist,
                  const SizedBox(height: 12),
                  booking,
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _errorMessage(BuildContext context, String message, {Key? key}) =>
      Semantics(
        key: key,
        container: true,
        liveRegion: true,
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
}
