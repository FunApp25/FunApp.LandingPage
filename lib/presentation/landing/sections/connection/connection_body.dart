import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Supporting copy for the connection section.
final class ConnectionBody extends StatelessWidget {
  /// Creates the connection supporting copy.
  const ConnectionBody({this.textAlign = TextAlign.start, super.key});

  /// Responsive text alignment.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.l10n.landingConnectionBody,
        key: const Key('connectionBodyText'),
        textAlign: textAlign,
        style: LandingTextStyles.sectionBody,
      ),
      const SizedBox(height: 12),
      Text(
        context.l10n.landingConnectionClosing,
        key: const Key('connectionClosingText'),
        textAlign: textAlign,
        style: LandingTextStyles.sectionBody,
      ),
    ],
  );
}
