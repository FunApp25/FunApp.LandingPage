import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Confirmation shown after a venue lead is accepted.
final class VenueLeadSuccess extends StatelessWidget {
  /// Creates the venue-lead confirmation.
  const VenueLeadSuccess({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      vertical: AppSizes.minimumPageGutter * 2,
    ),
    child: Semantics(
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
          const SizedBox(height: 16),
          Text(
            context.l10n.venueLeadSuccessBody,
            style: LandingTextStyles.sectionBody,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.venueLeadSuccessSignOff,
            style: LandingTextStyles.sectionBody,
          ),
        ],
      ),
    ),
  );
}
