import 'dart:async';
import 'dart:convert';

import 'package:fun_app_landing_page/core/config/development_registration_transport.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_exception.dart';
import 'package:fun_app_landing_page/data/user_registration/data_sources/user_registration_data_source_interface.dart';
import 'package:fun_app_landing_page/data/user_registration/models/founding_friend_registration_dto.dart';
import 'package:fun_app_landing_page/data/user_registration/models/founding_friend_registration_request.dart';
import 'package:fun_app_landing_page/data/user_registration/models/here_and_now_registration_dto.dart';
import 'package:fun_app_landing_page/data/user_registration/models/here_and_now_registration_request.dart';
import 'package:http/http.dart' as http;

/// Exact first-party Here & Now Worker endpoint.
const hereAndNowRegistrationEndpointPath = '/api/registrations/here-and-now';

/// Exact first-party Founding Friend Worker endpoint.
const foundingFriendRegistrationEndpointPath =
    '/api/registrations/founding-friend';

/// Maximum duration of one first-party registration submission.
const defaultWorkerRegistrationSubmissionTimeout = Duration(seconds: 15);

/// Maximum UTF-8 request size accepted by the first-party Worker.
const int maxWorkerRegistrationRequestBodyBytes = 16 * 1024;

/// Registration data source backed by Fun App's first-party Worker.
final class WorkerUserRegistrationDataSource
    implements UserRegistrationDataSourceInterface {
  /// Creates a Worker-backed source with an injected client and local origin.
  factory WorkerUserRegistrationDataSource({
    required http.Client client,
    required LocalRegistrationWorkerConfig config,
    Duration submissionTimeout = defaultWorkerRegistrationSubmissionTimeout,
  }) => WorkerUserRegistrationDataSource._(
    client,
    config,
    submissionTimeout,
  );

  const WorkerUserRegistrationDataSource._(
    this._client,
    this._config,
    this._submissionTimeout,
  );

  final http.Client _client;
  final LocalRegistrationWorkerConfig _config;
  final Duration _submissionTimeout;

  @override
  Future<void> submitHereAndNowRegistration(
    HereAndNowRegistrationDto registration,
  ) => _submit(
    endpointPath: hereAndNowRegistrationEndpointPath,
    payload: HereAndNowRegistrationRequest.fromDto(registration).toJson(),
  );

  @override
  Future<void> submitFoundingFriendRegistration(
    FoundingFriendRegistrationDto registration,
  ) => _submit(
    endpointPath: foundingFriendRegistrationEndpointPath,
    payload: FoundingFriendRegistrationRequest.fromDto(registration).toJson(),
  );

  Future<void> _submit({
    required String endpointPath,
    required Map<String, Object> payload,
  }) async {
    final requestBody = jsonEncode(payload);

    if (utf8.encode(requestBody).length >
        maxWorkerRegistrationRequestBodyBytes) {
      throw const UserRegistrationSubmissionRejectedException();
    }

    final abortCompleter = Completer<void>();
    final timeoutTimer = Timer(_submissionTimeout, abortCompleter.complete);
    final request =
        http.AbortableRequest(
            'POST',
            _config.endpoint(endpointPath),
            abortTrigger: abortCompleter.future,
          )
          ..headers['Content-Type'] = 'application/json'
          ..body = requestBody;
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

    if (statusCode == 204) {
      return;
    } else if (statusCode == 400 || statusCode == 422) {
      throw const UserRegistrationSubmissionRejectedException();
    } else if (statusCode == 429 || statusCode == 503) {
      throw const UserRegistrationServiceUnavailableException();
    } else {
      throw const UserRegistrationUnexpectedDataSourceException();
    }
  }
}
