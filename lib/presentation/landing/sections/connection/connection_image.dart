import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';

/// Responsive image surface for the connection section.
final class ConnectionImage extends StatelessWidget {
  /// Creates the connection image.
  const ConnectionImage({super.key});

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1360 / 614,
    child: ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(AppSizes.cardRadius),
      ),
      child: Semantics(
        key: const Key('connectionImageSemantics'),
        label: context.l10n.landingConnectionImageDescription,
        image: true,
        excludeSemantics: true,
        child: Image.asset(
          AppAssets.connectionGroup,
          key: const Key('connectionExperienceImage'),
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
      ),
    ),
  );
}
