import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

/// A provider-neutral operational failure from application work.
@freezed
sealed class AppFailure with _$AppFailure {
  /// Creates a failure for a temporarily unavailable submission service.
  const factory AppFailure.serviceUnavailable() = ServiceUnavailableAppFailure;

  /// Creates a failure for a submission the receiving service did not accept.
  const factory AppFailure.submissionRejected() = SubmissionRejectedAppFailure;

  /// Creates a failure for an unclassified operational problem.
  const factory AppFailure.unexpected() = UnexpectedAppFailure;
}
