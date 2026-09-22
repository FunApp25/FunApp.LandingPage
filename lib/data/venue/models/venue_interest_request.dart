import 'package:fun_app_landing_page/data/venue/models/venue_lead_dto.dart';

/// First-party JSON request for a prospective-venue submission.
final class VenueInterestRequest {
  const VenueInterestRequest._({
    required this._venueName,
    required this._venueType,
    required this._chainStatus,
    required this._venueCount,
    required this._venueCapacity,
    required this._website,
    required this._firstName,
    required this._lastName,
    required this._role,
    required this._email,
    required this._phoneNumber,
  });

  /// Translates the provider-neutral DTO at the first-party HTTP boundary.
  factory VenueInterestRequest.fromVenueLead(VenueLeadDto lead) =>
      VenueInterestRequest._(
        venueName: lead.venueName,
        venueType: lead.venueType,
        chainStatus: lead.chainStatus,
        venueCount: lead.venueCount,
        venueCapacity: lead.venueCapacity,
        website: lead.website,
        firstName: lead.firstName,
        lastName: lead.lastName,
        role: lead.role,
        email: lead.email,
        phoneNumber: lead.phoneNumber,
      );

  final String _venueName;
  final String? _venueType;
  final String? _chainStatus;
  final int? _venueCount;
  final int? _venueCapacity;
  final String _website;
  final String _firstName;
  final String _lastName;
  final String _role;
  final String _email;
  final String? _phoneNumber;

  /// Serializes only the Fun App-owned request contract.
  Map<String, Object> toJson() {
    final request = <String, Object>{
      'venueName': _venueName,
      'website': _website,
      'firstName': _firstName,
      'lastName': _lastName,
      'role': _role,
      'email': _email,
    };

    if (_venueType case final venueType?) {
      request['venueType'] = venueType;
    }
    if (_chainStatus case final chainStatus?) {
      request['chainStatus'] = chainStatus;
    }
    if (_venueCount case final venueCount?) {
      request['venueCount'] = venueCount;
    }
    if (_venueCapacity case final venueCapacity?) {
      request['venueCapacity'] = venueCapacity;
    }
    if (_phoneNumber case final phoneNumber?) {
      request['phoneNumber'] = phoneNumber;
    }

    return request;
  }
}
