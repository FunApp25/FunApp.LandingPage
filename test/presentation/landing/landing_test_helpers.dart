import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';

/// Pumps the complete landing application with [locale] as the platform locale.
Future<void> pumpLandingApp(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  tester.binding.platformDispatcher.localesTestValue = <Locale>[locale];
  addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(const FunAppLandingPageApp());
  await tester.pump();
}

/// Configures a deterministic one-device-pixel test viewport.
void setTestSurface(WidgetTester tester, Size size) {
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
}

/// Returns the asset name loaded by the SVG identified by [key].
String svgAssetName(WidgetTester tester, Key key) {
  final picture = tester.widget<SvgPicture>(find.byKey(key));
  expect(picture.bytesLoader, isA<SvgAssetLoader>());
  return (picture.bytesLoader as SvgAssetLoader).assetName;
}

/// Verifies that the SVG identified by [key] loads [expectedAsset].
void expectSvgAsset(
  WidgetTester tester,
  Key key,
  String expectedAsset,
) {
  expect(svgAssetName(tester, key), expectedAsset);
}

/// Verifies a heading semantic label without coupling to its visual widget.
void expectHeaderSemantics(
  WidgetTester tester,
  Key key,
  String expectedLabel,
) {
  final data = tester.getSemantics(find.byKey(key)).getSemanticsData();
  expect(data.label, expectedLabel);
  expect(data.flagsCollection.isHeader, isTrue);
}
