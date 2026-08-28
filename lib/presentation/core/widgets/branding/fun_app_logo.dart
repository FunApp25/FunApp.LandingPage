import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';

/// Displays the Fun App wordmark.
final class FunAppLogo extends StatelessWidget {
  /// Creates a [FunAppLogo].
  const FunAppLogo({
    this.width,
    this.semanticLabel,
    this.excludeFromSemantics = true,
    super.key,
  });

  /// Width for the wordmark.
  final double? width;

  /// Semantic label when the wordmark is meaningful.
  final String? semanticLabel;

  /// Whether this wordmark should be hidden from semantics.
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    AppAssets.funAppWordmarkBlack,
    key: const Key('funAppLogo'),
    width: width,
    semanticsLabel: semanticLabel,
    excludeFromSemantics: excludeFromSemantics,
  );
}
