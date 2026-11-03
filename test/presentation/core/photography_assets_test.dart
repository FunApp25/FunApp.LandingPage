@TestOn('vm')
library;

// Bundle packaging is checked on VM; web decoding uses release-browser checks.
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'photography decodes at its approved dimensions within byte budgets',
    () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest.listAssets();
      final photographs = <String, (int, int, int)>{
        AppAssets.heroPeopleMobile: (864, 878, 100000),
        AppAssets.heroPeople: (1412, 1434, 210000),
        AppAssets.connectionGroup: (1360, 614, 200000),
        AppAssets.foundingFriendsGroup: (673, 410, 70000),
        AppAssets.venueGroup: (673, 410, 85000),
        'assets/landing/founding_friends/2.0x/founding_friends_group.webp': (
          1346,
          820,
          220000,
        ),
        'assets/landing/venues/2.0x/venue_group.webp': (1346, 820, 280000),
      };

      for (final entry in photographs.entries) {
        final path = entry.key;
        final (width, height, byteBudget) = entry.value;
        expect(path, endsWith('.webp'));
        expect(
          assets.expand(
            (asset) => manifest.getAssetVariants(asset)!.map((v) => v.key),
          ),
          contains(path),
        );
        expect(assets, isNot(contains(path.replaceAll('.webp', '.png'))));

        final data = await rootBundle.load(path);
        expect(data.lengthInBytes, lessThanOrEqualTo(byteBudget), reason: path);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        final frame = await codec.getNextFrame();
        expect(frame.image.width, width, reason: path);
        expect(frame.image.height, height, reason: path);
        frame.image.dispose();
        codec.dispose();
      }
    },
  );

  test(
    'promotional photos use 1x and 2x variants without changing layout size',
    () async {
      for (final path in [
        AppAssets.foundingFriendsGroup,
        AppAssets.venueGroup,
      ]) {
        for (final dpr in [1.0, 2.0, 3.0]) {
          final image = await AssetImage(path).obtainKey(
            ImageConfiguration(devicePixelRatio: dpr),
          );
          final fullSizePath = path.replaceFirstMapped(
            RegExp(r'/([^/]+)$'),
            (match) => '/2.0x/${match[1]}',
          );
          expect(image.name, dpr == 1 ? path : fullSizePath);
          expect(image.scale, dpr == 1 ? 1 : 2);
        }
      }
    },
  );
}
