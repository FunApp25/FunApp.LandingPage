import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/section_eyebrow.dart';

/// Limited-time Founding Friend offer from Figma node `2243:2549`.
final class FoundingOfferSection extends StatelessWidget {
  /// Creates the founding-offer section.
  const FoundingOfferSection({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: const Key('foundingOfferBackground'),
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
              constraints: const BoxConstraints(maxWidth: 884),
              child: _FoundingOfferContent(
                statementSize: AppSizes.statementHeadingSizeFor(
                  availableWidth,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

final class _FoundingOfferContent extends StatelessWidget {
  const _FoundingOfferContent({required this.statementSize});

  final double statementSize;

  @override
  Widget build(BuildContext context) {
    final leading = context.l10n.landingFoundingOfferLeading;
    final foundingFriend = context.l10n.landingFoundingOfferFoundingFriend;
    final trailing = context.l10n.landingFoundingOfferTrailing;
    final semanticLabel = '$leading$foundingFriend$trailing';
    final letterSpacing = statementSize * -0.01;
    final regularStyle = LandingTextStyles.foundingOfferStatement.copyWith(
      fontSize: statementSize,
      letterSpacing: letterSpacing,
    );
    final emphasisStyle = LandingTextStyles.foundingOfferStatementEmphasis
        .copyWith(
          fontSize: statementSize,
          letterSpacing: letterSpacing,
        );

    return Column(
      key: const Key('foundingOfferContent'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionEyebrow(
          label: context.l10n.landingFoundingOfferEyebrow,
          glyphAsset: AppAssets.foundingOfferGlyph,
          foregroundColor: AppColors.energeticPlum,
          glyphSize: const Size.square(12),
          alignment: MainAxisAlignment.center,
          textAlign: TextAlign.center,
          glyphKey: const Key('foundingOfferGlyph'),
        ),
        const SizedBox(height: 24),
        Semantics(
          key: const Key('foundingOfferHeadingSemantics'),
          label: semanticLabel,
          header: true,
          excludeSemantics: true,
          child: Text.rich(
            key: const Key('foundingOfferStatementText'),
            TextSpan(
              text: leading,
              style: regularStyle,
              children: [
                TextSpan(text: foundingFriend, style: emphasisStyle),
                TextSpan(text: trailing),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
