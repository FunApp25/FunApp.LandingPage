import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/app_widget.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/founding_friend_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/here_and_now_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_success.dart';

import '../landing/landing_test_helpers.dart';

void main() {
  const hereAndNowIntroduction =
      'Thank you for interest in joining Fun App with a 6 month free trial '
      'of Here & Now membership';
  const hereAndNowIntroductionBody =
      'Sign up by entering your details on this form and secure your place '
      "in the queue. We'll stay in touch as Fun App moves towards launch. "
      'Welcome!';
  const foundingFriendIntroduction =
      'Thank you for your interest in becoming a Fun App Founding Friend';
  const foundingFriendIntroductionBody =
      'Sign up by entering your details below and get ready for an exciting '
      'journey as you gain Founding Friend status and help Fun App to change '
      'the world. Welcome!';
  const hereAndNowMarketing =
      "Yes, I'd like to receive occasional emails from Fun App about the "
      'upcoming app, including launch updates and exciting news.';
  const foundingFriendMarketing =
      "Yes, I'd like to receive emails from Fun App about the upcoming app, "
      'including launch updates, exciting news and exclusive Founding Friend '
      'communication';

  testWidgets('approved landing CTAs navigate to only their intended forms', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 1000));
    await tester.pumpWidget(const FunAppLandingPageApp());
    await tester.pump();

    final queueCta = find.byKey(const Key('foundingOfferCta'));
    await tester.ensureVisible(queueCta);
    await tester.tap(queueCta);
    await tester.pumpAndSettle();
    expect(find.byType(HereAndNowPage), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.byType(HereAndNowPage)))?.settings.name,
      HereAndNowPage.routeName,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    final hereAndNowCardCta = find.byKey(const Key('membershipCta-hereNow'));
    await tester.ensureVisible(hereAndNowCardCta);
    await tester.tap(hereAndNowCardCta);
    await tester.pumpAndSettle();
    expect(find.byType(HereAndNowPage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    final foundingFriendCta = find.byKey(const Key('foundingFriendsCta'));
    await tester.ensureVisible(foundingFriendCta);
    await tester.tap(foundingFriendCta);
    await tester.pumpAndSettle();
    expect(find.byType(FoundingFriendPage), findsOneWidget);
    expect(
      ModalRoute.of(
        tester.element(find.byType(FoundingFriendPage)),
      )?.settings.name,
      FoundingFriendPage.routeName,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LandingPage), findsOneWidget);
  });

  testWidgets('sign-up shared header returns to a landing section', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 1000));
    await tester.pumpWidget(const FunAppLandingPageApp());
    await tester.pump();
    Navigator.of(
      tester.element(find.byType(LandingPage)),
    ).pushNamed(HereAndNowPage.routeName);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('landingHeaderNavigationItem1')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LandingPage), findsOneWidget);
    expect(find.byType(HereAndNowPage), findsNothing);
    expect(find.byKey(const Key('membershipBackground')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sign-up shared footer returns to a landing section', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 1000));
    await tester.pumpWidget(const FunAppLandingPageApp());
    await tester.pump();
    Navigator.of(
      tester.element(find.byType(LandingPage)),
    ).pushNamed(FoundingFriendPage.routeName);
    await tester.pumpAndSettle();

    final footerMembership = find.byKey(const Key('footerNavigationItem1'));
    await tester.ensureVisible(footerMembership);
    await tester.tap(footerMembership);
    await tester.pumpAndSettle();

    expect(find.byType(FoundingFriendPage), findsNothing);
    expect(find.byType(LandingPage), findsOneWidget);
    expect(find.byKey(const Key('membershipBackground')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Here & Now renders exact approved copy and ordered fields', (
    tester,
  ) async {
    setTestSurface(tester, const Size(1440, 1200));
    await _pumpPage(tester, const HereAndNowPage());

    expect(
      find.text(hereAndNowIntroduction, findRichText: true),
      findsOneWidget,
    );
    expect(find.text(hereAndNowIntroductionBody), findsOneWidget);
    expect(find.text('First Name*'), findsOneWidget);
    expect(find.text('Last Name*'), findsOneWidget);
    expect(find.text('Email*'), findsOneWidget);
    expect(find.text('Age*'), findsOneWidget);
    expect(find.text('Gender'), findsOneWidget);
    expect(
      find.text("As a Here & Now member, I'd like to use Fun App for"),
      findsOneWidget,
    );
    expect(find.text(hereAndNowMarketing), findsOneWidget);
    expect(find.text('Join Here & Now Waitlist'), findsOneWidget);
    expect(find.text('Country*'), findsNothing);
    expect(find.byKey(const Key('nameFieldsRow-hereAndNow')), findsOneWidget);
    expect(
      find.byKey(const Key('contactFieldsRow-hereAndNow')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('demographicFieldsRow-hereAndNow')),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('emailField-hereAndNow'))).dy,
      tester.getTopLeft(find.byKey(const Key('ageField-hereAndNow'))).dy,
    );
    _expectOrdered(
      tester,
      const [
        Key('firstNameField-hereAndNow'),
        Key('emailField-hereAndNow'),
        Key('genderField-hereAndNow'),
        Key('usageReasonField-hereAndNow'),
        Key('marketingConsent-hereAndNow'),
        Key('userSignUpSubmit-hereAndNow'),
      ],
    );

    final submit = tester.widget<FilledButton>(
      find.byKey(const Key('userSignUpSubmit-hereAndNow')),
    );
    expect(submit.onPressed, isNull);
    expect(find.byType(UserSignUpSuccess), findsNothing);
    _expectHint(
      tester,
      const Key('firstNameField-hereAndNow'),
      'Your First Name',
    );
    _expectHint(
      tester,
      const Key('lastNameField-hereAndNow'),
      'Your Last Name',
    );
    _expectHint(
      tester,
      const Key('emailField-hereAndNow'),
      'example@gmail.com',
    );
    _expectHint(tester, const Key('ageField-hereAndNow'), 'Your Age');
    _expectHint(
      tester,
      const Key('genderField-hereAndNow'),
      'Select Your Gender',
    );
    _expectHint(
      tester,
      const Key('usageReasonField-hereAndNow'),
      'Enter Your Message',
    );
    final usageReason = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('usageReasonField-hereAndNow')),
        matching: find.byType(EditableText),
      ),
    );
    expect(usageReason.minLines, 5);
    expect(usageReason.maxLines, 7);
  });

  testWidgets(
    'Founding Friend renders exact approved copy and ordered fields',
    (
      tester,
    ) async {
      setTestSurface(tester, const Size(1440, 1200));
      await _pumpPage(tester, const FoundingFriendPage());

      expect(
        find.text(foundingFriendIntroduction, findRichText: true),
        findsOneWidget,
      );
      expect(find.text(foundingFriendIntroductionBody), findsOneWidget);
      expect(find.text('First Name*'), findsOneWidget);
      expect(find.text('Last Name*'), findsOneWidget);
      expect(find.text('Email*'), findsOneWidget);
      expect(find.text('Age*'), findsOneWidget);
      expect(find.text('Country*'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(
        find.text("As a Founding Friend, I'd like to use Fun App for"),
        findsOneWidget,
      );
      expect(find.text(foundingFriendMarketing), findsOneWidget);
      expect(find.text('Change the World'), findsOneWidget);
      expect(
        find.byKey(const Key('nameFieldsRow-foundingFriend')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('contactFieldsRow-foundingFriend')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('demographicFieldsRow-foundingFriend')),
        findsOneWidget,
      );
      expect(
        tester
            .getTopLeft(find.byKey(const Key('countryField-foundingFriend')))
            .dy,
        tester
            .getTopLeft(find.byKey(const Key('genderField-foundingFriend')))
            .dy,
      );
      _expectOrdered(
        tester,
        const [
          Key('firstNameField-foundingFriend'),
          Key('emailField-foundingFriend'),
          Key('countryField-foundingFriend'),
          Key('usageReasonField-foundingFriend'),
          Key('marketingConsent-foundingFriend'),
          Key('userSignUpSubmit-foundingFriend'),
        ],
      );

      final submit = tester.widget<FilledButton>(
        find.byKey(const Key('userSignUpSubmit-foundingFriend')),
      );
      expect(submit.onPressed, isNull);
      expect(find.byType(UserSignUpSuccess), findsNothing);
      _expectHint(
        tester,
        const Key('countryField-foundingFriend'),
        'Select Your Country',
      );
      expect(
        find.textContaining('Thank you', findRichText: true),
        findsOneWidget,
      );
    },
  );

  testWidgets('Here & Now validates locally and preserves the entered draft', (
    tester,
  ) async {
    UserSignUpDraft? submitted;
    setTestSurface(tester, const Size(390, 1000));
    await _pumpPage(
      tester,
      HereAndNowPage(onSubmit: (draft) => submitted = draft),
    );

    await _tapSubmit(tester, 'hereAndNow');
    expect(find.text('Required field'), findsNWidgets(4));
    expect(submitted, isNull);

    await tester.enterText(
      find.byKey(const Key('firstNameField-hereAndNow')),
      'Alex',
    );
    await tester.enterText(
      find.byKey(const Key('lastNameField-hereAndNow')),
      'Morgan',
    );
    await tester.enterText(
      find.byKey(const Key('emailField-hereAndNow')),
      'not-an-email',
    );
    await tester.enterText(
      find.byKey(const Key('ageField-hereAndNow')),
      '29 years',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('ageField-hereAndNow')),
          )
          .controller
          ?.text,
      '29',
    );
    await _tapSubmit(tester, 'hereAndNow');
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(submitted, isNull);
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('firstNameField-hereAndNow')),
          )
          .controller
          ?.text,
      'Alex',
    );

    await tester.enterText(
      find.byKey(const Key('emailField-hereAndNow')),
      'alex@example.com',
    );
    await _tapSubmit(tester, 'hereAndNow');
    expect(submitted, isNotNull);
    expect(submitted?.firstName, 'Alex');
    expect(submitted?.lastName, 'Morgan');
    expect(submitted?.age, 29);
    expect(submitted?.gender, isNull);
    expect(submitted?.usageReason, isNull);
    expect(submitted?.marketingConsent, isFalse);
    expect(find.byType(UserSignUpSuccess), findsNothing);
  });

  testWidgets('Founding Friend requires country and keeps consent optional', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    UserSignUpDraft? submitted;
    setTestSurface(tester, const Size(390, 1000));
    await _pumpPage(
      tester,
      FoundingFriendPage(onSubmit: (draft) => submitted = draft),
    );

    await tester.enterText(
      find.byKey(const Key('firstNameField-foundingFriend')),
      'Taylor',
    );
    await tester.enterText(
      find.byKey(const Key('lastNameField-foundingFriend')),
      'Jones',
    );
    await tester.enterText(
      find.byKey(const Key('emailField-foundingFriend')),
      'taylor@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('ageField-foundingFriend')),
      '31',
    );
    await _tapSubmit(tester, 'foundingFriend');
    expect(find.text('Required field'), findsOneWidget);
    expect(submitted, isNull);

    final country = find.byKey(const Key('countryField-foundingFriend'));
    await tester.ensureVisible(country);
    await tester.tap(country);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Afghanistan').last);
    await tester.pumpAndSettle();

    final checkbox = find.byKey(
      const Key('marketingConsent-foundingFriend'),
    );
    expect(
      tester
          .getSemantics(checkbox)
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.isFalse,
    );
    await tester.ensureVisible(checkbox);
    tester
        .widget<Focus>(
          find.byKey(const Key('marketingConsentFocus-foundingFriend')),
        )
        .focusNode
        ?.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(
      tester
          .getSemantics(checkbox)
          .getSemanticsData()
          .flagsCollection
          .isChecked,
      CheckedState.isTrue,
    );

    await _tapSubmit(tester, 'foundingFriend');
    expect(submitted?.country, 'Afghanistan');
    expect(submitted?.marketingConsent, isTrue);
    expect(find.byType(UserSignUpSuccess), findsNothing);
    semantics.dispose();
  });

  testWidgets('only injected Here & Now success shows approved confirmation', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      const HereAndNowPage(showConfirmedSuccess: true),
    );
    expect(find.byType(UserSignUpSuccess), findsOneWidget);
    expect(
      find.text(
        'Thank you for signing up for Here & Now membership',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Fun App will be launching soon and we look forward to welcoming you '
        'as an early member',
      ),
      findsOneWidget,
    );
    expect(find.text('info@funapp.world'), findsWidgets);
    expect(find.text('THE FUN APP TEAM'), findsOneWidget);
    expect(
      find.byKey(const Key('hereAndNowSuccessEnvelope')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('userSignUpForm-hereAndNow')), findsNothing);

    await _pumpPage(tester, const FoundingFriendPage());
    expect(find.byType(UserSignUpSuccess), findsNothing);
    expect(
      find.byKey(const Key('userSignUpForm-foundingFriend')),
      findsOneWidget,
    );
  });

  testWidgets('mixed headings use the approved responsive emphasis', (
    tester,
  ) async {
    for (final width in const [390.0, 1440.0]) {
      setTestSurface(tester, Size(width, 1200));
      await _pumpPage(tester, const HereAndNowPage());

      final introduction = tester.widget<Text>(
        find.byKey(const Key('userSignUpHeading-hereAndNow')),
      );
      final introductionSpan = introduction.textSpan! as TextSpan;
      final introductionEmphasis =
          introductionSpan.children!.single as TextSpan;
      expect(introductionSpan.style?.fontSize, width == 390 ? 36 : 60);
      expect(introductionEmphasis.style?.fontStyle, FontStyle.italic);
      expect(introductionEmphasis.style?.color, AppColors.warmOrange);
      expect(
        tester
            .getSize(
              find.byKey(const Key('userSignUpIntroductionGroup-hereAndNow')),
            )
            .width,
        width == 390 ? 326 : 648,
      );

      await _pumpPage(
        tester,
        const HereAndNowPage(showConfirmedSuccess: true),
      );
      final success = tester.widget<Text>(
        find.byKey(const Key('hereAndNowSuccessHeading')),
      );
      final successSpan = success.textSpan! as TextSpan;
      final successEmphasis = successSpan.children!.single as TextSpan;
      expect(successSpan.style?.fontSize, width == 390 ? 36 : 60);
      expect(successEmphasis.style?.fontStyle, FontStyle.italic);
      expect(successEmphasis.style?.color, AppColors.warmOrange);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Here & Now success remains bounded with scaled text', (
    tester,
  ) async {
    for (final width in const [390.0, 1440.0]) {
      setTestSurface(tester, Size(width, 1200));
      await _pumpPage(
        tester,
        const HereAndNowPage(showConfirmedSuccess: true),
        textScaleFactor: 2,
      );

      final card = tester.getRect(
        find.byKey(const Key('userSignUpCard-hereAndNow')),
      );
      expect(card.left, greaterThanOrEqualTo(0));
      expect(card.right, lessThanOrEqualTo(width));
      expect(find.byType(UserSignUpSuccess), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('both forms remain bounded at required responsive widths', (
    tester,
  ) async {
    for (final locale in AppLocalizations.supportedLocales) {
      for (final width in const [320.0, 390.0, 599.0, 600.0, 768.0, 1440.0]) {
        for (final page in const <Widget>[
          HereAndNowPage(),
          FoundingFriendPage(),
        ]) {
          setTestSurface(tester, Size(width, 1200));
          await _pumpPage(
            tester,
            page,
            locale: locale,
            textScaleFactor: 2,
          );

          final semanticId = page is HereAndNowPage
              ? 'hereAndNow'
              : 'foundingFriend';
          final card = tester.getRect(
            find.byKey(Key('userSignUpCard-$semanticId')),
          );
          expect(card.left, greaterThanOrEqualTo(0));
          expect(card.right, lessThanOrEqualTo(width));
          if (width == 1440) {
            expect(
              find.byKey(Key('nameFieldsRow-$semanticId')),
              findsOneWidget,
            );
            expect(
              find.byKey(Key('contactFieldsRow-$semanticId')),
              findsOneWidget,
            );
            expect(
              find.byKey(Key('demographicFieldsRow-$semanticId')),
              findsOneWidget,
            );
          } else {
            expect(
              find.byKey(Key('nameFieldsColumn-$semanticId')),
              findsOneWidget,
            );
            expect(
              find.byKey(Key('contactFieldsColumn-$semanticId')),
              findsOneWidget,
            );
            expect(
              find.byKey(Key('demographicFieldsColumn-$semanticId')),
              findsOneWidget,
            );
          }
          expect(tester.takeException(), isNull);
        }
      }
    }
  });

  testWidgets('required and optional semantics are explicit', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpPage(tester, const FoundingFriendPage());

    expect(
      tester
          .getSemantics(
            find.byKey(const Key('firstNameField-foundingFriend')),
          )
          .getSemanticsData()
          .label,
      contains('First Name (required)'),
    );
    expect(
      tester
          .getSemantics(find.byKey(const Key('genderField-foundingFriend')))
          .getSemanticsData()
          .label,
      contains('Gender (optional)'),
    );
    expect(
      tester.getSize(
        find.byKey(const Key('marketingConsentVisual-foundingFriend')),
      ),
      const Size.square(20),
    );
    semantics.dispose();
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  Locale locale = const Locale('en'),
  double textScaleFactor = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      theme: appTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
        child: child!,
      ),
      home: page,
    ),
  );
  await tester.pump();
}

void _expectHint(WidgetTester tester, Key key, String expected) {
  expect(
    find.descendant(of: find.byKey(key), matching: find.text(expected)),
    findsOneWidget,
  );
}

Future<void> _tapSubmit(WidgetTester tester, String semanticId) async {
  final submit = find.byKey(Key('userSignUpSubmit-$semanticId'));
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit);
  await tester.pump();
}

void _expectOrdered(WidgetTester tester, List<Key> keys) {
  final positions = [
    for (final key in keys) tester.getTopLeft(find.byKey(key)).dy,
  ];
  for (var index = 1; index < positions.length; index++) {
    expect(positions[index], greaterThan(positions[index - 1]));
  }
}
