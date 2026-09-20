import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';

/// Approved informational disclosure shown before venue submission.
final class VenuePrivacyDisclosure extends StatefulWidget {
  /// Creates the venue privacy disclosure.
  const VenuePrivacyDisclosure({
    required this.statement,
    required this.privacyNoticeLabel,
    required this.onPrivacyNoticeSelected,
    super.key,
  });

  /// Exact approved disclosure statement.
  final String statement;

  /// Exact approved interactive text within [statement].
  final String privacyNoticeLabel;

  /// Navigates to the hosted Privacy Notice, or null during submission.
  final VoidCallback? onPrivacyNoticeSelected;

  @override
  State<VenuePrivacyDisclosure> createState() => _VenuePrivacyDisclosureState();
}

final class _VenuePrivacyDisclosureState extends State<VenuePrivacyDisclosure> {
  late final TapGestureRecognizer _privacyNoticeRecognizer;
  var _isFocused = false;

  @override
  void initState() {
    super.initState();
    _privacyNoticeRecognizer = TapGestureRecognizer();
    _synchronizeRecognizer();
  }

  @override
  void didUpdateWidget(VenuePrivacyDisclosure oldWidget) {
    super.didUpdateWidget(oldWidget);
    _synchronizeRecognizer();
  }

  @override
  void dispose() {
    _privacyNoticeRecognizer.dispose();
    super.dispose();
  }

  void _synchronizeRecognizer() {
    _privacyNoticeRecognizer.onTap = widget.onPrivacyNoticeSelected;
  }

  @override
  Widget build(BuildContext context) {
    final statement = widget.statement;
    final privacyNoticeLabel = widget.privacyNoticeLabel;
    final linkStart = statement.indexOf(privacyNoticeLabel);
    assert(
      linkStart >= 0,
      'The Privacy Notice link label must occur in the approved disclosure.',
    );
    final beforeLink = statement.substring(0, linkStart);
    final afterLink = statement.substring(
      linkStart + privacyNoticeLabel.length,
    );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final linkStyle = bodyStyle?.copyWith(
      color: AppColors.energeticPlum,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.energeticPlum,
      backgroundColor: _isFocused
          ? AppColors.energeticPlum.withValues(alpha: 0.12)
          : null,
    );

    return Focus(
      key: const Key('venuePrivacyNoticeLinkFocus'),
      canRequestFocus: widget.onPrivacyNoticeSelected != null,
      includeSemantics: false,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      onKeyEvent: (node, event) {
        final activatesLink =
            event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter ||
                event.logicalKey == LogicalKeyboardKey.space);
        if (activatesLink && widget.onPrivacyNoticeSelected != null) {
          widget.onPrivacyNoticeSelected!();
          return KeyEventResult.handled;
        } else {
          return KeyEventResult.ignored;
        }
      },
      child: Semantics(
        key: const Key('venuePrivacyDisclosure'),
        container: true,
        child: Text.rich(
          TextSpan(
            style: bodyStyle,
            children: [
              TextSpan(text: beforeLink),
              TextSpan(
                text: privacyNoticeLabel,
                style: linkStyle,
                recognizer: widget.onPrivacyNoticeSelected == null
                    ? null
                    : _privacyNoticeRecognizer,
                mouseCursor: widget.onPrivacyNoticeSelected == null
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.click,
              ),
              TextSpan(text: afterLink),
            ],
          ),
        ),
      ),
    );
  }
}
