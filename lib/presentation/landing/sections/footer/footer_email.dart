import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Static contact-email presentation in the landing footer.
final class FooterEmail extends StatelessWidget {
  /// Creates the static footer email presentation.
  const FooterEmail({required this.email, super.key});

  /// Visible and semantic contact address.
  final String email;

  @override
  Widget build(BuildContext context) => Semantics(
    key: const Key('footerEmailSemantics'),
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
              key: const Key('footerEnvelope'),
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
            key: const Key('footerEmailText'),
            style: LandingTextStyles.footerEmail,
          ),
        ),
      ],
    ),
  );
}
