import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/connection/connection_experience_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/hero/hero_section.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';

import '../landing_test_helpers.dart';

void main() {
  testWidgets('matches the 390px mobile Hero composition', (tester) async {
    setTestSurface(tester, const Size(390, 844));
    await pumpLandingSection(tester, section: const HeroSection());

    final sectionRect = tester.getRect(find.byType(HeroSection));
    final cardRect = tester.getRect(find.byKey(const Key('heroCard')));
    final artworkRect = tester.getRect(
      find.byKey(const Key('heroPeopleImage')),
    );
    final contentRect = tester.getRect(
      find.byKey(const Key('heroContentBounds')),
    );
    final headline = tester.widget<Text>(
      find.byKey(const Key('heroHeadlineText')),
    );
    final supporting = tester.widget<Text>(
      find.byKey(const Key('heroSupportingText')),
    );
    final cardClip = tester.widget<ClipRRect>(
      find.byKey(const Key('heroCard')),
    );

    expect(find.byKey(const Key('heroMobileLayout')), findsOneWidget);
    expect(find.byKey(const Key('heroResponsiveLayout')), findsNothing);
    expect(cardRect.left - sectionRect.left, 16);
    expect(sectionRect.right - cardRect.right, 16);
    expect(cardRect.top - sectionRect.top, 0);
    expect(cardRect.width, 358);
    expect(
      cardClip.borderRadius,
      const BorderRadius.all(Radius.circular(AppSizes.cardRadius)),
    );
    expect(artworkRect.size, const Size(432, 439));
    expect(artworkRect.top - cardRect.top, closeTo(-115, 0.01));
    expect(artworkRect.center.dx, closeTo(cardRect.center.dx, 0.01));
    expect(contentRect.left - cardRect.left, 16);
    expect(cardRect.right - contentRect.right, 16);
    expect(contentRect.width, 326);
    expect(contentRect.top - artworkRect.bottom, closeTo(48, 0.01));
    expect(cardRect.bottom - contentRect.bottom, 48);
    expect(headline.textAlign, TextAlign.center);
    expect(headline.textSpan?.style?.fontSize, 36);
    expect(headline.textSpan?.style?.height, closeTo(46 / 36, 0.0001));
    expect(supporting.textAlign, TextAlign.center);
    expect(supporting.style?.fontSize, 16);
    expect(supporting.style?.height, closeTo(24 / 16, 0.0001));
    expect(find.byKey(const Key('heroPeopleImage')), findsOneWidget);
    expect(find.byKey(const Key('landingHeroWaitlistCta')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('matches the 390px mobile Connection composition', (
    tester,
  ) async {
    setTestSurface(tester, const Size(390, 844));
    await pumpLandingSection(
      tester,
      section: const ConnectionExperienceSection(),
    );

    final sectionRect = tester.getRect(
      find.byType(ConnectionExperienceSection),
    );
    final contentRect = tester.getRect(
      find.byKey(const Key('connectionMobileLayout')),
    );
    final imageRect = tester.getRect(
      find.byKey(const Key('connectionImageFrame')),
    );
    final heading = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('connectionHeadingSemantics')),
        matching: find.byType(Text),
      ),
    );
    final body = tester.widget<Text>(
      find.byKey(const Key('connectionBodyText')),
    );
    final eyebrow = tester.widget<SectionEyebrow>(
      find.byType(SectionEyebrow),
    );
    final image = tester.widget<Image>(
      find.byKey(const Key('connectionExperienceImage')),
    );
    final imageClip = tester.widget<ClipRRect>(
      find.byKey(const Key('connectionImageClip')),
    );

    expect(contentRect.left - sectionRect.left, 16);
    expect(sectionRect.right - contentRect.right, 16);
    expect(contentRect.top - sectionRect.top, 80);
    expect(contentRect.width, 358);
    expect(eyebrow.alignment, MainAxisAlignment.center);
    expect(heading.textAlign, TextAlign.center);
    expect(heading.style?.fontSize, 32);
    expect(heading.style?.height, closeTo(42 / 32, 0.0001));
    expect(body.textAlign, TextAlign.center);
    expect(body.style?.fontSize, 18);
    expect(body.style?.height, closeTo(28 / 18, 0.0001));
    expect(imageRect.top - contentRect.bottom, 40);
    expect(imageRect.size, const Size(358, 364));
    expect(sectionRect.bottom - imageRect.bottom, 80);
    expect(image.fit, BoxFit.cover);
    expect(image.alignment, Alignment.center);
    expect(
      imageClip.borderRadius,
      const BorderRadius.all(Radius.circular(AppSizes.cardRadius)),
    );
    expect(
      find.text('Do you recognise any of these experiences?'),
      findsOneWidget,
    );
    expect(find.text('Let’s change the world together'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches Hero and Connection exactly at 599/600', (
    tester,
  ) async {
    for (final width in [599.0, 600.0]) {
      setTestSurface(tester, Size(width, 900));
      await pumpLandingApp(tester);

      final isMobile = width < 600;
      expect(
        find.byKey(const Key('heroMobileLayout')),
        isMobile ? findsOneWidget : findsNothing,
      );
      expect(
        find.byKey(const Key('heroResponsiveLayout')),
        isMobile ? findsNothing : findsOneWidget,
      );
      expect(
        find.byKey(const Key('connectionMobileLayout')),
        isMobile ? findsOneWidget : findsNothing,
      );
      expect(
        find.byKey(const Key('connectionStackedLayout')),
        isMobile ? findsNothing : findsOneWidget,
      );

      final heroSection = tester.getRect(find.byType(HeroSection));
      final heroCard = tester.getRect(find.byKey(const Key('heroCard')));
      final connectionImage = tester.getRect(
        find.byKey(const Key('connectionImageFrame')),
      );
      expect(heroCard.top - heroSection.top, isMobile ? 0 : 20);
      expect(
        connectionImage.size.aspectRatio,
        closeTo(isMobile ? 358 / 364 : 1360 / 614, 0.001),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('keeps mobile Hero and Connection safe in every locale', (
    tester,
  ) async {
    for (final locale in AppLocalizations.supportedLocales) {
      for (final width in [320.0, 390.0]) {
        setTestSurface(tester, Size(width, 844));
        await pumpLandingApp(tester, locale: locale);

        final heroCard = tester.getRect(find.byKey(const Key('heroCard')));
        final heroArtwork = tester.getRect(
          find.byKey(const Key('heroPeopleImage')),
        );
        final heroContent = tester.getRect(
          find.byKey(const Key('heroContentBounds')),
        );
        final connectionSection = tester.getRect(
          find.byType(ConnectionExperienceSection),
        );
        final connectionImage = tester.getRect(
          find.byKey(const Key('connectionImageFrame')),
        );
        final heroSupporting = tester.widget<Text>(
          find.byKey(const Key('heroSupportingText')),
        );
        final connectionBody = tester.widget<Text>(
          find.byKey(const Key('connectionBodyText')),
        );

        expect(heroCard.left, greaterThanOrEqualTo(0));
        expect(heroCard.right, lessThanOrEqualTo(width));
        expect(heroArtwork.width, greaterThan(heroCard.width));
        expect(heroArtwork.center.dx, closeTo(heroCard.center.dx, 0.01));
        expect(heroContent.top - heroArtwork.bottom, greaterThan(0));
        expect(heroSupporting.maxLines, isNull);
        expect(heroSupporting.overflow, isNot(TextOverflow.ellipsis));
        expect(find.byKey(const Key('heroPeopleImage')), findsOneWidget);
        expect(connectionSection.width, lessThanOrEqualTo(width));
        expect(connectionImage.width, width - 32);
        expect(connectionBody.maxLines, isNull);
        expect(connectionBody.overflow, isNot(TextOverflow.ellipsis));
        expect(
          tester.takeException(),
          isNull,
          reason: '${locale.languageCode} must fit at ${width}px.',
        );
      }
    }
  });
}
