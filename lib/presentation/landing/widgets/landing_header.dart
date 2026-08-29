import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/branding/fun_app_logo.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_cta_button.dart';

/// Landing-page header from Figma node `2190:1568`.
final class LandingHeader extends StatelessWidget {
  /// Creates the landing-page header.
  const LandingHeader({super.key});

  // Minimum width required by the complete localized horizontal composition.
  // Below it, content wraps without hiding or inventing navigation behavior.
  static const _horizontalCompositionWidth = 880.0;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.lightForeground,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppSizes.desktopPageWidth;
        final pageGutter = AppSizes.pageGutterFor(availableWidth);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: pageGutter,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: LayoutBuilder(
                builder: (context, contentConstraints) {
                  final navigationLabels = <String>[
                    context.l10n.landingHeaderOurBelief,
                    context.l10n.landingHeaderMembership,
                    context.l10n.landingHeaderFoundingFriends,
                    context.l10n.landingHeaderForVenues,
                  ];
                  final usesHorizontalComposition =
                      contentConstraints.maxWidth >=
                      _horizontalCompositionWidth;

                  return usesHorizontalComposition
                      ? _HorizontalHeader(
                          navigationLabels: navigationLabels,
                          contactLabel: context.l10n.landingHeaderContactUs,
                        )
                      : _WrappedHeader(
                          navigationLabels: navigationLabels,
                          contactLabel: context.l10n.landingHeaderContactUs,
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

final class _HorizontalHeader extends StatelessWidget {
  const _HorizontalHeader({
    required this.navigationLabels,
    required this.contactLabel,
  });

  final List<String> navigationLabels;
  final String contactLabel;

  @override
  Widget build(BuildContext context) => Row(
    key: const Key('landingHeaderHorizontalLayout'),
    children: [
      const _HeaderLogo(),
      const Spacer(),
      _NavigationRow(labels: navigationLabels),
      const SizedBox(width: 56),
      LandingCtaButton(
        key: const Key('landingHeaderContactCta'),
        label: contactLabel,
        size: LandingCtaSize.compact,
      ),
    ],
  );
}

final class _WrappedHeader extends StatelessWidget {
  const _WrappedHeader({
    required this.navigationLabels,
    required this.contactLabel,
  });

  final List<String> navigationLabels;
  final String contactLabel;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('landingHeaderWrappedLayout'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _HeaderLogo(),
      const SizedBox(height: 16),
      Wrap(
        spacing: 24,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final label in navigationLabels) _NavigationLabel(label: label),
          LandingCtaButton(
            key: const Key('landingHeaderContactCta'),
            label: contactLabel,
            size: LandingCtaSize.compact,
          ),
        ],
      ),
    ],
  );
}

final class _HeaderLogo extends StatelessWidget {
  const _HeaderLogo();

  @override
  Widget build(BuildContext context) => FunAppLogo(
    width: AppSizes.headerWordmarkWidth,
    height: AppSizes.headerWordmarkHeight,
    variant: FunAppLogoVariant.landingV2,
    semanticLabel: context.l10n.brandName,
    excludeFromSemantics: false,
  );
}

final class _NavigationRow extends StatelessWidget {
  const _NavigationRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < labels.length; index++) ...[
        if (index > 0) const SizedBox(width: 40),
        _NavigationLabel(label: labels[index]),
      ],
    ],
  );
}

final class _NavigationLabel extends StatelessWidget {
  const _NavigationLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    maxLines: 1,
    style: AppTextStyles.landingHeaderNavigation,
  );
}
