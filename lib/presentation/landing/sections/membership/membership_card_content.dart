import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_models.dart';

/// Localized presentation data for one membership card.
typedef MembershipCardContent = ({
  String semanticId,
  MembershipCardVariant variant,
  String tierName,
  String price,
  String billingPeriod,
  String priceSemanticLabel,
  String description,
  List<MembershipBenefit> benefits,
  String ctaLabel,
  String footnote,
  String? badgeLabel,
});
