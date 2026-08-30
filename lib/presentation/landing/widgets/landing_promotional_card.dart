import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_cta_button.dart';

/// Side occupied by artwork in a wide promotional-card composition.
enum PromotionalImageSide {
  /// Artwork appears before copy visually.
  leading,

  /// Artwork appears after copy visually.
  trailing,
}

/// Shared static presentation for the two horizontal Figma promo cards.
///
/// The card deliberately exposes no callback or control semantics because the
/// CTA destinations are unresolved. At constrained widths, copy remains before
/// artwork in source and semantic order.
final class LandingPromotionalCard extends StatelessWidget {
  /// Creates a responsive promotional card.
  const LandingPromotionalCard({
    required this.semanticId,
    required this.heading,
    required this.bodyParagraphs,
    required this.ctaLabel,
    required this.ctaAppearance,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.imageAsset,
    required this.imageSemanticLabel,
    required this.imageSide,
    required this.desktopHeight,
    required this.desktopContentWidth,
    required this.desktopLeadingInset,
    required this.desktopGap,
    required this.desktopImageSlotWidth,
    required this.desktopTrailingInset,
    required this.desktopImageAlignment,
    super.key,
  });

  /// Stable key prefix that is never displayed.
  final String semanticId;

  /// Localized card heading.
  final String heading;

  /// Localized body paragraphs in reading order.
  final List<String> bodyParagraphs;

  /// Localized visual-only CTA label.
  final String ctaLabel;

  /// Figma CTA color treatment.
  final LandingCtaAppearance ctaAppearance;

  /// Figma card surface color.
  final Color backgroundColor;

  /// Figma card text color.
  final Color foregroundColor;

  /// Exact locally committed masked composition.
  final String imageAsset;

  /// Localized concise image description.
  final String imageSemanticLabel;

  /// Artwork side in the explicit desktop design.
  final PromotionalImageSide imageSide;

  /// Exact minimum desktop card height.
  final double desktopHeight;

  /// Exact desktop copy-column width.
  final double desktopContentWidth;

  /// Space before the first visual column at desktop width.
  final double desktopLeadingInset;

  /// Space between the copy and artwork slots.
  final double desktopGap;

  /// Layout slot width used to reproduce Figma's clipped artwork position.
  final double desktopImageSlotWidth;

  /// Space after the last visual column at desktop width.
  final double desktopTrailingInset;

  /// Alignment of the 673px artwork inside its clipped desktop slot.
  final Alignment desktopImageAlignment;

  static const _imageWidth = 673.0;
  static const _imageHeight = 410.0;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.all(
      Radius.circular(AppSizes.cardRadius),
    ),
    child: ColoredBox(
      color: backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useWideComposition =
              constraints.maxWidth >= AppSizes.maxContentWidth;
          return useWideComposition
              ? _WidePromotionalCard(
                  card: this,
                  verticalInset: (desktopHeight - _imageHeight) / 2,
                )
              : _StackedPromotionalCard(card: this);
        },
      ),
    ),
  );
}

final class _WidePromotionalCard extends StatelessWidget {
  const _WidePromotionalCard({
    required this.card,
    required this.verticalInset,
  });

  final LandingPromotionalCard card;
  final double verticalInset;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: card.desktopContentWidth,
      child: _PromotionalCardContent(card: card),
    );
    final image = _PromotionalCardImage(
      card: card,
      slotWidth: card.desktopImageSlotWidth,
      alignment: card.desktopImageAlignment,
      scaleToFit: false,
    );

    final children = card.imageSide == PromotionalImageSide.trailing
        ? <Widget>[
            SizedBox(width: card.desktopLeadingInset),
            content,
            SizedBox(width: card.desktopGap),
            image,
            SizedBox(width: card.desktopTrailingInset),
          ]
        : <Widget>[
            SizedBox(width: card.desktopTrailingInset),
            content,
            SizedBox(width: card.desktopGap),
            image,
            SizedBox(width: card.desktopLeadingInset),
          ];

    return Padding(
      key: Key('${card.semanticId}WideLayout'),
      padding: EdgeInsets.symmetric(vertical: verticalInset),
      child: Row(
        textDirection: card.imageSide == PromotionalImageSide.leading
            ? TextDirection.rtl
            : TextDirection.ltr,
        children: children,
      ),
    );
  }
}

