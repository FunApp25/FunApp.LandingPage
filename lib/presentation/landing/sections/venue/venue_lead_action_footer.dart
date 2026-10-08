import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Action and submission status kept visible below the scrolling venue form.
final class VenueLeadActionFooter extends StatelessWidget {
  /// Creates the current venue dialog action area.
  const VenueLeadActionFooter({
    required this.isSubmitting,
    required this.submissionSucceeded,
    required this.hasSubmissionFailure,
    required this.onClose,
    required this.onSubmit,
    this.constrainFailureHeight = true,
    this.alignWithVenuePageDesign = false,
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

  /// Whether failure copy should flex within the legacy dialog footer.
  final bool constrainFailureHeight;

  /// Whether to use the approved routed Venue-page Send treatment.
  final bool alignWithVenuePageDesign;

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
            if (constrainFailureHeight)
              Flexible(child: _failureMessage(context))
            else
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
          if (alignWithVenuePageDesign)
            LayoutBuilder(
              builder: (context, constraints) {
                final expands = constraints.maxWidth < 760;
                return Align(
                  child: SizedBox(
                    width: expands ? double.infinity : null,
                    height: 48,
                    child: FilledButton(
                      key: const Key('venueLeadSubmitButton'),
                      onPressed: isSubmitting ? null : onSubmit,
                      style: ButtonStyle(
                        minimumSize: WidgetStatePropertyAll(
                          Size(expands ? 0 : 144, 48),
                        ),
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.disabled)) {
                              return AppColors.warmOrange.withValues(
                                alpha: 0.45,
                              );
                            } else {
                              return AppColors.warmOrange;
                            }
                          },
                        ),
                        foregroundColor: const WidgetStatePropertyAll(
                          AppColors.lightForeground,
                        ),
                        overlayColor: WidgetStateProperty.resolveWith<Color?>((
                          states,
                        ) {
                          if (states.contains(WidgetState.focused)) {
                            return AppColors.energeticPlum.withValues(
                              alpha: 0.16,
                            );
                          } else if (states.contains(WidgetState.hovered)) {
                            return AppColors.lightForeground.withValues(
                              alpha: 0.08,
                            );
                          } else {
                            return null;
                          }
                        }),
                        shape: const WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppSizes.pillRadius),
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.venueLeadSubmit,
                            style: LandingTextStyles.heroCta.copyWith(
                              color: AppColors.lightForeground,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            AppAssets.venueSendArrowUpRight,
                            key: const Key('venueLeadSubmitArrow'),
                            excludeFromSemantics: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          else
            FilledButton(
              key: const Key('venueLeadSubmitButton'),
              onPressed: isSubmitting ? null : onSubmit,
              child: Text(l10n.venueLeadSubmit),
            ),
        ],
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
