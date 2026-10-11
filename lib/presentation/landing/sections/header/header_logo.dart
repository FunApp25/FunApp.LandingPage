import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';

/// Fun App wordmark used by the landing header.
final class HeaderLogo extends StatelessWidget {
  /// Creates the landing header logo.
  const HeaderLogo({required this.onSelected, super.key});

  /// Returns to the top of the landing page.
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    key: const Key('headerLogoLink'),
    label: context.l10n.brandName,
    link: true,
    onTap: onSelected,
    excludeSemantics: true,
    child: InkWell(
      onTap: onSelected,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(4),
      child: FunAppLogo(
        width: AppSizes.headerWordmarkWidth,
        height: AppSizes.headerWordmarkHeight,
        variant: FunAppLogoVariant.landingV2,
        semanticLabel: context.l10n.brandName,
      ),
    ),
  );
}