final class _StackedPromotionalCard extends StatelessWidget {
  const _StackedPromotionalCard({required this.card});

  final LandingPromotionalCard card;

  @override
  Widget build(BuildContext context) => Padding(
    key: Key('${card.semanticId}StackedLayout'),
    padding: const EdgeInsets.only(top: 64),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: card.desktopContentWidth),
            child: _PromotionalCardContent(card: card),
          ),
        ),
        const SizedBox(height: 40),
        _PromotionalCardImage(
          card: card,
          slotWidth: LandingPromotionalCard._imageWidth,
          alignment: Alignment.center,
          scaleToFit: true,
        ),
      ],
    ),
  );
}

final class _PromotionalCardContent extends StatelessWidget {
  const _PromotionalCardContent({required this.card});

  final LandingPromotionalCard card;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Semantics(
        key: Key('${card.semanticId}HeadingSemantics'),
        sortKey: const OrdinalSortKey(1),
        label: card.heading,
        header: true,
        excludeSemantics: true,
        child: Text(
          card.heading,
          key: Key('${card.semanticId}HeadingText'),
          textAlign: TextAlign.center,
          style: AppTextStyles.landingSectionHeading.copyWith(
            color: card.foregroundColor,
          ),
        ),
      ),
      const SizedBox(height: 20),
      for (var index = 0; index < card.bodyParagraphs.length; index++) ...[
        if (index > 0) const SizedBox(height: 12),
        Text(
          card.bodyParagraphs[index],
          key: Key('${card.semanticId}Body$index'),
          textAlign: TextAlign.center,
          style: AppTextStyles.landingStatBody.copyWith(
            color: card.foregroundColor,
          ),
        ),
      ],
      const SizedBox(height: 40),
      SizedBox(
        width: double.infinity,
        child: LandingCtaButton(
          key: Key('${card.semanticId}Cta'),
          label: card.ctaLabel,
          size: LandingCtaSize.prominent,
          appearance: card.ctaAppearance,
          arrowKey: Key('${card.semanticId}CtaArrow'),
        ),
      ),
    ],
  );
}

final class _PromotionalCardImage extends StatelessWidget {
  const _PromotionalCardImage({
    required this.card,
    required this.slotWidth,
    required this.alignment,
    required this.scaleToFit,
  });

  final LandingPromotionalCard card;
  final double slotWidth;
  final Alignment alignment;
  final bool scaleToFit;

  @override
  Widget build(BuildContext context) => Semantics(
    key: Key('${card.semanticId}ImageSemantics'),
    sortKey: const OrdinalSortKey(2),
    label: card.imageSemanticLabel,
    image: true,
    excludeSemantics: true,
    child: scaleToFit
        ? ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LandingPromotionalCard._imageWidth,
            ),
            child: AspectRatio(
              aspectRatio:
                  LandingPromotionalCard._imageWidth /
                  LandingPromotionalCard._imageHeight,
              child: _image,
            ),
          )
        : SizedBox(
            width: slotWidth,
            height: LandingPromotionalCard._imageHeight,
            child: OverflowBox(
              alignment: alignment,
              minWidth: LandingPromotionalCard._imageWidth,
              maxWidth: LandingPromotionalCard._imageWidth,
              minHeight: LandingPromotionalCard._imageHeight,
              maxHeight: LandingPromotionalCard._imageHeight,
              child: _image,
            ),
          ),
  );

  Widget get _image => Image.asset(
    card.imageAsset,
    key: Key('${card.semanticId}Image'),
    width: LandingPromotionalCard._imageWidth,
    height: LandingPromotionalCard._imageHeight,
    fit: BoxFit.fill,
    excludeFromSemantics: true,
  );
}
