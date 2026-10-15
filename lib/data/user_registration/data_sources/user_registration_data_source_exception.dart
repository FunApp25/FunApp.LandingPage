/// Base exception for classified registration data-source failures.
sealed class UserRegistrationDataSourceException implements Exception {
  /// Creates a classified registration data-source exception.
  const UserRegistrationDataSourceException();
}

/// The submission service cannot currently accept a request.
final class UserRegistrationServiceUnavailableException
    extends UserRegistrationDataSourceException {
  /// Creates an unavailable-service exception.
  const UserRegistrationServiceUnavailableException();
}

/// The provider rejected submitted field data.
final class UserRegistrationSubmissionRejectedException
    extends UserRegistrationDataSourceException {
  /// Creates a submission-rejected exception.
  const UserRegistrationSubmissionRejectedException();
}

/// The provider response has no established application classification.
final class UserRegistrationUnexpectedDataSourceException
    extends UserRegistrationDataSourceException {
  /// Creates an unexpected-response exception.
  const UserRegistrationUnexpectedDataSourceException();
}
