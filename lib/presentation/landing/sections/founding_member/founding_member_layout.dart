import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Width of the Founding Friend introduction column.
const foundingMemberIntroWidth = 328.0;

/// Gap between Founding Friend benefit cards.
const foundingMemberCardGap = 16.0;

/// Minimum width used to choose Founding Friend card columns.
const foundingMemberMinimumCardWidth = 328.0;

const _cardPadding = 32.0;
const _iconExtent = 60.0;
const _textGap = 8.0;
const _minimumContentSeparation = 12.0;
const _minimumCardHeight = 360.0;

/// Shared height that fits the tallest localized, scaled card text.
double foundingMemberCardHeightFor(
  BuildContext context,
  List<FoundingMemberCardContent> cards,
  double cardWidth,
) {
  final textWidth = cardWidth - (_cardPadding * 2);
  var tallestTextGroup = 0.0;

  for (final card in cards) {
    final titleHeight = _textHeight(
      context,
      card.title,
      LandingTextStyles.foundingMemberCardTitle,
      textWidth,
    );
    final bodyHeight = _textHeight(
      context,
      card.body,
      LandingTextStyles.compactSectionBody,
      textWidth,
    );
    final textGroupHeight = titleHeight + _textGap + bodyHeight;
    if (textGroupHeight > tallestTextGroup) {
      tallestTextGroup = textGroupHeight;
    }
  }

  final requiredHeight =
      (_cardPadding * 2) +
      _iconExtent +
      _minimumContentSeparation +
      tallestTextGroup;
  return requiredHeight.clamp(_minimumCardHeight, double.infinity);
}

double _textHeight(
  BuildContext context,
  String text,
  TextStyle style,
  double maxWidth,
) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout(maxWidth: maxWidth);

  final height = painter.height;
  painter.dispose();
  return height;
}
