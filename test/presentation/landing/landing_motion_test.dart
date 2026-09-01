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

    test('scales representative distances by viewport count', () {
      expect(
        LandingMotion.navigationDurationFor(
          distance: 250,
          viewportDimension: 1000,
        ),
        const Duration(milliseconds: 171),
      );
      expect(
        LandingMotion.navigationDurationFor(
          distance: 1000,
          viewportDimension: 1000,
        ),
        const Duration(milliseconds: 205),
      );
      expect(
        LandingMotion.navigationDurationFor(
          distance: 4000,
          viewportDimension: 1000,
        ),
        const Duration(milliseconds: 340),
      );
    });

    test('caps sufficiently long navigation', () {
      expect(
        LandingMotion.navigationDurationFor(
          distance: 12000,
          viewportDimension: 1000,
        ),
        const Duration(milliseconds: 520),
      );
    });

    test('uses a defensive minimum for unusable viewport dimensions', () {
      for (final viewportDimension in [0.0, 0.5, -1.0]) {
        expect(
          LandingMotion.navigationDurationFor(
            distance: 100,
            viewportDimension: viewportDimension,
          ),
          const Duration(milliseconds: 160),
        );
      }
    });
  });
}
