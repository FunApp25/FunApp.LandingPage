/// Base exception for classified venue-lead data-source failures.
sealed class VenueLeadDataSourceException implements Exception {
  const VenueLeadDataSourceException();
}

/// The data-source service cannot currently accept a request.
final class VenueLeadServiceUnavailableException
    extends VenueLeadDataSourceException {
  /// Creates a [VenueLeadServiceUnavailableException].
  const VenueLeadServiceUnavailableException();
}

/// The data source deliberately rejected the submission.
final class VenueLeadSubmissionRejectedException
    extends VenueLeadDataSourceException {
  /// Creates a [VenueLeadSubmissionRejectedException].
  const VenueLeadSubmissionRejectedException();
}

/// The selected provider integration has not been implemented yet.
final class VenueLeadIntegrationNotImplementedException
    extends VenueLeadDataSourceException {
  /// Creates a [VenueLeadIntegrationNotImplementedException].
  const VenueLeadIntegrationNotImplementedException();
}
