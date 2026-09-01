import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';

/// Semantic hero artwork shared by both hero compositions.
final class HeroImage extends StatelessWidget {
  /// Creates the landing hero artwork.
  const HeroImage({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    key: const Key('heroImageSemantics'),
    label: context.l10n.landingHeroImageDescription,
    image: true,
    excludeSemantics: true,
    child: Image.asset(
      AppAssets.heroPeople,
      key: const Key('heroPeopleImage'),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
    ),
  );
}
