import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_action_button.dart';

/// Send action and submission status for the routed Venue form.
final class VenueLeadActionFooter extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      key: const Key('venueLeadActionFooter'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasSubmissionFailure) ...[
          _failureMessage(context),
          const SizedBox(height: 12),
        ],
        if (isSubmitting) ...[
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
          const SizedBox(height: 12),
        ],
        BrandedFormActionButton(
          buttonKey: const Key('venueLeadSubmitButton'),
          arrowKey: const Key('venueLeadSubmitArrow'),
          label: l10n.venueLeadSubmit,
          onPressed: isSubmitting ? null : onSubmit,
          disabledBackgroundColor: AppColors.warmOrange.withValues(
            alpha: 0.45,
          ),
        ),
      ],
    );
  }

  Widget _failureMessage(BuildContext context) => SingleChildScrollView(
    child: Semantics(
      key: const Key('venueLeadSubmissionFailure'),
      container: true,
      liveRegion: true,
      child: Text(
        context.l10n.venueLeadSubmissionFailure,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ),
  );
}
