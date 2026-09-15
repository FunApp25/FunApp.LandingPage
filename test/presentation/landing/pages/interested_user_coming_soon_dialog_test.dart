import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_friends/founding_friends_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_section.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_dialog.dart';

import '../landing_test_helpers.dart';

void main() {
  testWidgets(
    'Founding Friends opens and closes the localized coming-soon dialog',
    (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      setTestSurface(tester, const Size(390, 844));
      await pumpLandingApp(tester);

      final landingPageContext = tester.element(find.byType(LandingPage));
      final l10n = AppLocalizations.of(landingPageContext);
      final foundingCta = find.byKey(const Key('foundingFriendsCta'));

      expect(foundingCta, findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(FoundingFriendsSection),
          matching: find.byType(InkWell),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(VenueSection),
          matching: find.byType(InkWell),
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(foundingCta);
      await tester.tap(foundingCta);
      await tester.pumpAndSettle();

      expect(find.byType(LandingDialog), findsOneWidget);
      expect(
        find.text(l10n.landingInterestedUserComingSoonTitle),
        findsOneWidget,
      );
      expect(
        find.text(l10n.landingInterestedUserComingSoonBody),
        findsOneWidget,
      );
      expect(find.byType(EditableText), findsNothing);
      expect(find.byType(TextField), findsNothing);
      final close = find.byKey(const Key('landingDialogCloseButton'));
      final closeSemantics = tester.getSemantics(close).getSemanticsData();
      expect(closeSemantics.label, l10n.landingDialogClose);
      expect(closeSemantics.flagsCollection.isButton, isTrue);

      await tester.tap(close);
      await tester.pumpAndSettle();

      expect(find.byType(LandingDialog), findsNothing);
      expect(foundingCta, findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('coming-soon dialog fits mobile and desktop viewports', (
    tester,
  ) async {
    for (final size in const [Size(320, 568), Size(1440, 900)]) {
      setTestSurface(tester, size);
      await pumpLandingApp(tester);

      final foundingCta = find.byKey(const Key('foundingFriendsCta'));
      await tester.ensureVisible(foundingCta);
      await tester.tap(foundingCta);
      await tester.pumpAndSettle();

      final dialogRect = tester.getRect(
        find.byKey(const Key('landingDialogSurface')),
      );
      expect(dialogRect.left, greaterThanOrEqualTo(16));
      expect(dialogRect.right, lessThanOrEqualTo(size.width - 16));
      expect(dialogRect.top, greaterThanOrEqualTo(0));
      expect(dialogRect.bottom, lessThanOrEqualTo(size.height));
      expect(find.byKey(const Key('landingDialogScrollView')), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'Expected no overflow at $size.',
      );

      await tester.tap(find.byKey(const Key('landingDialogCloseButton')));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('coming-soon content uses the active locale', (tester) async {
    setTestSurface(tester, const Size(390, 844));
    await pumpLandingApp(tester, locale: const Locale('es'));

    final l10n = AppLocalizations.of(
      tester.element(find.byType(LandingPage)),
    );
    await tester.ensureVisible(find.byKey(const Key('foundingFriendsCta')));
    await tester.tap(find.byKey(const Key('foundingFriendsCta')));
    await tester.pumpAndSettle();

    expect(
      find.text(l10n.landingInterestedUserComingSoonTitle),
      findsOneWidget,
    );
    expect(find.text(l10n.landingInterestedUserComingSoonBody), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
  });
}
