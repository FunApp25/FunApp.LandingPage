import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalogs = <String, Map<String, dynamic>>{
    for (final locale in const ['en', 'es', 'cy', 'be'])
      locale: jsonDecode(
        File('lib/l10n/app_$locale.arb').readAsStringSync(),
      ) as Map<String, dynamic>,
  };
  final englishMessages = _messages(catalogs['en']!);

  test('all supported catalogs contain the complete English message set', () {
    for (final locale in const ['es', 'cy', 'be']) {
      expect(
        _messages(catalogs[locale]!).keys,
        unorderedEquals(englishMessages.keys),
        reason: '$locale must not rely on generated English fallbacks',
      );
    }
  });

  test('localized ICU placeholders match the English catalog', () {
    for (final locale in const ['es', 'cy', 'be']) {
      final messages = _messages(catalogs[locale]!);
      for (final entry in englishMessages.entries) {
        expect(
          _placeholders(messages[entry.key]!),
          _placeholders(entry.value),
          reason: '$locale:${entry.key}',
        );
      }
    }
  });

  test('country labels preserve every stored integration value', () {
    final englishOptions = _countryOptions(
      englishMessages['userSignUpCountryOptionsSource']!,
    );
    for (final locale in const ['es', 'cy', 'be']) {
      final localizedOptions = _countryOptions(
        _messages(catalogs[locale]!)['userSignUpCountryOptionsSource']!,
      );
      expect(
        localizedOptions.keys,
        orderedEquals(englishOptions.keys),
        reason: '$locale must preserve the HubSpot-compatible values',
      );
      expect(localizedOptions.values, everyElement(isNotEmpty));
      expect(
        localizedOptions.entries
            .where((entry) => entry.value != englishOptions[entry.key])
            .length,
        greaterThan(100),
        reason: '$locale country labels should be meaningfully localized',
      );
    }
  });

  test('non-English catalogs only retain intentional shared text', () {
    const intentionalSharedKeys = {
      'appTitle',
      'brandName',
      'landingHeaderFoundingFriends',
      'landingStatsBelongingForum',
      'landingStatsMarmaladeTrust',
      'landingStatsBacpYouGov',
      'landingStatsFirstValue',
      'landingStatsSecondValue',
      'landingStatsThirdValue',
      'landingStatsFourthValue',
      'landingMembershipFreePrice',
      'landingMembershipHereNowPrice',
      'landingMembershipLifetimePrice',
      'landingVenueHeadingTrailing',
      'userSignUpFoundingFriendEyebrow',
      'venueLeadEmailPlaceholder',
      'venueLeadPhoneNumberPlaceholder',
      'venueLeadVenueCountPlaceholder',
      'venueLeadWebsitePlaceholder',
      'userSignUpEmailPlaceholder',
    };

    for (final locale in const ['es', 'cy', 'be']) {
      final messages = _messages(catalogs[locale]!);
      final unchanged = <String>{
        for (final entry in messages.entries)
          if (entry.value == englishMessages[entry.key]) entry.key,
      };
      expect(
        unchanged.difference(intentionalSharedKeys),
        isEmpty,
        reason: '$locale contains an unreviewed English fallback',
      );
    }
  });
}

Map<String, String> _messages(Map<String, dynamic> catalog) => {
  for (final entry in catalog.entries)
    if (!entry.key.startsWith('@')) entry.key: entry.value as String,
};

Set<String> _placeholders(String message) => {
  for (final match in RegExp(
    r'\{([A-Za-z][A-Za-z0-9_]*)\}',
  ).allMatches(message))
    match.group(1)!,
};

Map<String, String> _countryOptions(String source) => {
  for (final line in source.split('\n'))
    line.split('\t').first: line.split('\t').last,
};
