/// The two approved prospective-user sign-up experiences.
enum UserSignUpExperience {
  /// Six-month Here & Now membership waitlist.
  hereAndNow,

  /// Founding Friend interest before a future provider checkout.
  foundingFriend,
}

/// One provider-neutral option shown by a user sign-up dropdown.
typedef UserSignUpOption = ({String value, String label});

/// Presentation-owned draft passed only to an explicitly injected submit seam.
///
/// Production does not currently provide that seam, so this value is neither
/// persisted nor transported until the Cloudflare-backed integration exists.
final class UserSignUpDraft {
  /// Creates a complete presentation draft after local validation succeeds.
  const UserSignUpDraft({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    required this.gender,
    required this.country,
    required this.usageReason,
    required this.marketingConsent,
  });

  /// First name exactly as entered.
  final String firstName;

  /// Last name exactly as entered.
  final String lastName;

  /// Email exactly as entered.
  final String email;

  /// Required integer age.
  final int age;

  /// Optional HubSpot-compatible gender value.
  final String? gender;

  /// Required HubSpot-compatible country value for Founding Friend only.
  final String? country;

  /// Optional usage reason exactly as entered.
  final String? usageReason;

  /// Explicit optional marketing opt-in, initially false.
  final bool marketingConsent;
}

/// Test/development-safe seam for exercising locally validated form state.
typedef UserSignUpSubmit = void Function(UserSignUpDraft draft);
