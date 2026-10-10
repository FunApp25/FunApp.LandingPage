import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_checkbox.dart';

/// Presentation-local acknowledgement toggle for the Venue form.
final class VenuePrivacyAcknowledgementCheckbox extends StatefulWidget {
  /// Creates an unchecked acknowledgement toggle.
  const VenuePrivacyAcknowledgementCheckbox({
    required this.semanticLabel,
    required this.label,
    super.key,
  });

  /// Accessible name associated with the visible acknowledgement copy.
  final String semanticLabel;

  /// Rich disclosure text, including its independent Privacy Notice link.
  final Widget label;

  @override
  State<VenuePrivacyAcknowledgementCheckbox> createState() =>
      _VenuePrivacyAcknowledgementCheckboxState();
}

final class _VenuePrivacyAcknowledgementCheckboxState
    extends State<VenuePrivacyAcknowledgementCheckbox> {
  var _isAcknowledged = false;

  @override
  Widget build(BuildContext context) => BrandedFormCheckbox(
    semanticKey: const Key('venuePrivacyAcknowledgementCheckbox'),
    focusKey: const Key('venuePrivacyAcknowledgementFocus'),
    visualKey: const Key('venuePrivacyAcknowledgementVisual'),
    label: widget.semanticLabel,
    labelWidget: widget.label,
    preserveLabelSemantics: true,
    value: _isAcknowledged,
    onChanged: (value) => setState(() => _isAcknowledged = value),
  );
}
