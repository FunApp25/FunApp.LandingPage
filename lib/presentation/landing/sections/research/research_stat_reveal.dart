import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_reveal_progress.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';

/// Staggered visual reveal wrapper for one research statistic card.
final class ResearchStatReveal extends StatelessWidget {
  /// Creates one research statistic reveal wrapper.
  const ResearchStatReveal({
    required this.index,
    required this.cardDurationMilliseconds,
    required this.staggerMilliseconds,
    required this.sequenceDurationMilliseconds,
    required this.initialDistance,
    required this.initialOpacity,
    required this.child,
    super.key,
  });

  /// Card position in the research group.
  final int index;

  /// Duration of this card's reveal.
  final int cardDurationMilliseconds;

  /// Delay between adjacent cards.
  final int staggerMilliseconds;

  /// Duration of the complete group sequence.
  final int sequenceDurationMilliseconds;

  /// Initial vertical translation.
  final double initialDistance;

  /// Initial opacity before reveal.
  final double initialOpacity;

  /// Statistic card retained throughout the transition.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final groupProgress = ResearchRevealProgress.of(context);
    final elapsedMilliseconds = groupProgress * sequenceDurationMilliseconds;
    final delayMilliseconds = staggerMilliseconds * index;
    final cardProgress = LandingMotion.standardCurve.transform(
      ((elapsedMilliseconds - delayMilliseconds) / cardDurationMilliseconds)
          .clamp(0, 1),
    );

    return Transform.translate(
      key: Key('researchStatRevealTransform$index'),
      offset: Offset(0, initialDistance * (1 - cardProgress)),
      child: Opacity(
        key: Key('researchStatRevealOpacity$index'),
        opacity: initialOpacity + ((1 - initialOpacity) * cardProgress),
        alwaysIncludeSemantics: true,
        child: child,
      ),
    );
  }
}
