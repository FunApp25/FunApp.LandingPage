import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';

/// Active Fun App wordmark treatments.
enum FunAppLogoVariant {
  /// Existing single-color wordmark used on warm-charcoal surfaces.
  charcoal,

  /// Dual-color V2 wordmark from the current landing-page header.
  landingV2,
}

/// Displays the Fun App wordmark.
final class FunAppLogo extends StatelessWidget {
  /// Creates a [FunAppLogo].
  const FunAppLogo({
    this.width,
    this.height,
    this.variant = FunAppLogoVariant.charcoal,
    this.semanticLabel,
    this.excludeFromSemantics = true,
    this.svgKey = const Key('funAppLogo'),
    super.key,
  });

  /// Width for the wordmark.
  final double? width;

  /// Height for the wordmark.
  final double? height;

  /// Visual wordmark treatment.
  final FunAppLogoVariant variant;

  /// Semantic label when the wordmark is meaningful.
  final String? semanticLabel;

  /// Whether this wordmark should be hidden from semantics.
  final bool excludeFromSemantics;

  /// Key applied to the underlying SVG presentation boundary.
  final Key? svgKey;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    switch (variant) {
      FunAppLogoVariant.charcoal => AppAssets.funAppWordmarkBlack,
      FunAppLogoVariant.landingV2 => AppAssets.funAppLogoV2,
    },
    key: svgKey,
    width: width,
    height: height,
    semanticsLabel: semanticLabel,
    excludeFromSemantics: excludeFromSemantics,
  );
}
