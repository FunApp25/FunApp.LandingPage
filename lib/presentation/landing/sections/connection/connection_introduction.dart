import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/connection/connection_body.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/connection/connection_title.dart';

/// Responsive heading-and-body composition for the connection section.
final class ConnectionIntroduction extends StatelessWidget {
  /// Creates the connection introduction.
  const ConnectionIntroduction({
    required this.availableWidth,
    required this.headingSize,
    super.key,
  });

  // Exact desktop columns need 443px + 672px plus the 245px Figma gap.
  static const _minimumWideCompositionWidth = 1195.0;

  /// Width available to the introduction.
  final double availableWidth;

  /// Responsive heading font size.
  final double headingSize;

  @override
  Widget build(BuildContext context) {
    if (availableWidth >= _minimumWideCompositionWidth) {
      return Row(
        key: const Key('connectionWideLayout'),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 443,
            child: ConnectionTitle(headingSize: headingSize),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: SizedBox(width: 672, child: ConnectionBody()),
          ),
        ],
      );
    } else {
      return Column(
        key: const Key('connectionStackedLayout'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConnectionTitle(headingSize: headingSize),
          const SizedBox(height: 32),
          const ConnectionBody(),
        ],
      );
    }
  }
}
