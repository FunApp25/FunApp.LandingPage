import 'package:flutter/widgets.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';

/// Convenience accessors for localized presentation resources.
extension BuildContextLocalizationsExtension on BuildContext {
  /// Localized strings for the active widget subtree.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
