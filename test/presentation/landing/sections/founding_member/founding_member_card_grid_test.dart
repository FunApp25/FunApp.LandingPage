import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_card_grid.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_section.dart';

import '../../landing_test_helpers.dart';

void main() {
  testWidgets('single-column cards fill the width even with short content', (
    tester,
  ) async {
    setTestSurface(tester, const Size(600, 900));
    await pumpLandingSection(
      tester,
      section: const FoundingMemberCardGrid(
        cards: [
          (
            semanticId: 'short',
            iconAsset: AppAssets.foundingMemberUsers,
            title: 'Badge',
            body: 'Visible recognition.',
          ),
          (
            semanticId: 'longer',
            iconAsset: AppAssets.foundingMemberChat,
            title: 'Membership',
            body: 'A longer benefit description.',
          ),
          (
            semanticId: 'third',
            iconAsset: AppAssets.foundingMemberRocket,
            title: 'Access',
            body: 'Early access.',
          ),
        ],
      ),
    );
    for (final id in ['short', 'longer', 'third']) {
      expect(
        tester.getSize(find.byKey(Key('foundingMemberCardSurface-$id'))).width,
        600,
      );
    }
    expect(tester.takeException(), isNull);
  });
  for (final locale in AppLocalizations.supportedLocales) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('benefit card dimensions and wrapping: $locale, ${scale}x', (
        tester,
      ) async {
        for (final width in [
          320.0,
          390.0,
          599.0,
          600.0,
          746.0,
          747.0,
          900.0,
          1095.0,
          1096.0,
          1439.0,
          1440.0,
        ]) {
          setTestSurface(tester, Size(width, 1000));
          await tester.pumpWidget(
            MaterialApp(
              theme: appTheme,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                ),
                child: child!,
              ),
              home: const Scaffold(
                body: SingleChildScrollView(child: FoundingMemberSection()),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final columns = width < 747
              ? 1
              : width < 1096
              ? 2
              : 3;
          if (width < 600) {
            expect(
              find.byKey(const Key('foundingMemberMobileLayout')),
              findsOneWidget,
            );
          } else {
            expect(
              find.byKey(Key('foundingMemberCardsColumns$columns')),
              findsOneWidget,
            );
          }
          Size? firstSize;
          for (final id in ['recognised', 'lifetime', 'access']) {
            if (width < 600 && id != 'recognised') {
              final carousel = find.byType(PageView);
              await tester.ensureVisible(carousel);
              await tester.dragFrom(
                tester.getTopLeft(carousel) + const Offset(100, 50),
                Offset(-width * 0.75, 0),
              );
              await tester.pumpAndSettle();
            }
            final surface = find.byKey(Key('foundingMemberCardSurface-$id'));
            final rect = tester.getRect(surface);
            firstSize ??= rect.size;
            expect(
              rect.width,
              closeTo(firstSize.width, 0.01),
              reason:
                  '$width, $id, local size ${tester.getSize(surface)}, '
                  'rect $rect',
            );
            if (width < 600 || columns > 1) {
              expect(
                rect.height,
                closeTo(firstSize.height, 0.01),
                reason: '$width, $id',
              );
            }
            for (final part in ['Title', 'Body', 'Icon']) {
              final content = tester.getRect(
                find.byKey(
                  Key(
                    part == 'Icon'
                        ? 'foundingMemberIcon-$id'
                        : 'foundingMemberCard$part-$id',
                  ),
                ),
              );
              expect(content.top, greaterThanOrEqualTo(rect.top));
              expect(content.bottom, lessThanOrEqualTo(rect.bottom));
              expect(content.left, greaterThanOrEqualTo(rect.left));
              expect(content.right, lessThanOrEqualTo(rect.right));
            }
          }
          expect(
            tester.takeException(),
            isNull,
            reason: '$width, $locale, $scale',
          );
          // Start each viewport with a fresh carousel position.
          await tester.pumpWidget(const SizedBox.shrink());
        }
      });
    }
  }
}
