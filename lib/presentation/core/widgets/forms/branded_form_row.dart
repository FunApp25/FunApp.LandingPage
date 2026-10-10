import 'package:flutter/material.dart';

/// Shared responsive two-column/stacked form-field composition.
final class BrandedFormRow extends StatelessWidget {
  /// Creates a field pair that follows the public-form grid breakpoint.
  const BrandedFormRow({
    required this.rowKey,
    required this.columnKey,
    required this.leading,
    required this.horizontal,
    this.trailing,
    super.key,
  });

  /// Stable key used for the two-column composition.
  final Key rowKey;

  /// Stable key used for the stacked composition.
  final Key columnKey;

  /// First field in visual and focus order.
  final Widget leading;

  /// Optional second field in visual and focus order.
  final Widget? trailing;

  /// Whether to render a two-column row instead of a stack.
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return Row(
        key: rowKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: leading),
          const SizedBox(width: 16),
          Expanded(child: trailing ?? const SizedBox.shrink()),
        ],
      );
    } else {
      return Column(
        key: columnKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          leading,
          if (trailing != null) ...[
            const SizedBox(height: 16),
            trailing!,
          ],
        ],
      );
    }
  }
}
