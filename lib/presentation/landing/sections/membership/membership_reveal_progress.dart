import 'package:flutter/material.dart';

/// Shares membership group reveal configuration with each card.
final class MembershipRevealProgress extends InheritedWidget {
  /// Creates the membership reveal progress scope.
  const MembershipRevealProgress({
    required this.progress,
    required this.cardDurationMilliseconds,
    required this.staggerMilliseconds,
    required this.sequenceDurationMilliseconds,
    required this.initialDistance,
    required super.child,
    super.key,
  });

  /// Current group reveal progress from zero to one.
  final double progress;

  /// Duration of an individual card reveal.
  final int cardDurationMilliseconds;

  /// Delay between adjacent cards.
  final int staggerMilliseconds;

  /// Duration of the complete group sequence.
  final int sequenceDurationMilliseconds;

  /// Initial horizontal translation.
  final double initialDistance;

  /// Returns the current membership reveal scope.
  static MembershipRevealProgress of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MembershipRevealProgress>()!;

  @override
  bool updateShouldNotify(MembershipRevealProgress oldWidget) =>
      progress != oldWidget.progress ||
      cardDurationMilliseconds != oldWidget.cardDurationMilliseconds ||
      staggerMilliseconds != oldWidget.staggerMilliseconds ||
      sequenceDurationMilliseconds != oldWidget.sequenceDurationMilliseconds ||
      initialDistance != oldWidget.initialDistance;
}
