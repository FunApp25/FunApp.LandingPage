import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/forms/branded_form_dropdown.dart';

/// Optional two-choice presentation for the existing string-valued field.
final class VenueChainStatusControl extends StatelessWidget {
  /// Creates the chain status control.
  const VenueChainStatusControl({
    required this.label,
    required this.independentLabel,
    required this.chainLabel,
    required this.selectedValue,
    required this.onSelected,
    required this.placeholder,
    super.key,
  });

  /// Localized field heading.
  final String label;

  /// Localized Independent option.
  final String independentLabel;

  /// Localized Part of chain option.
  final String chainLabel;

  /// Existing draft value, or null when unanswered.
  final String? selectedValue;

  /// Dispatches the stable existing field value, including empty on deselect.
  final ValueChanged<String> onSelected;

  /// Localized unselected prompt for the routed-page presentation.
  final String placeholder;

  /// Provider-neutral value sent through the existing BLoC event.
  static const independentValue = 'Independent';

  /// Provider-neutral value sent through the existing BLoC event.
  static const chainValue = 'Part of chain';

  @override
  Widget build(BuildContext context) => BrandedFormDropdown<String>(
    key: const Key('venueLeadChainStatusControl'),
    fieldKey: const Key('venueLeadChainStatusMenu'),
    caretKey: const Key('venueLeadChainStatusCaret'),
    label: label,
    semanticLabel: label,
    placeholder: placeholder,
    value: selectedValue,
    options: [
      (
        value: VenueChainStatusControl.independentValue,
        label: independentLabel,
      ),
      (
        value: VenueChainStatusControl.chainValue,
        label: chainLabel,
      ),
    ],
    optionKeys: const {
      VenueChainStatusControl.independentValue: Key(
        'venueChainIndependentOption',
      ),
      VenueChainStatusControl.chainValue: Key(
        'venueChainPartOfChainOption',
      ),
    },
    onChanged: (value) {
      if (value != null) {
        onSelected(value == selectedValue ? '' : value);
      }
    },
  );
}
