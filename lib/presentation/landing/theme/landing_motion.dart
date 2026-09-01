// Landing motion uses a deliberately small shared token vocabulary.
// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/animation.dart';

/// Restrained interaction-motion tokens for the landing presentation.
abstract final class LandingMotion {
  /// Brief hover and state-icon transition.
  static const Duration fastDuration = Duration(milliseconds: 120);

  /// Standard local state-transition duration.
  static const Duration standardDuration = Duration(milliseconds: 200);

  /// Standard curve for local interaction feedback.
  static const Curve standardCurve = Curves.easeOutCubic;

  /// Curve for bounded in-page navigation movement.
  static const Curve navigationCurve = Curves.easeInOutCubic;

  static const _minimumNavigationDuration = 220;
  static const _maximumNavigationDuration = 800;
  static const _navigationDurationPerViewport = 60.0;

  /// Resolves [normalDuration] to zero when motion is disabled.
  static Duration duration({
    required bool disableAnimations,
    required Duration normalDuration,
  }) => disableAnimations ? Duration.zero : normalDuration;

  /// Resolves bounded anchor-navigation timing from the current geometry.
  static Duration navigationDurationFor({
    required double distance,
    required double viewportDimension,
  }) {
    final absoluteDistance = distance.abs();

    if (absoluteDistance <= 1) {
      return Duration.zero;
    } else if (viewportDimension <= 1) {
      return const Duration(milliseconds: _minimumNavigationDuration);
    } else {
      final screens = absoluteDistance / viewportDimension;
      final milliseconds =
          (_minimumNavigationDuration +
                  (_navigationDurationPerViewport * screens))
              .round()
              .clamp(
                _minimumNavigationDuration,
                _maximumNavigationDuration,
              );

      return Duration(milliseconds: milliseconds);
    }
  }
}
