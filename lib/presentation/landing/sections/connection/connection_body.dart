import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Supporting copy for the connection section.
final class ConnectionBody extends StatelessWidget {
  /// Creates the connection supporting copy.
  const ConnectionBody({super.key});

  @override
  Widget build(BuildContext context) => Text(
    context.l10n.landingConnectionBody,
    key: const Key('connectionBodyText'),
    style: LandingTextStyles.sectionBody,
  );
}
