import 'package:dartz/dartz.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_exception.dart';
import 'package:fun_app_landing_page/data/venue/data_sources/venue_lead_data_source_interface.dart';
import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';
import 'package:fun_app_landing_page/domain/venue/venue_lead_repository_interface.dart';
import 'package:injectable/injectable.dart';

/// Provider-neutral venue-lead repository backed by an injected data source.
@LazySingleton(as: VenueLeadRepositoryInterface)
final class VenueLeadRepository implements VenueLeadRepositoryInterface {
  /// Creates a [VenueLeadRepository].
  const VenueLeadRepository(this._dataSource);

  final VenueLeadDataSourceInterface _dataSource;

  @override
  Future<Either<AppFailure, Unit>> submitVenueLead(VenueLead lead) async {
    if (lead.isValid) {
      try {
        final dto = VenueLeadDto.fromValidDomain(lead);
        await _dataSource.submitVenueLead(dto);

        return right(unit);
      } on VenueLeadServiceUnavailableException {
        return left(const AppFailure.serviceUnavailable());
      } on VenueLeadSubmissionRejectedException {
        return left(const AppFailure.submissionRejected());
      } on VenueLeadUnexpectedDataSourceException {
        return left(const AppFailure.unexpected());
      } on Object {
        return left(const AppFailure.unexpected());
      }
    } else {
      return left(const AppFailure.unexpected());
    }
  }
}
