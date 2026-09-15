import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Confirmation shown after a venue lead is accepted.
final class VenueLeadSuccess extends StatelessWidget {
  /// Creates the venue-lead confirmation.
  const VenueLeadSuccess({required this.onClose, super.key});

  /// Dismisses the completed venue flow.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Semantics(
    key: const Key('venueLeadSuccess'),
    container: true,
    liveRegion: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            context.l10n.venueLeadSuccessTitle,
            key: const Key('venueLeadSuccessTitle'),
            style: LandingTextStyles.sectionHeading,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('venueLeadSuccessCloseButton'),
          onPressed: onClose,
          child: Text(context.l10n.landingDialogClose),
        ),
      ],
    ),
  );
}
