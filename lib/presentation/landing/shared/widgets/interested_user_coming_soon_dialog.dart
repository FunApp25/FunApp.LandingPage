import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_dialog.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Opens the presentation-only prospective-user MVP message.
Future<void> showInterestedUserComingSoonDialog(BuildContext context) async {
  await showLandingDialog<void>(
    context: context,
    semanticLabel: context.l10n.landingInterestedUserComingSoonTitle,
    closeTooltip: context.l10n.landingDialogClose,
    builder: (context) => const InterestedUserComingSoonDialogContent(),
  );
}

/// Localized prospective-user content with no collection or business action.
final class InterestedUserComingSoonDialogContent extends StatelessWidget {
  /// Creates the coming-soon message.
  const InterestedUserComingSoonDialogContent({super.key});

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('interestedUserComingSoonDialogContent'),
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(
          context.l10n.landingInterestedUserComingSoonTitle,
          key: const Key('interestedUserComingSoonTitle'),
          style: LandingTextStyles.sectionHeading,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        context.l10n.landingInterestedUserComingSoonBody,
        key: const Key('interestedUserComingSoonBody'),
        style: LandingTextStyles.sectionBody,
      ),
    ],
  );
}
