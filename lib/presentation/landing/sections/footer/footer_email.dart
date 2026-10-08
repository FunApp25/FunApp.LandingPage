import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Shared static contact-email presentation from the landing design.
final class FooterEmail extends StatelessWidget {
  /// Creates the static footer email presentation.
  const FooterEmail({
    required this.email,
    this.semanticKey = const Key('footerEmailSemantics'),
    this.envelopeKey = const Key('footerEnvelope'),
    this.textKey = const Key('footerEmailText'),
    super.key,
  });

  /// Visible and semantic contact address.
  final String email;

  /// Key for the combined static email semantics.
  final Key semanticKey;

  /// Key for the decorative envelope asset.
  final Key envelopeKey;

  /// Key for the visible email text.
  final Key textKey;

  @override
  Widget build(BuildContext context) => Semantics(
    key: semanticKey,
    label: email,
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.yellowAccent,
            borderRadius: BorderRadius.all(
              Radius.circular(AppSizes.pillRadius),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              AppAssets.footerEnvelope,
              key: envelopeKey,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.blueMain,
                BlendMode.srcIn,
              ),
              excludeFromSemantics: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            email,
            key: textKey,
            style: LandingTextStyles.footerEmail,
          ),
        ),
      ],
    ),
  );
}
