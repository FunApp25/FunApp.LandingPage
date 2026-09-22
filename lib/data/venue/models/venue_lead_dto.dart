import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';

part 'venue_lead_dto.freezed.dart';

/// Validated, provider-neutral values passed to a venue-lead data source.
@freezed
abstract class VenueLeadDto with _$VenueLeadDto {
  /// Creates a [VenueLeadDto].
  const factory VenueLeadDto({
    required String venueName,
    required String? venueType,
    required String? chainStatus,
    required int? venueCount,
    required int? venueCapacity,
    required String website,
    required String firstName,
    required String lastName,
    required String role,
    required String email,
    required String? phoneNumber,
  }) = _VenueLeadDto;

  /// Extracts raw values from an aggregate already validated by the repository.
  factory VenueLeadDto.fromValidDomain(VenueLead lead) => VenueLeadDto(
    venueName: lead.venueName.getOrCrash(),
    venueType: lead.venueType.fold(
      () => null,
      (value) => value.getOrCrash(),
    ),
    chainStatus: lead.chainStatus.fold(
      () => null,
      (value) => value.getOrCrash(),
    ),
    venueCount: lead.venueCount.fold(
      () => null,
      (value) => value.getOrCrash(),
    ),
    venueCapacity: lead.venueCapacity.fold(
      () => null,
      (value) => value.getOrCrash(),
    ),
    website: lead.website.getOrCrash(),
    firstName: lead.firstName.getOrCrash(),
    lastName: lead.lastName.getOrCrash(),
    role: lead.role.getOrCrash(),
    email: lead.email.getOrCrash(),
    phoneNumber: lead.phoneNumber.fold(
      () => null,
      (value) => value.getOrCrash(),
    ),
  );
}
