import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/content/faq_content.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// One FAQ answer paragraph with approved emphasized terms.
final class FaqAnswerParagraph extends StatelessWidget {
  /// Creates an FAQ answer paragraph.
  const FaqAnswerParagraph({required this.paragraph, super.key});

  /// Localized paragraph content and emphasis metadata.
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
