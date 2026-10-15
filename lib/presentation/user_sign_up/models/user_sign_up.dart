/// The two approved prospective-user sign-up experiences.
enum UserSignUpExperience {
  /// Six-month Here & Now membership waitlist.
  hereAndNow,

  /// Founding Friend interest before a future provider checkout.
  foundingFriend,
}

/// One provider-neutral option shown by a user sign-up dropdown.
typedef UserSignUpOption = ({String value, String label});
