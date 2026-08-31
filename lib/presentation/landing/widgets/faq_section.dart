import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/content/faq_content.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/section_eyebrow.dart';

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
                        _FaqItem(
                          index: index,
                          content: _items[index],
                          isExpanded: _expandedIndexes.contains(index),
                          focusNode: _questionFocusNodes[index],
                          questionSize: questionSize,
                          questionLineHeight: questionLineHeight,
                          verticalPadding: itemVerticalPadding,
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

final class _FaqItem extends StatefulWidget {
  const _FaqItem({
    required this.index,
    required this.content,
    required this.isExpanded,
    required this.focusNode,
    required this.questionSize,
    required this.questionLineHeight,
    required this.verticalPadding,
    required this.onToggle,
  });

  final int index;
  final FaqItemContent content;
  final bool isExpanded;
  final FocusNode focusNode;
  final double questionSize;
  final double questionLineHeight;
  final double verticalPadding;
  final VoidCallback onToggle;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

final class _FaqItemState extends State<_FaqItem> {
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final answerRightPadding = constraints.maxWidth >= 520 ? 44.0 : 0.0;

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          key: Key('faqItemSurface${widget.index}'),
          behavior: HitTestBehavior.opaque,
          onTap: widget.onToggle,
          excludeFromSemantics: true,
          child: DecoratedBox(
            key: Key('faqItemVisualSurface${widget.index}'),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isFocused
                    ? AppColors.energeticPlum
                    : Colors.transparent,
                width: 2,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            position: DecorationPosition.foreground,
            child: DecoratedBox(
              key: Key('faqItemStateBackground${widget.index}'),
              decoration: BoxDecoration(
                color: _isFocused || _isHovered
                    ? AppColors.energeticPlum.withValues(
                        alpha: _isFocused ? 0.08 : 0.06,
                      )
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.warmCharcoal.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    key: Key('faqQuestionSemantics${widget.index}'),
                    container: true,
                    label: widget.content.question,
                    button: true,
                    expanded: widget.isExpanded,
                    onTap: widget.onToggle,
                    excludeSemantics: true,
                    child: FocusableActionDetector(
                      key: Key('faqQuestionControl${widget.index}'),
                      focusNode: widget.focusNode,
                      mouseCursor: SystemMouseCursors.click,
                      shortcuts: const <ShortcutActivator, Intent>{
                        SingleActivator(LogicalKeyboardKey.enter):
                            ActivateIntent(),
                        SingleActivator(LogicalKeyboardKey.space):
                            ActivateIntent(),
                      },
                      actions: <Type, Action<Intent>>{
                        ActivateIntent: CallbackAction<ActivateIntent>(
                          onInvoke: (_) {
                            widget.onToggle();
                            return null;
                          },
                        ),
                      },
                      onFocusChange: (value) {
                        setState(() => _isFocused = value);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: widget.verticalPadding,
                          bottom: widget.isExpanded
                              ? 0
                              : widget.verticalPadding,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.content.question,
                                key: Key('faqQuestionText${widget.index}'),
                                style: LandingTextStyles.faqQuestion.copyWith(
                                  fontSize: widget.questionSize,
                                  height:
                                      widget.questionLineHeight /
                                      widget.questionSize,
                                  letterSpacing: widget.questionSize * -0.01,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SvgPicture.asset(
                              widget.isExpanded
                                  ? AppAssets.faqMinus
                                  : AppAssets.faqPlus,
                              key: Key('faqIcon${widget.index}'),
                              width: 28,
                              height: 28,
                              excludeFromSemantics: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (widget.isExpanded)
                    Padding(
                      key: Key('faqAnswer${widget.index}'),
                      padding: EdgeInsets.only(
                        top: widget.verticalPadding >= 32 ? 20 : 16,
                        right: answerRightPadding,
                        bottom: widget.verticalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (
                            var paragraphIndex = 0;
                            paragraphIndex < widget.content.paragraphs.length;
                            paragraphIndex++
                          ) ...[
                            _FaqAnswerParagraph(
                              paragraph:
                                  widget.content.paragraphs[paragraphIndex],
                            ),
                            if (paragraphIndex <
                                widget.content.paragraphs.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

final class _FaqAnswerParagraph extends StatelessWidget {
  const _FaqAnswerParagraph({required this.paragraph});

  final FaqParagraphContent paragraph;

  @override
  Widget build(BuildContext context) {
    final normalStyle = LandingTextStyles.faqAnswer;
    final emphasisStyle = LandingTextStyles.faqAnswerEmphasis;
    final emphasizedRanges = _emphasizedRanges(
      paragraph.text,
      paragraph.emphasizedTerms,
    );

    if (emphasizedRanges.isEmpty) {
      return Text(paragraph.text, style: normalStyle);
    } else {
      final spans = <InlineSpan>[];
      var cursor = 0;
      for (final range in emphasizedRanges) {
        if (range.start > cursor) {
          spans.add(
            TextSpan(text: paragraph.text.substring(cursor, range.start)),
          );
        }
        spans.add(
          TextSpan(
            text: paragraph.text.substring(range.start, range.end),
            style: emphasisStyle,
          ),
        );
        cursor = range.end;
      }
      if (cursor < paragraph.text.length) {
        spans.add(TextSpan(text: paragraph.text.substring(cursor)));
      }

      return Text.rich(TextSpan(style: normalStyle, children: spans));
    }
  }
}

List<TextRange> _emphasizedRanges(String text, List<String> terms) {
  final ranges = <TextRange>[];
  for (final term in terms) {
    final start = text.indexOf(term);
    if (start >= 0) {
      ranges.add(TextRange(start: start, end: start + term.length));
    }
  }
  ranges.sort((first, second) => first.start.compareTo(second.start));
  return ranges;
}
