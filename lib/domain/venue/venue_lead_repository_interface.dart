import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';

/// Provider-neutral boundary for prospective-venue submissions.
abstract interface class VenueLeadRepositoryInterface {
  /// Performs one logical submission and acknowledges application-level
  /// success.
  Future<Either<AppFailure, Unit>> submitVenueLead(VenueLead lead);
}
