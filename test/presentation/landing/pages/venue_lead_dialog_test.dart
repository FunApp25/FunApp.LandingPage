import 'dart:async';
import 'dart:collection';
import 'dart:ui' show PointerDeviceKind, SemanticsAction, Tristate;

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';
import 'package:fun_app_landing_page/domain/venue/venue_lead_repository_interface.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_chain_status_control.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_dialog.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_privacy_disclosure.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_dialog.dart';
import 'package:fun_app_landing_page/presentation/privacy/pages/privacy_notice_page.dart';

import '../landing_test_helpers.dart';

void main() {
  late _ControlledVenueLeadRepository repository;

  setUp(() async {
    await getIt.reset();
    repository = _ControlledVenueLeadRepository();
  });

  tearDown(() async {
    repository.completeAllPending();
    await getIt.reset();
  });

  testWidgets('venue and Founding Friends CTAs open distinct flows', (
    tester,
  ) async {
    getIt.registerFactory<VenueLeadFormBloc>(
      () => VenueLeadFormBloc(repository),
    );
    await pumpLandingApp(tester);

    final context = tester.element(find.byType(LandingPage));
    final l10n = AppLocalizations.of(context);
    final foundingCta = find.byKey(const Key('foundingFriendsCta'));
    await tester.ensureVisible(foundingCta);
    await tester.tap(foundingCta);
    await tester.pumpAndSettle();

    expect(
      find.text(l10n.landingInterestedUserComingSoonTitle),
      findsOneWidget,
    );
    expect(find.byKey(const Key('venueLeadForm')), findsNothing);
    await tester.tap(find.byKey(const Key('landingDialogCloseButton')));
    await tester.pumpAndSettle();

    final venueCta = find.byKey(const Key('venueCardCta'));
    await tester.ensureVisible(venueCta);
    await tester.tap(venueCta);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('venueLeadForm')), findsOneWidget);
    expect(
      find.text(l10n.landingInterestedUserComingSoonTitle),
      findsNothing,
    );
    expect(find.byType(TextField), findsNWidgets(9));
    expect(
      find.byKey(const Key('venueLeadChainStatusControl')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsNothing);
    expect(repository.submittedLeads, isEmpty);
  });

  testWidgets('shows the exact disclosure at the end of the scrolling body', (
    tester,
  ) async {
    const approvedDisclosure =
        'By submitting this form, you acknowledge that Fun App will use the '
        'information you provide to respond to your enquiry. Please see Fun '
        "App's Privacy Notice for information about how it collects and "
        'processes personal data.';
    final semantics = tester.ensureSemantics();
    setTestSurface(tester, const Size(320, 568));
    await _pumpVenueDialog(tester, repository: repository);

    final disclosure = tester.widget<VenuePrivacyDisclosure>(
      find.byType(VenuePrivacyDisclosure),
    );
    expect(disclosure.statement, approvedDisclosure);
    expect(disclosure.privacyNoticeLabel, 'Privacy Notice');
    expect(
      tester
          .widget<RichText>(
            find.descendant(
              of: find.byType(VenuePrivacyDisclosure),
              matching: find.byType(RichText),
            ),
          )
          .text
          .toPlainText(),
      approvedDisclosure,
    );
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(find.byType(Radio<Object>), findsNothing);

    final submit = find.byKey(const Key('venueLeadSubmitButton'));
    await tester.ensureVisible(
      find.byKey(const Key('venuePrivacyDisclosure')),
    );
    await tester.pumpAndSettle();
    final phoneField = find.byKey(const Key('venueLeadPhoneNumberField'));
    final disclosureFinder = find.byKey(
      const Key('venuePrivacyDisclosure'),
    );
    expect(
      tester.getTopLeft(disclosureFinder).dy,
      greaterThan(tester.getBottomLeft(phoneField).dy),
    );
    expect(
      find.ancestor(
        of: disclosureFinder,
        matching: find.byKey(const Key('landingDialogScrollView')),
      ),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: submit,
        matching: find.byKey(const Key('landingDialogFooter')),
      ),
      findsOneWidget,
    );

    final privacyLink = find.semantics
        .byLabel('Privacy Notice')
        .evaluate()
        .single
        .getSemanticsData();
    expect(privacyLink.label, 'Privacy Notice');
    expect(privacyLink.flagsCollection.isLink, isTrue);
    expect(privacyLink.hasAction(SemanticsAction.tap), isTrue);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('Privacy Notice link follows the last field in keyboard order', (
    tester,
  ) async {
    await _pumpVenueDialog(tester, repository: repository);

    final phoneField = find.byKey(const Key('venueLeadPhoneNumberField'));
    await tester.ensureVisible(phoneField);
    await tester.tap(phoneField);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    expect(
      Focus.of(tester.element(find.byKey(const Key('venuePrivacyDisclosure'))))
          .hasFocus,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(LandingDialog), findsOneWidget);
  });

  testWidgets('venue Privacy Notice launches a tab and preserves draft', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final createdBlocs = <VenueLeadFormBloc>[];
    getIt.registerFactory<VenueLeadFormBloc>(() {
      final bloc = VenueLeadFormBloc(repository);
      createdBlocs.add(bloc);
      return bloc;
    });
    final launched = <Uri>[];
    await pumpLandingApp(tester, onPrivacyNoticeLaunch: launched.add);

    final venueCta = find.byKey(const Key('venueCardCta'));
    await tester.ensureVisible(venueCta);
    await tester.tap(venueCta);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('venueLeadVenueNameField')),
      'Unsaved Venue Draft',
    );
    await tester.ensureVisible(
      find.byKey(const Key('venueLeadSubmitButton')),
    );
    await tester.pump();
    tester.semantics.tap(find.semantics.byLabel('Privacy Notice'));
    await tester.pump();

    expect(find.byType(LandingDialog), findsOneWidget);
    expect(find.byType(PrivacyNoticePage), findsNothing);
    expect(createdBlocs, hasLength(1));
    expect(createdBlocs.single.isClosed, isFalse);
    expect(launched, hasLength(1));
    expect(launched.single.fragment, '/privacy');
    expect(launched.single.path, '/');
    expect(
      tester
          .widget<TextField>(
            find.byKey(const Key('venueLeadVenueNameField')),
          )
          .controller
          ?.text,
      'Unsaved Venue Draft',
    );
    expect(repository.submittedLeads, isEmpty);
    semantics.dispose();
  });

  testWidgets('renders the established fields with optional chain choices', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpVenueDialog(tester, repository: repository);
    final l10n = _l10n(tester);

    final expectedLabels = [
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadVenueNameLabel),
      l10n.venueLeadOptionalFieldLabel(l10n.venueLeadVenueTypeLabel),
      l10n.venueLeadOptionalFieldLabel(l10n.venueLeadChainStatusLabel),
      l10n.venueLeadOptionalFieldLabel(l10n.venueLeadVenueCapacityLabel),
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadWebsiteLabel),
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadFirstNameLabel),
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadLastNameLabel),
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadRoleLabel),
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadEmailLabel),
      l10n.venueLeadOptionalFieldLabel(l10n.venueLeadPhoneNumberLabel),
    ];

    expect(find.byType(TextField), findsNWidgets(9));
    for (final label in expectedLabels) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.bySemanticsLabel(expectedLabels.first), findsOneWidget);
    expect(find.byType(DropdownButton<Object>), findsNothing);
    expect(find.byType(DropdownMenu<Object>), findsNothing);
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsNothing);
    expect(
      find.byKey(const Key('venueChainIndependentOption')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('venueChainPartOfChainOption')),
      findsOneWidget,
    );

    final closeSemantics = tester
        .getSemantics(find.byKey(const Key('landingDialogCloseButton')))
        .getSemanticsData();
    expect(closeSemantics.label, l10n.landingDialogClose);
    expect(closeSemantics.flagsCollection.isButton, isTrue);
    semantics.dispose();
  });

  testWidgets('uses BLoC validation and does not submit invalid input', (
    tester,
  ) async {
    setTestSurface(tester, const Size(320, 568));
    await _pumpVenueDialog(tester, repository: repository);
    final l10n = _l10n(tester);

    await _tapSubmit(tester);
    expect(find.text(l10n.venueLeadValidationRequired), findsNWidgets(6));
    expect(repository.submittedLeads, isEmpty);

    await tester.enterText(
      find.byKey(const Key('venueLeadWebsiteField')),
      'not-a-web-address',
    );
    await tester.enterText(
      find.byKey(const Key('venueLeadEmailField')),
      '.contact@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('venueLeadVenueCapacityField')),
      '0',
    );
    await tester.enterText(
      find.byKey(const Key('venueLeadPhoneNumberField')),
      '+44000000000',
    );
    await tester.pump();

    expect(find.text(l10n.venueLeadValidationWebsite), findsOneWidget);
    expect(find.text(l10n.venueLeadValidationEmail), findsOneWidget);
    expect(find.text(l10n.venueLeadValidationNumbersOnly), findsOneWidget);
    expect(find.text(l10n.venueLeadValidationPositiveInteger), findsOneWidget);
    expect(repository.submittedLeads, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chain choices stay optional and clear hidden venue count', (
    tester,
  ) async {
    late VenueLeadFormBloc bloc;
    await _pumpVenueDialog(
      tester,
      repository: repository,
      onBlocCreated: (created) => bloc = created,
    );
    final l10n = _l10n(tester);
    expect(bloc.state.lead.chainStatus.isNone(), isTrue);
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsNothing);
    expect(
      tester
          .getSemantics(find.byKey(const Key('venueChainIndependentOption')))
          .getSemanticsData()
          .flagsCollection
          .isSelected,
      Tristate.isFalse,
    );

    final chain = find.byKey(const Key('venueChainPartOfChainOption'));
    await tester.ensureVisible(chain);
    await tester.tap(chain);
    await tester.pumpAndSettle();
    expect(
      bloc.state.lead.chainStatus.toNullable()?.getOrCrash(),
      VenueChainStatusControl.chainValue,
    );
    expect(
      tester.getSemantics(chain).getSemanticsData().flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsOneWidget);
    expect(
      find.text(
        l10n.venueLeadOptionalFieldLabel(l10n.venueLeadVenueCountLabel),
      ),
      findsOneWidget,
    );
    expect(l10n.venueLeadVenueCountLabel, 'Number of venues');
    await tester.enterText(
      find.byKey(const Key('venueLeadVenueCountField')),
      '12',
    );
    await tester.pump();
    expect(bloc.state.lead.venueCount.toNullable()?.getOrCrash(), 12);

    final independent = find.byKey(const Key('venueChainIndependentOption'));
    await tester.ensureVisible(independent);
    await tester.tap(independent);
    await tester.pumpAndSettle();
    expect(
      bloc.state.lead.chainStatus.toNullable()?.getOrCrash(),
      VenueChainStatusControl.independentValue,
    );
    expect(bloc.state.lead.venueCount.isNone(), isTrue);
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsNothing);

    await _fillRequiredFields(tester);
    await _tapSubmit(tester);
    expect(repository.submittedLeads, hasLength(1));
    expect(repository.submittedLeads.single.venueCount.isNone(), isTrue);
  });

  testWidgets('venue count animates in and out and loses focus when hidden', (
    tester,
  ) async {
    await _pumpVenueDialog(tester, repository: repository);
    final animation = find.byKey(const Key('venueLeadVenueCountAnimation'));
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsNothing);
    expect(
      tester.widget<AnimatedSize>(animation).duration,
      isNot(Duration.zero),
    );

    await tester.ensureVisible(
      find.byKey(const Key('venueChainPartOfChainOption')),
    );
    await tester.tap(find.byKey(const Key('venueChainPartOfChainOption')));
    await tester.pump();
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsOneWidget);
    await tester.pumpAndSettle();
    final count = find.byKey(const Key('venueLeadVenueCountField'));
    await tester.ensureVisible(count);
    await tester.tap(count);
    expect(tester.widget<TextField>(count).focusNode?.hasFocus, isTrue);

    await tester.ensureVisible(
      find.byKey(const Key('venueChainIndependentOption')),
    );
    await tester.tap(find.byKey(const Key('venueChainIndependentOption')));
    await tester.pumpAndSettle();
    expect(count, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('venue count visibility works with animations disabled', (
    tester,
  ) async {
    await _pumpVenueDialog(
      tester,
      repository: repository,
      disableAnimations: true,
    );
    final animation = find.byKey(const Key('venueLeadVenueCountAnimation'));
    expect(animation, findsNothing);
    await tester.ensureVisible(
      find.byKey(const Key('venueChainPartOfChainOption')),
    );
    await tester.tap(find.byKey(const Key('venueChainPartOfChainOption')));
    await tester.pump();
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('venueChainIndependentOption')),
    );
    await tester.tap(find.byKey(const Key('venueChainIndependentOption')));
    await tester.pump();
    expect(find.byKey(const Key('venueLeadVenueCountField')), findsNothing);
  });

  testWidgets('chain control supports keyboard activation and reduced motion', (
    tester,
  ) async {
    var selected = '';
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: VenueChainStatusControl(
              label: 'Chain status',
              independentLabel: 'Independent',
              chainLabel: 'Part of chain',
              selectedValue: null,
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(selected, VenueChainStatusControl.independentValue);
    final option = find.descendant(
      of: find.byKey(const Key('venueChainIndependentOption')),
      matching: find.byType(AnimatedContainer),
    );
    expect(tester.widget<AnimatedContainer>(option).duration, Duration.zero);
  });

  testWidgets('venue grouping and fields reuse rounded Fun App tokens', (
    tester,
  ) async {
    await _pumpVenueDialog(tester, repository: repository);
    final group = tester.widget<Container>(
      find.byKey(const Key('venueLeadVenueDetailsGroup')),
    );
    final groupDecoration = group.decoration! as BoxDecoration;
    expect(groupDecoration.color, AppColors.beigeAccent);
    expect(
      groupDecoration.borderRadius,
      BorderRadius.circular(AppSizes.cardRadius),
    );
    final field = tester.widget<TextField>(
      find.byKey(const Key('venueLeadVenueNameField')),
    );
    final border = field.decoration!.border! as OutlineInputBorder;
    expect(border.borderRadius, BorderRadius.circular(AppSizes.cardRadius));
    expect(field.decoration!.filled, isTrue);
    expect(field.decoration!.fillColor, AppColors.lightForeground);
  });

  testWidgets('validation feedback remains red through hover and focus', (
    tester,
  ) async {
    await _pumpVenueDialog(tester, repository: repository);
    await _tapSubmit(tester);
    final field = find.byKey(const Key('venueLeadVenueNameField'));
    final error = find.descendant(
      of: field,
      matching: find.text(_l10n(tester).venueLeadValidationRequired),
    );
    expect(error, findsOneWidget);
    expect(tester.widget<Text>(error).style?.color, AppColors.cherryRed);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(field));
    await tester.pump();
    expect(tester.widget<Text>(error).style?.color, AppColors.cherryRed);
    await tester.tap(field);
    await tester.pump();
    expect(tester.widget<Text>(error).style?.color, AppColors.cherryRed);
    final decoration = tester.widget<TextField>(field).decoration!;
    expect(decoration.labelStyle?.color, AppColors.cherryRed);
    expect(decoration.floatingLabelStyle?.color, AppColors.cherryRed);
    expect(
      decoration.focusedErrorBorder?.borderSide.color,
      AppColors.cherryRed,
    );
    await mouse.removePointer();
  });

  testWidgets('quantity inputs reject non-digits and retain valid digits', (
    tester,
  ) async {
    late VenueLeadFormBloc bloc;
    await _pumpVenueDialog(
      tester,
      repository: repository,
      onBlocCreated: (created) => bloc = created,
    );
    final chain = find.byKey(const Key('venueChainPartOfChainOption'));
    await tester.ensureVisible(chain);
    await tester.tap(chain);
    await tester.pumpAndSettle();
    for (final key in const [
      Key('venueLeadVenueCountField'),
      Key('venueLeadVenueCapacityField'),
    ]) {
      await tester.enterText(find.byKey(key), 'a1.2- 3');
      await tester.pump();
      expect(tester.widget<TextField>(find.byKey(key)).controller?.text, '123');
      expect(
        tester.widget<TextField>(find.byKey(key)).keyboardType,
        TextInputType.number,
      );
    }
    expect(bloc.state.lead.venueCount.toNullable()?.getOrCrash(), 123);
    expect(bloc.state.lead.venueCapacity.toNullable()?.getOrCrash(), 123);
  });

  testWidgets(
    'submission blocks duplicates and dismissal, then shows success and resets',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final createdBlocs = <VenueLeadFormBloc>[];
      var privacyLaunches = 0;
      await _pumpVenueDialog(
        tester,
        repository: repository,
        onBlocCreated: createdBlocs.add,
        onPrivacyNoticeSelected: () => privacyLaunches++,
      );
      await _fillRequiredFields(tester);
      expect(
        find.byKey(const Key('landingDialogBottomFade')),
        findsOneWidget,
      );

      await _tapSubmit(tester);

      expect(repository.submittedLeads, hasLength(1));
      final submitButton = tester.widget<FilledButton>(
        find.byKey(const Key('venueLeadSubmitButton')),
      );
      expect(submitButton.onPressed, isNull);
      final buttonContext = tester.element(
        find.byKey(const Key('venueLeadSubmitButton')),
      );
      final buttonStyle = submitButton.defaultStyleOf(buttonContext);
      expect(
        buttonStyle.backgroundColor?.resolve({WidgetState.disabled}),
        isNot(buttonStyle.backgroundColor?.resolve({WidgetState.hovered})),
      );
      expect(
        find.byKey(const Key('venueLeadSubmissionProgress')),
        findsOneWidget,
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(
        find.byKey(const Key('landingDialogBottomFade')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        isNull,
      );
      expect(
        tester
            .getSemantics(find.byKey(const Key('venueLeadSubmissionProgress')))
            .getSemanticsData()
            .label,
        contains(_l10n(tester).venueLeadSubmitting),
      );
      expect(find.text(_l10n(tester).venueLeadSubmit), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        tester
            .widget<PopScope<void>>(
              find.byKey(const Key('venueLeadDialogPopScope')),
            )
            .canPop,
        isFalse,
      );
      final closeButton = tester.widget<IconButton>(
        find.descendant(
          of: find.byKey(const Key('landingDialogCloseButton')),
          matching: find.byType(IconButton),
        ),
      );
      expect(closeButton.onPressed, isNull);
      final privacyDisclosure = tester.widget<VenuePrivacyDisclosure>(
        find.byType(VenuePrivacyDisclosure),
      );
      expect(privacyDisclosure.onPrivacyNoticeSelected, isNotNull);
      final pendingPrivacyLinks = find.semantics.byLabel('Privacy Notice');
      if (pendingPrivacyLinks.evaluate().isNotEmpty) {
        expect(
          pendingPrivacyLinks.evaluate().single.getSemanticsData().hasAction(
            SemanticsAction.tap,
          ),
          isTrue,
        );
      }
      await tester.ensureVisible(find.byType(VenuePrivacyDisclosure));
      tester.semantics.tap(find.semantics.byLabel('Privacy Notice'));
      await tester.pump();
      expect(privacyLaunches, 1);
      expect(find.byType(LandingDialog), findsOneWidget);
      expect(repository.submittedLeads, hasLength(1));

      await tester.tap(find.byKey(const Key('venueLeadSubmitButton')));
      await tester.tapAt(const Offset(1, 1));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(repository.submittedLeads, hasLength(1));
      expect(find.byType(LandingDialog), findsOneWidget);
      expect(find.byType(PrivacyNoticePage), findsNothing);

      repository.completeNext(right(unit));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('venueLeadSuccess')), findsOneWidget);
      expect(find.byKey(const Key('landingDialogTopFade')), findsNothing);
      expect(find.byKey(const Key('landingDialogBottomFade')), findsNothing);
      expect(find.text(_l10n(tester).venueLeadSuccessTitle), findsOneWidget);
      expect(find.text(_l10n(tester).venueLeadSuccessBody), findsOneWidget);
      expect(find.text(_l10n(tester).venueLeadSuccessSignOff), findsOneWidget);
      expect(
        tester
            .getSemantics(find.byKey(const Key('venueLeadSuccessTitle')))
            .getSemanticsData()
            .flagsCollection
            .isHeader,
        isTrue,
      );
      expect(find.byKey(const Key('venueLeadSubmitButton')), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byKey(const Key('venueLeadSubmissionFailure')), findsNothing);
      expect(
        tester.getTopLeft(find.byKey(const Key('venueLeadSuccessTitle'))).dy,
        greaterThan(
          tester
                  .getTopLeft(find.byKey(const Key('landingDialogScrollView')))
                  .dy +
              24,
        ),
      );
      expect(
        find.byKey(const Key('venueLeadSuccessCloseButton')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<PopScope<void>>(
              find.byKey(const Key('venueLeadDialogPopScope')),
            )
            .canPop,
        isTrue,
      );
      expect(repository.submittedLeads.single.venueType.isNone(), isTrue);
      expect(repository.submittedLeads.single.chainStatus.isNone(), isTrue);
      expect(repository.submittedLeads.single.venueCount.isNone(), isTrue);
      expect(repository.submittedLeads.single.venueCapacity.isNone(), isTrue);
      expect(repository.submittedLeads.single.phoneNumber.isNone(), isTrue);

      await tester.tap(find.byKey(const Key('venueLeadSuccessCloseButton')));
      await tester.pumpAndSettle();
      expect(createdBlocs.single.isClosed, isTrue);

      await tester.tap(find.byKey(const Key('openVenueLeadDialog')));
      await tester.pumpAndSettle();
      expect(createdBlocs, hasLength(2));
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('venueLeadVenueNameField')),
            )
            .controller
            ?.text,
        isEmpty,
      );
      await tester.tap(find.byKey(const Key('landingDialogCloseButton')));
      await tester.pumpAndSettle();
      expect(createdBlocs.last.isClosed, isTrue);
      semantics.dispose();
    },
  );

  testWidgets('failure preserves the draft and retry can succeed', (
    tester,
  ) async {
    await _pumpVenueDialog(tester, repository: repository);
    await _fillRequiredFields(tester);

    await _tapSubmit(tester);
    repository.completeNext(left(const AppFailure.serviceUnavailable()));
    await tester.pumpAndSettle();

    final l10n = _l10n(tester);
    expect(
      find.text(l10n.venueLeadSubmissionFailure),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const Key('landingDialogBottomFade')), findsOneWidget);
    expect(
      tester
          .getBottomLeft(find.byKey(const Key('venueLeadSubmissionFailure')))
          .dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('venueLeadSubmitButton'))).dy,
      ),
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('venueLeadVenueNameField')))
          .controller
          ?.text,
      'Test Venue',
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('venueLeadSubmitButton')))
          .onPressed,
      isNotNull,
    );

    await _tapSubmit(tester);
    expect(repository.submittedLeads, hasLength(2));
    repository.completeNext(right(unit));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('venueLeadSuccess')), findsOneWidget);
  });

  testWidgets('editing during submission discards stale success in the UI', (
    tester,
  ) async {
    await _pumpVenueDialog(tester, repository: repository);
    await _fillRequiredFields(tester);

    await _tapSubmit(tester);
    await tester.enterText(
      find.byKey(const Key('venueLeadVenueNameField')),
      'Edited Venue',
    );
    await tester.pump();
    repository.completeNext(right(unit));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('venueLeadSuccess')), findsNothing);
    expect(find.byKey(const Key('venueLeadForm')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('venueLeadVenueNameField')))
          .controller
          ?.text,
      'Edited Venue',
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('venueLeadSubmitButton')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets(
    'scheme-less website can pass presentation validation unchanged',
    (
      tester,
    ) async {
      await _pumpVenueDialog(tester, repository: repository);
      await _fillRequiredFields(tester, website: 'test.com');
      await _tapSubmit(tester);
      expect(repository.submittedLeads, hasLength(1));
      expect(repository.submittedLeads.single.website.getOrCrash(), 'test.com');
      expect(find.text(_l10n(tester).venueLeadValidationWebsite), findsNothing);
    },
  );

  testWidgets('editing during submission discards stale failure in the UI', (
    tester,
  ) async {
    await _pumpVenueDialog(tester, repository: repository);
    await _fillRequiredFields(tester);

    await _tapSubmit(tester);
    await tester.enterText(
      find.byKey(const Key('venueLeadVenueNameField')),
      'Edited Venue',
    );
    await tester.pump();
    repository.completeNext(left(const AppFailure.submissionRejected()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('venueLeadSubmissionFailure')), findsNothing);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('venueLeadVenueNameField')))
          .controller
          ?.text,
      'Edited Venue',
    );
    await _tapSubmit(tester);
    expect(repository.submittedLeads, hasLength(2));
    repository.completeNext(right(unit));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('venueLeadSuccess')), findsOneWidget);
  });

  for (final failure in const [
    AppFailure.submissionRejected(),
    AppFailure.unexpected(),
  ]) {
    testWidgets('$failure shows a retryable message without losing the draft', (
      tester,
    ) async {
      await _pumpVenueDialog(tester, repository: repository);
      await _fillRequiredFields(tester);

      await _tapSubmit(tester);
      repository.completeNext(left(failure));
      await tester.pumpAndSettle();

      expect(
        find.text(_l10n(tester).venueLeadSubmissionFailure),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('venueLeadVenueNameField')))
            .controller
            ?.text,
        'Test Venue',
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('venueLeadSubmitButton')),
            )
            .onPressed,
        isNotNull,
      );
    });
  }

  testWidgets('venue form stays bounded and scrollable across viewports', (
    tester,
  ) async {
    for (final size in const [
      Size(320, 568),
      Size(390, 844),
      Size(768, 768),
      Size(1440, 900),
      Size(320, 300),
    ]) {
      setTestSurface(tester, size);
      await _pumpVenueDialog(tester, repository: repository);

      final dialogRect = tester.getRect(
        find.byKey(const Key('landingDialogSurface')),
      );
      expect(dialogRect.left, greaterThanOrEqualTo(16));
      expect(dialogRect.right, lessThanOrEqualTo(size.width - 16));
      expect(dialogRect.top, greaterThanOrEqualTo(0));
      expect(dialogRect.bottom, lessThanOrEqualTo(size.height));
      expect(find.byKey(const Key('landingDialogScrollView')), findsOneWidget);

      final submit = find.byKey(const Key('venueLeadSubmitButton'));
      expect(
        submit,
        findsOneWidget,
      );
      expect(tester.getRect(submit).bottom, lessThan(dialogRect.bottom));
      await tester.drag(
        find.byKey(const Key('landingDialogScrollView')),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(submit).bottom, lessThan(dialogRect.bottom));
      await tester.drag(
        find.byKey(const Key('landingDialogScrollView')),
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(submit).bottom, lessThan(dialogRect.bottom));
      expect(
        tester.takeException(),
        isNull,
        reason: 'Expected no overflow at $size.',
      );

      await tester.tap(find.byKey(const Key('landingDialogCloseButton')));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('venue dialog scrolls at two times text scale and short height', (
    tester,
  ) async {
    setTestSurface(tester, const Size(320, 300));
    tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );
    await _pumpVenueDialog(tester, repository: repository);

    final submit = find.byKey(const Key('venueLeadSubmitButton'));
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    expect(tester.getRect(submit).right, lessThanOrEqualTo(320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('success spacing and Close remain usable across viewports', (
    tester,
  ) async {
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );
    for (final size in const [
      Size(320, 568),
      Size(390, 844),
      Size(1440, 900),
      Size(320, 300),
    ]) {
      setTestSurface(tester, size);
      if (size.height == 300) {
        tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
      } else {
        tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
      }
      await _pumpVenueDialog(tester, repository: repository);
      await _fillRequiredFields(tester);
      await _tapSubmit(tester);
      repository.completeNext(right(unit));
      await tester.pumpAndSettle();

      final body = tester.getRect(
        find.byKey(const Key('landingDialogScrollView')),
      );
      final title = tester.getRect(
        find.byKey(const Key('venueLeadSuccessTitle')),
      );
      final close = tester.getRect(
        find.byKey(const Key('venueLeadSuccessCloseButton')),
      );
      final dialog = tester.getRect(
        find.byKey(const Key('landingDialogSurface')),
      );
      expect(title.top, greaterThanOrEqualTo(body.top + 24));
      expect(close.bottom, lessThan(dialog.bottom));
      expect(find.byKey(const Key('landingDialogTopFade')), findsNothing);
      await tester.ensureVisible(
        find.text(_l10n(tester).venueLeadSuccessSignOff),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Expected no overflow at $size.',
      );
      await tester.tap(find.byKey(const Key('venueLeadSuccessCloseButton')));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('failure footer wraps at two times text scale and short height', (
    tester,
  ) async {
    setTestSurface(tester, const Size(320, 300));
    tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );
    await _pumpVenueDialog(tester, repository: repository);
    await _fillRequiredFields(tester);
    await _tapSubmit(tester);
    repository.completeNext(left(const AppFailure.serviceUnavailable()));
    await tester.pumpAndSettle();

    final dialog = tester.getRect(
      find.byKey(const Key('landingDialogSurface')),
    );
    final submit = tester.getRect(
      find.byKey(const Key('venueLeadSubmitButton')),
    );
    final failureScroll = tester.getRect(
      find.descendant(
        of: find.byKey(const Key('venueLeadActionFooter')),
        matching: find.byType(SingleChildScrollView),
      ),
    );
    expect(find.byKey(const Key('venueLeadSubmissionFailure')), findsOneWidget);
    expect(failureScroll.bottom, lessThan(submit.top));
    expect(submit.bottom, lessThan(dialog.bottom));
    expect(failureScroll.left, greaterThanOrEqualTo(dialog.left));
    expect(failureScroll.right, lessThanOrEqualTo(dialog.right));
    expect(tester.takeException(), isNull);
  });

  test('uses one provider-neutral operational failure message', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(
      l10n.venueLeadSubmissionFailure.toLowerCase(),
      isNot(contains('hubspot')),
    );
    expect(
      l10n.venueLeadSubmissionFailure.toLowerCase(),
      isNot(contains('http')),
    );
  });
}

Future<void> _pumpVenueDialog(
  WidgetTester tester, {
  required _ControlledVenueLeadRepository repository,
  ValueChanged<VenueLeadFormBloc>? onBlocCreated,
  VoidCallback? onPrivacyNoticeSelected,
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: disableAnimations,
        ),
        child: child!,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            key: const Key('openVenueLeadDialog'),
            onPressed: () => showVenueLeadDialog(
              context,
              onPrivacyNoticeSelected: onPrivacyNoticeSelected ?? () {},
              createBloc: () {
                final bloc = VenueLeadFormBloc(repository);
                onBlocCreated?.call(bloc);
                return bloc;
              },
            ),
            child: const Text('Open venue dialog'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const Key('openVenueLeadDialog')));
  await tester.pumpAndSettle();
}

AppLocalizations _l10n(WidgetTester tester) => AppLocalizations.of(
  tester.element(find.byType(VenueLeadDialog)),
);

Future<void> _fillRequiredFields(
  WidgetTester tester, {
  String website = 'https://venue.example.com',
}) async {
  for (final entry in <(Key, String)>[
    (const Key('venueLeadVenueNameField'), 'Test Venue'),
    (const Key('venueLeadWebsiteField'), website),
    (const Key('venueLeadFirstNameField'), 'Test'),
    (const Key('venueLeadLastNameField'), 'Person'),
    (const Key('venueLeadRoleField'), 'Manager'),
    (const Key('venueLeadEmailField'), 'test@venue.example.com'),
  ]) {
    await tester.enterText(find.byKey(entry.$1), entry.$2);
  }
  await tester.pump();
}

Future<void> _tapSubmit(WidgetTester tester) async {
  final submit = find.byKey(const Key('venueLeadSubmitButton'));
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit);
  await tester.pump();
}

final class _ControlledVenueLeadRepository
    implements VenueLeadRepositoryInterface {
  final submittedLeads = <VenueLead>[];
  final _pendingResults = Queue<Completer<Either<AppFailure, Unit>>>();

  @override
  Future<Either<AppFailure, Unit>> submitVenueLead(VenueLead lead) {
    submittedLeads.add(lead);
    final completer = Completer<Either<AppFailure, Unit>>();
    _pendingResults.add(completer);
    return completer.future;
  }

  void completeNext(Either<AppFailure, Unit> result) {
    _pendingResults.removeFirst().complete(result);
  }

  void completeAllPending() {
    while (_pendingResults.isNotEmpty) {
      completeNext(right(unit));
    }
  }
}
