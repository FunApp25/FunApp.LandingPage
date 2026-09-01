import 'package:flutter/material.dart';

/// Shares the research group reveal progress with each statistic card.
final class ResearchRevealProgress extends InheritedWidget {
  /// Creates the research reveal progress scope.
  const ResearchRevealProgress({
    required this.progress,
    required super.child,
    super.key,
  });

  /// Current group reveal progress from zero to one.
  final double progress;

  /// Returns the current research group reveal progress.
  static double of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ResearchRevealProgress>()!
      .progress;

  @override
  bool updateShouldNotify(ResearchRevealProgress oldWidget) =>
      progress != oldWidget.progress;
}
