import 'dart:async';
import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';
import 'package:fun_app_landing_page/domain/venue/venue_lead_repository_interface.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_dialog.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_lead_form_messages.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_dialog.dart';

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
    expect(find.byType(TextField), findsNWidgets(11));
    expect(repository.submittedLeads, isEmpty);
  });

  testWidgets('renders the approved free-text field contract and semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpVenueDialog(tester, repository: repository);
    final l10n = _l10n(tester);

    final expectedLabels = [
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadVenueNameLabel),
      l10n.venueLeadOptionalFieldLabel(l10n.venueLeadVenueTypeLabel),
      l10n.venueLeadOptionalFieldLabel(l10n.venueLeadChainStatusLabel),
      l10n.venueLeadOptionalFieldLabel(l10n.venueLeadVenueCountLabel),
      l10n.venueLeadOptionalFieldLabel(l10n.venueLeadVenueCapacityLabel),
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadWebsiteLabel),
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadFirstNameLabel),
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadLastNameLabel),
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadRoleLabel),
      l10n.venueLeadRequiredFieldLabel(l10n.venueLeadEmailLabel),
      l10n.venueLeadOptionalFieldLabel(l10n.venueLeadPhoneNumberLabel),
    ];

    expect(find.byType(TextField), findsNWidgets(11));
    for (final label in expectedLabels) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.bySemanticsLabel(expectedLabels.first), findsOneWidget);
    expect(find.byType(DropdownButton<Object>), findsNothing);
    expect(find.byType(DropdownMenu<Object>), findsNothing);

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
      find.byKey(const Key('venueLeadVenueCountField')),
      'many',
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
    expect(find.text(l10n.venueLeadValidationNumbersOnly), findsNWidgets(2));
    expect(find.text(l10n.venueLeadValidationPositiveInteger), findsOneWidget);
    expect(repository.submittedLeads, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'submission blocks duplicates and dismissal, then shows success and resets',
    (tester) async {
      final createdBlocs = <VenueLeadFormBloc>[];
      await _pumpVenueDialog(
        tester,
        repository: repository,
        onBlocCreated: createdBlocs.add,
      );
      await _fillRequiredFields(tester);

      await _tapSubmit(tester);

      expect(repository.submittedLeads, hasLength(1));
      final submitButton = tester.widget<FilledButton>(
        find.byKey(const Key('venueLeadSubmitButton')),
      );
      expect(submitButton.onPressed, isNull);
      expect(
        find.byKey(const Key('venueLeadSubmissionProgress')),
        findsOneWidget,
      );
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

      await tester.tap(find.byKey(const Key('venueLeadSubmitButton')));
      await tester.tapAt(const Offset(1, 1));
      await tester.pump();
      expect(repository.submittedLeads, hasLength(1));
      expect(find.byType(LandingDialog), findsOneWidget);

      repository.completeNext(right(unit));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('venueLeadSuccess')), findsOneWidget);
      expect(find.text(_l10n(tester).venueLeadSuccessTitle), findsOneWidget);
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
      find.text(l10n.venueLeadSubmissionServiceUnavailable),
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

  testWidgets('venue form stays bounded and scrollable across viewports', (
    tester,
  ) async {
    for (final size in const [
      Size(320, 568),
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

      await tester.ensureVisible(
        find.byKey(const Key('venueLeadSubmitButton')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('venueLeadSubmitButton')),
        findsOneWidget,
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'Expected no overflow at $size.',
      );

      await tester.tap(find.byKey(const Key('landingDialogCloseButton')));
      await tester.pumpAndSettle();
    }
  });

  test('maps every operational failure without provider terminology', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(
      venueLeadSubmissionFailureMessage(
        l10n,
        const AppFailure.serviceUnavailable(),
      ),
      l10n.venueLeadSubmissionServiceUnavailable,
    );
    expect(
      venueLeadSubmissionFailureMessage(
        l10n,
        const AppFailure.submissionRejected(),
      ),
      l10n.venueLeadSubmissionRejected,
    );
    expect(
      venueLeadSubmissionFailureMessage(
        l10n,
        const AppFailure.unexpected(),
      ),
      l10n.venueLeadSubmissionUnexpected,
    );
    for (final message in [
      l10n.venueLeadSubmissionServiceUnavailable,
      l10n.venueLeadSubmissionRejected,
      l10n.venueLeadSubmissionUnexpected,
    ]) {
      expect(message.toLowerCase(), isNot(contains('hubspot')));
      expect(message.toLowerCase(), isNot(contains('http')));
    }
  });
}

Future<void> _pumpVenueDialog(
  WidgetTester tester, {
  required _ControlledVenueLeadRepository repository,
  ValueChanged<VenueLeadFormBloc>? onBlocCreated,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            key: const Key('openVenueLeadDialog'),
            onPressed: () => showVenueLeadDialog(
              context,
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

Future<void> _fillRequiredFields(WidgetTester tester) async {
  for (final entry in const <(Key, String)>[
    (Key('venueLeadVenueNameField'), 'Test Venue'),
    (Key('venueLeadWebsiteField'), 'https://venue.example.com'),
    (Key('venueLeadFirstNameField'), 'Test'),
    (Key('venueLeadLastNameField'), 'Person'),
    (Key('venueLeadRoleField'), 'Manager'),
    (Key('venueLeadEmailField'), 'test@venue.example.com'),
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
