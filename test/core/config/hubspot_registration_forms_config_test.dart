import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/core/config/hubspot_registration_forms_config.dart';

void main() {
  test('builds the supported public Forms v3 endpoint', () {
    final config = _config();

    expect(
      config.submissionEndpoint(config.hereAndNowFormGuid),
      Uri.parse(
        'https://api.hsforms.com/submissions/v3/integration/submit/'
        '149114580/3284e6bc-e3a2-4d2e-9e21-684399126f3b',
      ),
    );
  });

  test('rejects incomplete or malformed public identifiers', () {
    expect(
      () => HubSpotRegistrationFormsConfig(
        portalId: '',
        hereAndNowFormGuid: '3284e6bc-e3a2-4d2e-9e21-684399126f3b',
        foundingFriendFormGuid: '39f027d9-e786-4768-b532-54ed44e1f718',
      ),
      throwsArgumentError,
    );
    expect(
      () => HubSpotRegistrationFormsConfig(
        portalId: '149114580',
        hereAndNowFormGuid: 'not-a-guid',
        foundingFriendFormGuid: '39f027d9-e786-4768-b532-54ed44e1f718',
      ),
      throwsArgumentError,
    );
  });
}

HubSpotRegistrationFormsConfig _config() => HubSpotRegistrationFormsConfig(
  portalId: '149114580',
  hereAndNowFormGuid: '3284e6bc-e3a2-4d2e-9e21-684399126f3b',
  foundingFriendFormGuid: '39f027d9-e786-4768-b532-54ed44e1f718',
);
