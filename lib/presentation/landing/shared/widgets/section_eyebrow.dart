import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Shared Figma eyebrow treatment for implemented landing-page sections.
final class SectionEyebrow extends StatelessWidget {
  /// Creates a section eyebrow with decorative vector artwork.
  const SectionEyebrow({
    required this.label,
    required this.glyphAsset,
    required this.foregroundColor,
    required this.glyphSize,
    this.alignment = MainAxisAlignment.start,
    this.textAlign = TextAlign.start,
    this.glyphKey,
    super.key,
  });

  /// Localized eyebrow label.
  final String label;

  /// Local SVG containing the exact Figma glyph geometry.
  final String glyphAsset;

  /// Shared foreground color for the glyph and label.
  final Color foregroundColor;

  /// Exact displayed glyph dimensions from Figma.
  final Size glyphSize;

  /// Horizontal placement of the combined glyph and label.
  final MainAxisAlignment alignment;

  /// Text alignment when a localized label wraps.
  final TextAlign textAlign;

  /// Optional key used to verify the decorative asset boundary.
  final Key? glyphKey;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: alignment,
    children: [
      SvgPicture.asset(
        glyphAsset,
        key: glyphKey,
        width: glyphSize.width,
        height: glyphSize.height,
        colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
        excludeFromSemantics: true,
      ),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          label,
          textAlign: textAlign,
          style: LandingTextStyles.sectionEyebrow.copyWith(
            color: foregroundColor,
          ),
        ),
      ),
    ],
  );
}
