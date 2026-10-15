/// Public HubSpot Forms configuration used only by the development entrypoint.
final class HubSpotRegistrationFormsConfig {
  /// Creates validated public form identifiers.
  factory HubSpotRegistrationFormsConfig({
    required String portalId,
    required String hereAndNowFormGuid,
    required String foundingFriendFormGuid,
  }) {
    final guidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    if (!RegExp(r'^\d+$').hasMatch(portalId)) {
      throw ArgumentError.value(
        portalId,
        'portalId',
        'Must contain digits only.',
      );
    } else if (!guidPattern.hasMatch(hereAndNowFormGuid)) {
      throw ArgumentError.value(
        hereAndNowFormGuid,
        'hereAndNowFormGuid',
        'Must be a UUID.',
      );
    } else if (!guidPattern.hasMatch(foundingFriendFormGuid)) {
      throw ArgumentError.value(
        foundingFriendFormGuid,
        'foundingFriendFormGuid',
        'Must be a UUID.',
      );
    }

    return HubSpotRegistrationFormsConfig._(
      portalId: portalId,
      hereAndNowFormGuid: hereAndNowFormGuid,
      foundingFriendFormGuid: foundingFriendFormGuid,
    );
  }

  const HubSpotRegistrationFormsConfig._({
    required this.portalId,
    required this.hereAndNowFormGuid,
    required this.foundingFriendFormGuid,
  });

  /// Reads public identifiers supplied at compile time.
  ///
  /// No configuration keeps development submissions fail-closed. Partial or
  /// malformed configuration fails during composition instead of silently
  /// targeting the wrong form.
  static HubSpotRegistrationFormsConfig? fromEnvironment() {
    const portalId = String.fromEnvironment(
      'FUN_APP_HUBSPOT_REGISTRATION_PORTAL_ID',
    );
    const hereAndNowFormGuid = String.fromEnvironment(
      'FUN_APP_HUBSPOT_HERE_AND_NOW_FORM_GUID',
    );
    const foundingFriendFormGuid = String.fromEnvironment(
      'FUN_APP_HUBSPOT_FOUNDING_FRIEND_FORM_GUID',
    );

    if (portalId.isEmpty &&
        hereAndNowFormGuid.isEmpty &&
        foundingFriendFormGuid.isEmpty) {
      return null;
    } else {
      return HubSpotRegistrationFormsConfig(
        portalId: portalId,
        hereAndNowFormGuid: hereAndNowFormGuid,
        foundingFriendFormGuid: foundingFriendFormGuid,
      );
    }
  }

  /// Public HubSpot portal identifier.
  final String portalId;

  /// Public Here & Now form identifier.
  final String hereAndNowFormGuid;

  /// Public Founding Friend form identifier.
  final String foundingFriendFormGuid;

  /// Returns the supported unauthenticated v3 submission endpoint.
  Uri submissionEndpoint(String formGuid) => Uri.https(
    'api.hsforms.com',
    '/submissions/v3/integration/submit/$portalId/$formGuid',
  );
}
