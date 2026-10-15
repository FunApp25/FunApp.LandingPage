import 'dart:async';
import 'dart:convert';

import 'package:fun_app_landing_page/core/config/hubspot_registration_forms_config.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_exception.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_interface.dart';
import 'package:fun_app_landing_page/data/user_registration/models/founding_friend_registration_dto.dart';
import 'package:fun_app_landing_page/data/user_registration/models/here_and_now_registration_dto.dart';
import 'package:fun_app_landing_page/data/user_registration/models/hubspot_form_submission_request.dart';
import 'package:http/http.dart' as http;

/// Maximum duration of one direct HubSpot registration submission.
const defaultHubSpotRegistrationSubmissionTimeout = Duration(seconds: 15);

/// Direct browser transport for HubSpot's public unauthenticated Forms API.
final class HubSpotUserRegistrationDataSource
    implements UserRegistrationDataSourceInterface {
  /// Creates a direct HubSpot data source with injected public configuration.
  factory HubSpotUserRegistrationDataSource({
    required http.Client client,
    required HubSpotRegistrationFormsConfig config,
    Duration submissionTimeout = defaultHubSpotRegistrationSubmissionTimeout,
  }) => HubSpotUserRegistrationDataSource._(
    client,
    config,
    submissionTimeout,
  );

  const HubSpotUserRegistrationDataSource._(
    this._client,
    this._config,
    this._submissionTimeout,
  );

  final http.Client _client;
  final HubSpotRegistrationFormsConfig _config;
  final Duration _submissionTimeout;

  @override
  Future<void> submitHereAndNowRegistration(
    HereAndNowRegistrationDto registration,
  ) => _submit(
    formGuid: _config.hereAndNowFormGuid,
    payload: HubSpotFormSubmissionRequest.hereAndNow(registration),
  );

  @override
  Future<void> submitFoundingFriendRegistration(
    FoundingFriendRegistrationDto registration,
  ) => _submit(
    formGuid: _config.foundingFriendFormGuid,
    payload: HubSpotFormSubmissionRequest.foundingFriend(registration),
  );

  Future<void> _submit({
    required String formGuid,
    required HubSpotFormSubmissionRequest payload,
  }) async {
    final abortCompleter = Completer<void>();
    final timeoutTimer = Timer(_submissionTimeout, abortCompleter.complete);
    final request =
        http.AbortableRequest(
            'POST',
            _config.submissionEndpoint(formGuid),
            abortTrigger: abortCompleter.future,
          )
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(payload.toJson());
    final int statusCode;

    try {
      final response = await _client.send(request);
      statusCode = response.statusCode;
      await response.stream.drain<void>();
    } on http.RequestAbortedException {
      throw const UserRegistrationServiceUnavailableException();
    } on http.ClientException {
      throw const UserRegistrationServiceUnavailableException();
    } finally {
      timeoutTimer.cancel();
    }

    if (statusCode == 200) {
      return;
    } else if (statusCode == 400) {
      throw const UserRegistrationSubmissionRejectedException();
    } else if (statusCode == 429 || statusCode >= 500) {
      throw const UserRegistrationServiceUnavailableException();
    } else {
      throw const UserRegistrationUnexpectedDataSourceException();
    }
  }
}
