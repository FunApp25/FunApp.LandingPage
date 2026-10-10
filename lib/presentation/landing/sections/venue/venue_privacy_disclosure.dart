import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_privacy_acknowledgement_checkbox.dart';

/// Approved informational disclosure shown before venue submission.
final class VenuePrivacyDisclosure extends StatefulWidget {
  /// Creates the venue privacy disclosure.
  const VenuePrivacyDisclosure({
    required this.statement,
    required this.privacyNoticeLabel,
    required this.onPrivacyNoticeSelected,
    this.showAcknowledgementCheckbox = false,
    super.key,
  });

  /// Exact approved disclosure statement.
  final String statement;

  /// Exact approved interactive text within [statement].
  final String privacyNoticeLabel;

  /// Opens the hosted Privacy Notice; null disables the link.
  final VoidCallback? onPrivacyNoticeSelected;

  /// Whether to show the routed-page-only presentation acknowledgement.
  final bool showAcknowledgementCheckbox;

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
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final bodyStyle = widget.showAcknowledgementCheckbox
        ? AppTextStyles.bodyFontStyle(
            fontSize: mobile ? 12 : 14,
            fontWeight: FontWeight.w400,
            height: mobile ? 20 / 12 : 22 / 14,
            color: AppColors.bodyGray,
          )
        : Theme.of(context).textTheme.bodyMedium;
    final linkStyle = bodyStyle?.copyWith(
      color: widget.showAcknowledgementCheckbox
          ? AppColors.bodyGray
          : AppColors.energeticPlum,
      fontWeight: widget.showAcknowledgementCheckbox
          ? FontWeight.w400
          : FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: widget.showAcknowledgementCheckbox
          ? AppColors.bodyGray
          : AppColors.energeticPlum,
      backgroundColor: _isFocused
          ? AppColors.energeticPlum.withValues(alpha: 0.12)
          : null,
    );

    final linkedStatement = Focus(
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
              TextSpan(
                text: beforeLink,
                semanticsLabel: widget.showAcknowledgementCheckbox ? '' : null,
              ),
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
              TextSpan(
                text: afterLink,
                semanticsLabel: widget.showAcknowledgementCheckbox ? '' : null,
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.showAcknowledgementCheckbox) {
      return VenuePrivacyAcknowledgementCheckbox(
        key: const Key('venuePrivacyAcknowledgementRow'),
        semanticLabel: statement,
        label: linkedStatement,
      );
    } else {
      return linkedStatement;
    }
  }
}
