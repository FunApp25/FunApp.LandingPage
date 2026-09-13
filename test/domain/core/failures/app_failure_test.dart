import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';

void main() {
  test('keeps service-unavailable failures semantically distinguishable', () {
    const failure = AppFailure.serviceUnavailable();

    expect(failure, const AppFailure.serviceUnavailable());
    expect(failure, isA<ServiceUnavailableAppFailure>());
  });

  test('keeps rejected submissions semantically distinguishable', () {
    const failure = AppFailure.submissionRejected();

    expect(failure, const AppFailure.submissionRejected());
    expect(failure, isA<SubmissionRejectedAppFailure>());
  });

  test('keeps unexpected failures semantically distinguishable', () {
    const failure = AppFailure.unexpected();

    expect(failure, const AppFailure.unexpected());
    expect(failure, isA<UnexpectedAppFailure>());
  });

  test('does not conflate distinct operational categories', () {
    expect(
      const AppFailure.serviceUnavailable(),
      isNot(const AppFailure.submissionRejected()),
    );
    expect(
      const AppFailure.submissionRejected(),
      isNot(const AppFailure.unexpected()),
    );
  });
}
