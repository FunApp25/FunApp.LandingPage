/// Visual variants in the current static membership pricing design.
enum MembershipCardVariant {
  /// White Free Membership card.
  free,

  /// Yellow Here & Now Membership card.
  hereNow,

  /// Dark Lifetime Membership card.
  lifetime,
}

/// One localized benefit in a presentation-only membership card.
typedef MembershipBenefit = ({String label, bool emphasized});
