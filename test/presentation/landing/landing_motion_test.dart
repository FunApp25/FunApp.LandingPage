import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';

void main() {
  group('LandingMotion.navigationDurationFor', () {
    test('returns zero for an effectively aligned destination', () {
      expect(
        LandingMotion.navigationDurationFor(
          distance: 1,
          viewportDimension: 1000,
        ),
        Duration.zero,
      );
    });

    test('keeps nearby nonzero navigation at the minimum duration', () {
      expect(
        LandingMotion.navigationDurationFor(
          distance: 2,
          viewportDimension: 1000,
        ),
        const Duration(milliseconds: 220),
      );
    });

    test('scales representative distances by viewport count', () {
      expect(
        LandingMotion.navigationDurationFor(
          distance: 250,
          viewportDimension: 1000,
        ),
        const Duration(milliseconds: 235),
      );
      expect(
        LandingMotion.navigationDurationFor(
          distance: 1000,
          viewportDimension: 1000,
        ),
        const Duration(milliseconds: 280),
      );
      expect(
        LandingMotion.navigationDurationFor(
          distance: 4000,
          viewportDimension: 1000,
        ),
        const Duration(milliseconds: 460),
      );
      expect(
        LandingMotion.navigationDurationFor(
          distance: 8000,
          viewportDimension: 1000,
        ),
        const Duration(milliseconds: 700),
      );
    });

    test('caps sufficiently long navigation', () {
      expect(
        LandingMotion.navigationDurationFor(
          distance: 10000,
          viewportDimension: 1000,
        ),
        const Duration(milliseconds: 800),
      );
    });

    test('uses a defensive minimum for unusable viewport dimensions', () {
      for (final viewportDimension in [0.0, 0.5, -1.0]) {
        expect(
          LandingMotion.navigationDurationFor(
            distance: 100,
            viewportDimension: viewportDimension,
          ),
          const Duration(milliseconds: 220),
        );
      }
    });
  });

  test('anchor navigation retains cubic acceleration and deceleration', () {
    expect(LandingMotion.navigationCurve, Curves.easeInOutCubic);
  });
}
