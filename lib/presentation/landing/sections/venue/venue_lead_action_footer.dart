import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';

/// Action and submission status kept visible below the scrolling venue form.
final class VenueLeadActionFooter extends StatelessWidget {
  /// Creates the current venue dialog action area.
  const VenueLeadActionFooter({
    required this.isSubmitting,
    required this.submissionSucceeded,
    required this.hasSubmissionFailure,
    required this.onClose,
    required this.onSubmit,
    super.key,
  });

  /// Whether a repository submission is in flight.
  final bool isSubmitting;

  /// Whether the current draft was submitted successfully.
  final bool submissionSucceeded;

  /// Whether the latest settled submission failed operationally.
  final bool hasSubmissionFailure;

  /// Dismisses the successful dialog.
  final VoidCallback? onClose;

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
        if (submissionSucceeded)
          FilledButton(
            key: const Key('venueLeadSuccessCloseButton'),
            onPressed: onClose,
            child: Text(l10n.landingDialogClose),
          )
        else ...[
          if (hasSubmissionFailure) ...[
            Flexible(
              child: SingleChildScrollView(
                child: Semantics(
                  key: const Key('venueLeadSubmissionFailure'),
                  container: true,
                  liveRegion: true,
                  child: Text(
                    l10n.venueLeadSubmissionFailure,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
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
          FilledButton(
            key: const Key('venueLeadSubmitButton'),
            onPressed: isSubmitting ? null : onSubmit,
            child: Text(l10n.venueLeadSubmit),
          ),
        ],
      ],
    );
  }
}
