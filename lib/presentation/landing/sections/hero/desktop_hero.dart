import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/hero/hero_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/hero/hero_image.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Wide Figma composition for the landing hero.
final class DesktopHero extends StatelessWidget {
  /// Creates the wide landing hero composition.
  const DesktopHero({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    key: const Key('heroDesktopLayout'),
    constraints: const BoxConstraints(minHeight: 644),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(80, 106, 0, 106),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 600,
              child: HeroContent(
                headlineSize: 60,
                supportingStyle: LandingTextStyles.heroSupporting,
              ),
            ),
          ),
        ),
        const Positioned(
          top: -113,
          right: -99,
          width: 706,
          height: 717,
          child: HeroImage(),
        ),
      ],
    ),
  );
}
