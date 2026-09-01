import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_card_content.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/membership/membership_reveal_progress.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';

/// One membership card with its coordinated group reveal transform.
final class MembershipCardItem extends StatelessWidget {
  /// Creates a membership card item.
  const MembershipCardItem({
    required this.index,
    required this.card,
    required this.usesCoordinatedHeight,
    super.key,
  });

  /// Card position in the complete membership group.
  final int index;

  /// Localized membership card presentation data.
  final MembershipCardContent card;

  /// Whether the card participates in an equal-height row.
  final bool usesCoordinatedHeight;

  @override
  Widget build(BuildContext context) {
    final reveal = MembershipRevealProgress.of(context);
    final elapsedMilliseconds =
        reveal.progress * reveal.sequenceDurationMilliseconds;
    final delayMilliseconds = reveal.staggerMilliseconds * index;
    final cardProgress = LandingMotion.standardCurve.transform(
      ((elapsedMilliseconds - delayMilliseconds) /
              reveal.cardDurationMilliseconds)
          .clamp(0, 1),
    );

    return Transform.translate(
      key: Key('membershipCardRevealTransform-${card.semanticId}'),
      offset: Offset(reveal.initialDistance * (1 - cardProgress), 0),
      child: Opacity(
        key: Key('membershipCardRevealOpacity-${card.semanticId}'),
        opacity: 0.12 + (0.88 * cardProgress),
        alwaysIncludeSemantics: true,
        child: MembershipCard(
          semanticId: card.semanticId,
          variant: card.variant,
          tierName: card.tierName,
          price: card.price,
          billingPeriod: card.billingPeriod,
          priceSemanticLabel: card.priceSemanticLabel,
          description: card.description,
          benefits: card.benefits,
          ctaLabel: card.ctaLabel,
          footnote: card.footnote,
          badgeLabel: card.badgeLabel,
          usesCoordinatedHeight: usesCoordinatedHeight,
        ),
      ),
    );
  }
}
