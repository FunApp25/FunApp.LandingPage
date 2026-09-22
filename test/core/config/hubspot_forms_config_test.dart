import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/config/hubspot_forms_config.dart';

void main() {
  test('uses the established compile-time configuration keys', () {
    expect(hubSpotPortalIdDefineName, 'FUN_APP_HUBSPOT_PORTAL_ID');
    expect(
      hubSpotVenueFormGuidDefineName,
      'FUN_APP_HUBSPOT_VENUE_FORM_GUID',
    );
  });

  test('accepts non-empty public HubSpot identifiers', () {
    final config = HubSpotFormsConfig.fromValues(
      portalId: '123456789',
      venueFormGuid: '00000000-0000-0000-0000-000000000000',
    );

    expect(config.portalId, '123456789');
    expect(
      config.venueFormGuid,
      '00000000-0000-0000-0000-000000000000',
    );
  });

  test('rejects a missing portal ID', () {
    expect(
      () => HubSpotFormsConfig.fromValues(
        portalId: '',
        venueFormGuid: '00000000-0000-0000-0000-000000000000',
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains(hubSpotPortalIdDefineName),
        ),
      ),
    );
  });

  test('rejects a missing venue form GUID', () {
    expect(
      () => HubSpotFormsConfig.fromValues(
        portalId: '123456789',
        venueFormGuid: '',
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains(hubSpotVenueFormGuidDefineName),
        ),
      ),
    );
  });
}
