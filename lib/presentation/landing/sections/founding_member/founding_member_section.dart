import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_card_grid.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_introduction.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_layout.dart';

/// Founding Member explanation from Figma node `2243:2446`.
final class FoundingMemberSection extends StatelessWidget {
  /// Creates the Founding Member explanation section.
  const FoundingMemberSection({super.key});

  static const _wideCompositionWidth = 1360.0;

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: const Key('foundingMemberBackground'),
    color: AppColors.beigeAccent,
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
                  final cards = _benefitCards(context);
                  if (contentConstraints.maxWidth >= _wideCompositionWidth) {
                    return Row(
                      key: const Key('foundingMemberWideLayout'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: foundingMemberIntroWidth,
                          child: FoundingMemberIntroduction(headingSize: 44),
                        ),
                        const SizedBox(width: foundingMemberCardGap),
                        Expanded(
                          child: FoundingMemberCardGrid(
                            cards: cards,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      key: const Key('foundingMemberStackedIntroLayout'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: foundingMemberIntroWidth,
                            child: FoundingMemberIntroduction(
                              headingSize: AppSizes.sectionHeadingSizeFor(
                                availableWidth,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: availableWidth < 600 ? 32 : 48),
                        FoundingMemberCardGrid(
                          cards: cards,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    ),
  );

  static List<FoundingMemberCardContent> _benefitCards(
    BuildContext context,
  ) => [
    (
      semanticId: 'recognised',
      iconAsset: AppAssets.foundingMemberUsers,
      title: context.l10n.landingFoundingMemberRecognisedTitle,
      body: context.l10n.landingFoundingMemberRecognisedBody,
    ),
    (
      semanticId: 'access',
      iconAsset: AppAssets.foundingMemberRocket,
      title: context.l10n.landingFoundingMemberAccessTitle,
      body: context.l10n.landingFoundingMemberAccessBody,
    ),
    (
      semanticId: 'voice',
      iconAsset: AppAssets.foundingMemberChat,
      title: context.l10n.landingFoundingMemberVoiceTitle,
      body: context.l10n.landingFoundingMemberVoiceBody,
    ),
  ];
}
