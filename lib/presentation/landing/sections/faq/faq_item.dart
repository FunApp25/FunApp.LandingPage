import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/content/faq_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/faq/faq_answer_paragraph.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// One independently expandable FAQ item.
final class FaqItem extends StatefulWidget {
  /// Creates an FAQ item.
  const FaqItem({
    required this.index,
    required this.content,
    required this.isExpanded,
    required this.focusNode,
    required this.questionSize,
    required this.questionLineHeight,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.onToggle,
    super.key,
  });

  /// Stable item position in the FAQ collection.
  final int index;

  /// Localized question and answer content.
  final FaqItemContent content;

  /// Whether this answer is currently expanded.
  final bool isExpanded;

  /// Focus node owned by the FAQ section.
  final FocusNode focusNode;

  /// Responsive question font size.
  final double questionSize;

  /// Responsive question line height.
  final double questionLineHeight;

  /// Responsive vertical item padding.
  final double verticalPadding;

  /// Responsive horizontal item padding.
  final double horizontalPadding;

  /// Toggles this item's expansion state.
  final VoidCallback onToggle;

  @override
  State<FaqItem> createState() => _FaqItemState();
}

final class _FaqItemState extends State<FaqItem> {
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final answerRightPadding = constraints.maxWidth >= 520 ? 44.0 : 0.0;
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      final fastDuration = LandingMotion.duration(
        disableAnimations: disableAnimations,
        normalDuration: LandingMotion.fastDuration,
      );
      final hoverDuration = LandingMotion.duration(
        disableAnimations: disableAnimations || _isFocused,
        normalDuration: LandingMotion.fastDuration,
      );
      final standardDuration = LandingMotion.duration(
        disableAnimations: disableAnimations,
        normalDuration: LandingMotion.standardDuration,
      );
      final backgroundColor = _isFocused
          ? AppColors.energeticPlum.withValues(alpha: 0.08)
          : _isHovered
          ? AppColors.energeticPlum.withValues(alpha: 0.06)
          : Colors.transparent;
      final collapsedAnswer = SizedBox(
        key: Key('faqAnswerStateCollapsed${widget.index}'),
        height: widget.verticalPadding,
      );
      final expandedAnswer = Padding(
        key: Key('faqAnswer${widget.index}'),
        padding: EdgeInsets.only(
          left: widget.horizontalPadding,
          top: widget.verticalPadding >= 32 ? 20 : 16,
          right: widget.horizontalPadding + answerRightPadding,
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
              FaqAnswerParagraph(
                paragraph: widget.content.paragraphs[paragraphIndex],
              ),
              if (paragraphIndex < widget.content.paragraphs.length - 1)
                const SizedBox(height: 12),
            ],
          ],
        ),
      );
      final answerSemanticLabel = widget.content.paragraphs
          .map((paragraph) => paragraph.text)
          .join('\n\n');
      final Widget answerRegion;
      if (disableAnimations) {
        answerRegion = widget.isExpanded ? expandedAnswer : collapsedAnswer;
      } else {
        answerRegion = AnimatedCrossFade(
          key: Key('faqAnswerTransition${widget.index}'),
          firstChild: collapsedAnswer,
          secondChild: expandedAnswer,
          crossFadeState: widget.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: standardDuration,
          sizeCurve: LandingMotion.standardCurve,
        );
      }

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
            child: AnimatedContainer(
              key: Key('faqItemStateBackground${widget.index}'),
              duration: hoverDuration,
              curve: LandingMotion.standardCurve,
              decoration: BoxDecoration(
                color: backgroundColor,
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
                        padding: EdgeInsets.fromLTRB(
                          widget.horizontalPadding,
                          widget.verticalPadding,
                          widget.horizontalPadding,
                          0,
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
                            SizedBox.square(
                              key: Key('faqIcon${widget.index}'),
                              dimension: 28,
                              child: AnimatedSwitcher(
                                key: Key('faqIconSwitcher${widget.index}'),
                                duration: fastDuration,
                                switchInCurve: LandingMotion.standardCurve,
                                switchOutCurve: LandingMotion.standardCurve,
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: SvgPicture.asset(
                                  widget.isExpanded
                                      ? AppAssets.faqMinus
                                      : AppAssets.faqPlus,
                                  key: Key(
                                    widget.isExpanded
                                        ? 'faqMinus${widget.index}'
                                        : 'faqPlus${widget.index}',
                                  ),
                                  width: 28,
                                  height: 28,
                                  excludeFromSemantics: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    key: Key('faqAnswerSemantics${widget.index}'),
                    container: widget.isExpanded,
                    label: widget.isExpanded ? answerSemanticLabel : null,
                    excludeSemantics: true,
                    child: answerRegion,
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
