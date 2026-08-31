import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/section_eyebrow.dart';

/// Alternative connection experience from Figma node `2190:1596`.
final class ConnectionExperienceSection extends StatelessWidget {
  /// Creates the connection-experience section.
  const ConnectionExperienceSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.lightForeground,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = AppSizes.pageGutterFor(availableWidth);
        final verticalPadding = AppSizes.sectionVerticalPaddingFor(
          availableWidth,
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: pageGutter,
            vertical: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: LayoutBuilder(
                builder: (context, contentConstraints) {
                  final introductionGap = switch (availableWidth) {
                    >= 1200 => 80.0,
                    >= 600 => 64.0,
                    _ => 40.0,
                  };

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ConnectionIntroduction(
                        availableWidth: contentConstraints.maxWidth,
                        headingSize: AppSizes.sectionHeadingSizeFor(
                          availableWidth,
                        ),
                      ),
                      SizedBox(height: introductionGap),
                      const _ConnectionImage(),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    ),
  );
}

final class _ConnectionIntroduction extends StatelessWidget {
  const _ConnectionIntroduction({
    required this.availableWidth,
    required this.headingSize,
  });

  // Exact desktop columns need 443px + 672px plus the 245px Figma gap.
  static const _minimumWideCompositionWidth = 1195.0;

  final double availableWidth;
  final double headingSize;

  @override
  Widget build(BuildContext context) {
    if (availableWidth >= _minimumWideCompositionWidth) {
      return Row(
        key: const Key('connectionWideLayout'),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 443,
            child: _ConnectionTitle(headingSize: headingSize),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: SizedBox(width: 672, child: _ConnectionBody()),
          ),
        ],
      );
    } else {
      return Column(
        key: const Key('connectionStackedLayout'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConnectionTitle(headingSize: headingSize),
          const SizedBox(height: 32),
          const _ConnectionBody(),
        ],
      );
    }
  }
}

final class _ConnectionTitle extends StatelessWidget {
  const _ConnectionTitle({required this.headingSize});

  final double headingSize;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionEyebrow(
        label: context.l10n.landingConnectionEyebrow,
        glyphAsset: AppAssets.roundedSparkleDiamond,
        foregroundColor: AppColors.warmOrange,
        glyphSize: const Size.square(12),
        glyphKey: const Key('connectionEyebrowGlyph'),
      ),
      const SizedBox(height: 16),
      Semantics(
        key: const Key('connectionHeadingSemantics'),
        label: context.l10n.landingConnectionHeading,
        header: true,
        excludeSemantics: true,
        child: Text(
          context.l10n.landingConnectionHeading,
          style: LandingTextStyles.sectionHeading.copyWith(
            fontSize: headingSize,
            letterSpacing: headingSize * -0.01,
          ),
        ),
      ),
    ],
  );
}

final class _ConnectionBody extends StatelessWidget {
  const _ConnectionBody();

  @override
  Widget build(BuildContext context) => Text(
    context.l10n.landingConnectionBody,
    key: const Key('connectionBodyText'),
    style: LandingTextStyles.sectionBody,
  );
}

final class _ConnectionImage extends StatelessWidget {
  const _ConnectionImage();

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
