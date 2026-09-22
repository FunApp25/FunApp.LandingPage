/// Compile-time key for the public HubSpot account identifier.
const hubSpotPortalIdDefineName = 'FUN_APP_HUBSPOT_PORTAL_ID';

/// Compile-time key for the public HubSpot venue-form identifier.
const hubSpotVenueFormGuidDefineName = 'FUN_APP_HUBSPOT_VENUE_FORM_GUID';

/// Public compile-time configuration for HubSpot Forms submissions.
final class HubSpotFormsConfig {
  const HubSpotFormsConfig._({
    required this.portalId,
    required this.venueFormGuid,
  });

  /// Creates validated configuration from explicit values.
  factory HubSpotFormsConfig.fromValues({
    required String portalId,
    required String venueFormGuid,
  }) {
    if (portalId.isEmpty) {
      throw const FormatException(
        '$hubSpotPortalIdDefineName must be provided for production.',
      );
    } else if (venueFormGuid.isEmpty) {
      throw const FormatException(
        '$hubSpotVenueFormGuidDefineName must be provided for production.',
      );
    } else {
      return HubSpotFormsConfig._(
        portalId: portalId,
        venueFormGuid: venueFormGuid,
      );
    }
  }

  /// Reads and validates the public identifiers embedded at compile time.
  factory HubSpotFormsConfig.fromEnvironment() => HubSpotFormsConfig.fromValues(
    portalId: const String.fromEnvironment(
      hubSpotPortalIdDefineName,
    ),
    venueFormGuid: const String.fromEnvironment(
      hubSpotVenueFormGuidDefineName,
    ),
  );

  /// HubSpot account identifier used by the Forms endpoint.
  final String portalId;

  /// HubSpot form identifier for prospective venue submissions.
  final String venueFormGuid;
}
