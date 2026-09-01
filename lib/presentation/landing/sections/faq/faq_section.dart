import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/content/faq_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/faq/faq_item.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Expandable FAQ from Figma node `2190:1644`.
///
/// Expansion is presentation-local: the first item starts open, and every item
/// toggles independently without changing the landing page's scroll structure.
final class FaqSection extends StatefulWidget {
  /// Creates the FAQ section.
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

final class _FaqSectionState extends State<FaqSection> {
  final Set<int> _expandedIndexes = <int>{0};
  final List<FocusNode> _questionFocusNodes = [];
  late List<FaqItemContent> _items;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _items = buildFaqItems(context.l10n);
    while (_questionFocusNodes.length < _items.length) {
      _questionFocusNodes.add(
        FocusNode(
          debugLabel: 'FAQ question ${_questionFocusNodes.length + 1}',
        ),
      );
    }
    while (_questionFocusNodes.length > _items.length) {
      _questionFocusNodes.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    for (final focusNode in _questionFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _toggle(int index) {
    setState(
      () {
        if (_expandedIndexes.contains(index)) {
          _expandedIndexes.remove(index);
        } else {
          _expandedIndexes.add(index);
        }
      },
    );
  }

  @override
  // This block body keeps the responsive layout calculation readable.
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return ColoredBox(
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
          final headingSize = AppSizes.sectionHeadingSizeFor(availableWidth);
          final questionSize = switch (availableWidth) {
            >= 1200 => 32.0,
            >= 600 => 30.0,
            _ => 27.0,
          };
          final questionLineHeight = switch (availableWidth) {
            >= 1200 => 40.0,
            >= 600 => 38.0,
            _ => 34.0,
          };
          final itemVerticalPadding = switch (availableWidth) {
            >= 1200 => 32.0,
            >= 600 => 28.0,
            _ => 24.0,
          };
          final itemHorizontalPadding = switch (availableWidth) {
            >= 1200 => 24.0,
            >= 600 => 22.0,
            _ => 18.0,
          };

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: pageGutter,
              vertical: verticalPadding,
            ),
            child: Column(
              key: const Key('faqContent'),
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 728),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SectionEyebrow(
                        label: context.l10n.landingFaqEyebrow.toUpperCase(),
                        glyphAsset: AppAssets.faqGlyph,
                        foregroundColor: AppColors.energeticPlum,
                        glyphSize: const Size(22, 12),
                        alignment: MainAxisAlignment.center,
                        textAlign: TextAlign.center,
                        glyphKey: const Key('faqEyebrowGlyph'),
                      ),
                      const SizedBox(height: 24),
                      Semantics(
                        key: const Key('faqHeadingSemantics'),
                        header: true,
                        child: Text(
                          context.l10n.landingFaqHeading,
                          key: const Key('faqHeadingText'),
                          textAlign: TextAlign.center,
                          style: LandingTextStyles.sectionHeading.copyWith(
                            fontSize: headingSize,
                            letterSpacing: headingSize * -0.01,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: availableWidth >= 1200 ? 48 : 32),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 902),
                  child: Column(
                    key: const Key('faqItems'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < _items.length; index++)
                        FaqItem(
                          index: index,
                          content: _items[index],
                          isExpanded: _expandedIndexes.contains(index),
                          focusNode: _questionFocusNodes[index],
                          questionSize: questionSize,
                          questionLineHeight: questionLineHeight,
                          verticalPadding: itemVerticalPadding,
                          horizontalPadding: itemHorizontalPadding,
                          onToggle: () => _toggle(index),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
