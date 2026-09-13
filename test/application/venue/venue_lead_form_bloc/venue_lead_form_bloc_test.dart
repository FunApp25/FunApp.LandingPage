import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/phone_number.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/positive_integer.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/website.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';
import 'package:fun_app_landing_page/domain/venue/venue_lead_repository_interface.dart';

void main() {
  late _FakeVenueLeadRepository repository;

  setUp(() {
    repository = _FakeVenueLeadRepository();
  });

  VenueLeadFormBloc buildBloc() => VenueLeadFormBloc(repository);

  test('initial state contains an incomplete typed draft', () {
    final bloc = buildBloc();
    addTearDown(bloc.close);

    expect(bloc.state.lead, VenueLead.empty());
    expect(bloc.state.lead.isValid, isFalse);
    expect(bloc.state.lead.venueType, none<NonEmptySingleLineText>());
    expect(
      bloc.state.lead.chainStatus,
      none<NonEmptySingleLineText>(),
    );
    expect(bloc.state.lead.venueCount, none<PositiveInteger>());
    expect(bloc.state.lead.venueCapacity, none<PositiveInteger>());
    expect(bloc.state.lead.phoneNumber, none<PhoneNumber>());
    expect(bloc.state.hasAttemptedSubmit, isFalse);
    expect(bloc.state.isSubmitting, isFalse);
    expect(
      bloc.state.submissionResult,
      none<Either<AppFailure, Unit>>(),
    );
  });

  final populatedLead = _validLeadWithOptionals();
  final changeSeed = _state(
    lead: populatedLead,
    hasAttemptedSubmit: true,
    submissionResult: some(right(unit)),
  );
  final fieldChanges = <_FieldChange>[
    _FieldChange(
      'venue name',
      const VenueLeadFormEvent.venueNameChanged('  New Venue  '),
      populatedLead.copyWith(
        venueName: NonEmptySingleLineText('  New Venue  '),
      ),
    ),
    _FieldChange(
      'venue type',
      const VenueLeadFormEvent.venueTypeChanged('  Arts centre  '),
      populatedLead.copyWith(
        venueType: some(NonEmptySingleLineText('  Arts centre  ')),
      ),
    ),
    _FieldChange(
      'chain status',
      const VenueLeadFormEvent.chainStatusChanged('  Independent  '),
      populatedLead.copyWith(
        chainStatus: some(NonEmptySingleLineText('  Independent  ')),
      ),
    ),
    _FieldChange(
      'venue count',
      const VenueLeadFormEvent.venueCountChanged('7'),
      populatedLead.copyWith(venueCount: some(PositiveInteger('7'))),
    ),
    _FieldChange(
      'venue capacity',
      const VenueLeadFormEvent.venueCapacityChanged('900'),
      populatedLead.copyWith(venueCapacity: some(PositiveInteger('900'))),
    ),
    _FieldChange(
      'website',
      const VenueLeadFormEvent.websiteChanged('https://new.example.com'),
      populatedLead.copyWith(website: Website('https://new.example.com')),
    ),
    _FieldChange(
      'first name',
      const VenueLeadFormEvent.firstNameChanged('  Taylor  '),
      populatedLead.copyWith(firstName: PersonalName('  Taylor  ')),
    ),
    _FieldChange(
      'last name',
      const VenueLeadFormEvent.lastNameChanged('Jordan'),
      populatedLead.copyWith(lastName: PersonalName('Jordan')),
    ),
    _FieldChange(
      'role',
      const VenueLeadFormEvent.roleChanged('Owner'),
      populatedLead.copyWith(role: NonEmptySingleLineText('Owner')),
    ),
    _FieldChange(
      'email',
      const VenueLeadFormEvent.emailChanged('Contact@new.example.com'),
      populatedLead.copyWith(email: EmailAddress('Contact@new.example.com')),
    ),
    _FieldChange(
      'phone number',
      const VenueLeadFormEvent.phoneNumberChanged('0011223344'),
      populatedLead.copyWith(phoneNumber: some(PhoneNumber('0011223344'))),
    ),
  ];

  for (final fieldChange in fieldChanges) {
    blocTest<VenueLeadFormBloc, VenueLeadFormState>(
      '${fieldChange.name} change updates only its domain field and clears '
      'the prior result',
      build: buildBloc,
      seed: () => changeSeed,
      act: (bloc) => bloc.add(fieldChange.event),
      expect: () => [
        changeSeed.copyWith(
          lead: fieldChange.expectedLead,
          submissionResult: none(),
        ),
      ],
      verify: (_) {
        expect(repository.submittedLeads, isEmpty);
      },
    );
  }

  final requiredInvalidChanges = <_FieldChange>[
    _FieldChange(
      'venue name',
      const VenueLeadFormEvent.venueNameChanged('   '),
      populatedLead.copyWith(venueName: NonEmptySingleLineText('   ')),
    ),
    _FieldChange(
      'website',
      const VenueLeadFormEvent.websiteChanged('not-a-url'),
      populatedLead.copyWith(website: Website('not-a-url')),
    ),
    _FieldChange(
      'first name',
      const VenueLeadFormEvent.firstNameChanged('First\nName'),
      populatedLead.copyWith(firstName: PersonalName('First\nName')),
    ),
    _FieldChange(
      'last name',
      const VenueLeadFormEvent.lastNameChanged(''),
      populatedLead.copyWith(lastName: PersonalName('')),
    ),
    _FieldChange(
      'role',
      const VenueLeadFormEvent.roleChanged(''),
      populatedLead.copyWith(role: NonEmptySingleLineText('')),
    ),
    _FieldChange(
      'email',
      const VenueLeadFormEvent.emailChanged('invalid'),
      populatedLead.copyWith(email: EmailAddress('invalid')),
    ),
  ];

  for (final fieldChange in requiredInvalidChanges) {
    blocTest<VenueLeadFormBloc, VenueLeadFormState>(
      'invalid required ${fieldChange.name} remains typed without throwing',
      build: buildBloc,
      seed: () => _state(lead: populatedLead),
      act: (bloc) => bloc.add(fieldChange.event),
      expect: () => [
        _state(lead: fieldChange.expectedLead),
      ],
      verify: (bloc) {
        expect(bloc.state.lead.isValid, isFalse);
        expect(repository.submittedLeads, isEmpty);
      },
    );
  }

  final optionalClearChanges = <_OptionalChange>[
    _OptionalChange(
      'venue type',
      VenueLeadFormEvent.venueTypeChanged,
      (lead) => lead.copyWith(venueType: none()),
    ),
    _OptionalChange(
      'chain status',
      VenueLeadFormEvent.chainStatusChanged,
      (lead) => lead.copyWith(chainStatus: none()),
    ),
    _OptionalChange(
      'venue count',
      VenueLeadFormEvent.venueCountChanged,
      (lead) => lead.copyWith(venueCount: none()),
    ),
    _OptionalChange(
      'venue capacity',
      VenueLeadFormEvent.venueCapacityChanged,
      (lead) => lead.copyWith(venueCapacity: none()),
    ),
    _OptionalChange(
      'phone number',
      VenueLeadFormEvent.phoneNumberChanged,
      (lead) => lead.copyWith(phoneNumber: none()),
    ),
  ];

  for (final optionalChange in optionalClearChanges) {
    for (final blankInput in ['', ' \t ']) {
      blocTest<VenueLeadFormBloc, VenueLeadFormState>(
        '${optionalChange.name} treats '
        '${blankInput.isEmpty ? 'empty' : 'whitespace-only'} input as absence',
        build: buildBloc,
        seed: () => _state(lead: populatedLead),
        act: (bloc) => bloc.add(optionalChange.event(blankInput)),
        expect: () => [
          _state(lead: optionalChange.clear(populatedLead)),
        ],
        verify: (_) {
          expect(repository.submittedLeads, isEmpty);
        },
      );
    }
  }

  final invalidOptionalChanges = <_FieldChange>[
    _FieldChange(
      'venue type',
      const VenueLeadFormEvent.venueTypeChanged('Type\nOther'),
      populatedLead.copyWith(
        venueType: some(NonEmptySingleLineText('Type\nOther')),
      ),
    ),
    _FieldChange(
      'chain status',
      const VenueLeadFormEvent.chainStatusChanged('Chain\nStatus'),
      populatedLead.copyWith(
        chainStatus: some(NonEmptySingleLineText('Chain\nStatus')),
      ),
    ),
    _FieldChange(
      'venue count',
      const VenueLeadFormEvent.venueCountChanged('many'),
      populatedLead.copyWith(venueCount: some(PositiveInteger('many'))),
    ),
    _FieldChange(
      'venue capacity',
      const VenueLeadFormEvent.venueCapacityChanged('0'),
      populatedLead.copyWith(venueCapacity: some(PositiveInteger('0'))),
    ),
    _FieldChange(
      'phone number',
      const VenueLeadFormEvent.phoneNumberChanged('+34123'),
      populatedLead.copyWith(phoneNumber: some(PhoneNumber('+34123'))),
    ),
  ];

  for (final fieldChange in invalidOptionalChanges) {
    blocTest<VenueLeadFormBloc, VenueLeadFormState>(
      'invalid non-blank optional ${fieldChange.name} remains present',
      build: buildBloc,
      seed: () => _state(lead: populatedLead),
      act: (bloc) => bloc.add(fieldChange.event),
      expect: () => [_state(lead: fieldChange.expectedLead)],
      verify: (bloc) {
        expect(bloc.state.lead.isValid, isFalse);
        expect(repository.submittedLeads, isEmpty);
      },
    );
  }

  blocTest<VenueLeadFormBloc, VenueLeadFormState>(
    'invalid submission exposes validation without operational failure',
    build: buildBloc,
    act: (bloc) => bloc.add(const VenueLeadFormEvent.submitted()),
    expect: () => [
      VenueLeadFormState.initial().copyWith(hasAttemptedSubmit: true),
    ],
    verify: (bloc) {
      expect(bloc.state.lead, VenueLead.empty());
      expect(bloc.state.isSubmitting, isFalse);
      expect(bloc.state.submissionResult, none<Either<AppFailure, Unit>>());
      expect(repository.submittedLeads, isEmpty);
    },
  );

  blocTest<VenueLeadFormBloc, VenueLeadFormState>(
    'valid submission emits submitting then success and preserves the draft',
    build: buildBloc,
    seed: () => _state(lead: populatedLead),
    act: (bloc) => bloc.add(const VenueLeadFormEvent.submitted()),
    expect: () => [
      _state(
        lead: populatedLead,
        hasAttemptedSubmit: true,
        isSubmitting: true,
      ),
      _state(
        lead: populatedLead,
        hasAttemptedSubmit: true,
        submissionResult: some(right(unit)),
      ),
    ],
    verify: (bloc) {
      expect(repository.submittedLeads, [populatedLead]);
      expect(bloc.state.lead, populatedLead);
    },
  );

  for (final failure in const <AppFailure>[
    AppFailure.serviceUnavailable(),
    AppFailure.submissionRejected(),
    AppFailure.unexpected(),
  ]) {
    blocTest<VenueLeadFormBloc, VenueLeadFormState>(
      '${failure.runtimeType} submission emits submitting then failure',
      setUp: () {
        repository.onSubmit = (_) async => left(failure);
      },
      build: buildBloc,
      seed: () => _state(lead: populatedLead),
      act: (bloc) => bloc.add(const VenueLeadFormEvent.submitted()),
      expect: () => [
        _state(
          lead: populatedLead,
          hasAttemptedSubmit: true,
          isSubmitting: true,
        ),
        _state(
          lead: populatedLead,
          hasAttemptedSubmit: true,
          submissionResult: some(left(failure)),
        ),
      ],
      verify: (bloc) {
        expect(repository.submittedLeads, [populatedLead]);
        expect(bloc.state.lead, populatedLead);
      },
    );
  }

  blocTest<VenueLeadFormBloc, VenueLeadFormState>(
    'rapid duplicate submissions create only one in-flight repository call',
    setUp: () {
      final resultCompleter = Completer<Either<AppFailure, Unit>>();
      repository.onSubmit = (_) => resultCompleter.future;
      addTearDown(() {
        if (!resultCompleter.isCompleted) {
          resultCompleter.complete(right(unit));
        }
      });
      repository.completePendingSubmission = () {
        resultCompleter.complete(right(unit));
      };
    },
    build: buildBloc,
    seed: () => _state(lead: populatedLead),
    act: (bloc) async {
      bloc
        ..add(const VenueLeadFormEvent.submitted())
        ..add(const VenueLeadFormEvent.submitted());
      await Future<void>.delayed(Duration.zero);
      expect(repository.submittedLeads, [populatedLead]);
      repository.completePendingSubmission!();
    },
    expect: () => [
      _state(
        lead: populatedLead,
        hasAttemptedSubmit: true,
        isSubmitting: true,
      ),
      _state(
        lead: populatedLead,
        hasAttemptedSubmit: true,
        submissionResult: some(right(unit)),
      ),
    ],
    verify: (_) {
      expect(repository.submittedLeads, hasLength(1));
    },
  );

  for (final (completionName, completionResult) in [
    ('success', right<AppFailure, Unit>(unit)),
    (
      'failure',
      left<AppFailure, Unit>(const AppFailure.serviceUnavailable()),
    ),
  ]) {
    final editedLead = populatedLead.copyWith(
      venueName: NonEmptySingleLineText('Edited Venue'),
    );
    late Completer<Either<AppFailure, Unit>> resultCompleter;

    blocTest<VenueLeadFormBloc, VenueLeadFormState>(
      'discards stale $completionName when the draft changes in flight',
      setUp: () {
        resultCompleter = Completer<Either<AppFailure, Unit>>();
        repository.onSubmit = (_) => resultCompleter.future;
      },
      build: buildBloc,
      seed: () => _state(lead: populatedLead),
      act: (bloc) async {
        final submitting = bloc.stream.firstWhere(
          (state) => state.isSubmitting,
        );
        bloc.add(const VenueLeadFormEvent.submitted());
        await submitting;

        final edited = bloc.stream.firstWhere(
          (state) => state.lead == editedLead,
        );
        bloc.add(
          const VenueLeadFormEvent.venueNameChanged('Edited Venue'),
        );
        await edited;

        final settled = bloc.stream.firstWhere(
          (state) => !state.isSubmitting && state.lead == editedLead,
        );
        resultCompleter.complete(completionResult);
        await settled;
      },
      expect: () => [
        _state(
          lead: populatedLead,
          hasAttemptedSubmit: true,
          isSubmitting: true,
        ),
        _state(
          lead: editedLead,
          hasAttemptedSubmit: true,
          isSubmitting: true,
        ),
        _state(
          lead: editedLead,
          hasAttemptedSubmit: true,
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.lead, editedLead);
        expect(bloc.state.isSubmitting, isFalse);
        expect(bloc.state.submissionResult, none<Either<AppFailure, Unit>>());
        expect(repository.submittedLeads, [populatedLead]);
      },
    );
  }

  blocTest<VenueLeadFormBloc, VenueLeadFormState>(
    'submission can retry successfully after an operational failure',
    setUp: () {
      repository.onSubmit = (_) async {
        if (repository.submittedLeads.length == 1) {
          return left(const AppFailure.serviceUnavailable());
        } else {
          return right(unit);
        }
      };
    },
    build: buildBloc,
    seed: () => _state(lead: populatedLead),
    act: (bloc) async {
      final firstCompletion = bloc.stream.firstWhere(
        (state) => !state.isSubmitting && state.submissionResult.isSome(),
      );
      bloc.add(const VenueLeadFormEvent.submitted());
      await firstCompletion;
      bloc.add(const VenueLeadFormEvent.submitted());
    },
    expect: () => [
      _state(
        lead: populatedLead,
        hasAttemptedSubmit: true,
        isSubmitting: true,
      ),
      _state(
        lead: populatedLead,
        hasAttemptedSubmit: true,
        submissionResult: some(
          left(const AppFailure.serviceUnavailable()),
        ),
      ),
      _state(
        lead: populatedLead,
        hasAttemptedSubmit: true,
        isSubmitting: true,
      ),
      _state(
        lead: populatedLead,
        hasAttemptedSubmit: true,
        submissionResult: some(right(unit)),
      ),
    ],
    verify: (_) {
      expect(repository.submittedLeads, [populatedLead, populatedLead]);
    },
  );

  blocTest<VenueLeadFormBloc, VenueLeadFormState>(
    'edit after failure clears the result but keeps validation visible',
    build: buildBloc,
    seed: () => _state(
      lead: populatedLead,
      hasAttemptedSubmit: true,
      submissionResult: some(left(const AppFailure.unexpected())),
    ),
    act: (bloc) => bloc.add(
      const VenueLeadFormEvent.roleChanged('Updated role'),
    ),
    expect: () => [
      _state(
        lead: populatedLead.copyWith(
          role: NonEmptySingleLineText('Updated role'),
        ),
        hasAttemptedSubmit: true,
      ),
    ],
  );
}

VenueLeadFormState _state({
  required VenueLead lead,
  bool hasAttemptedSubmit = false,
  bool isSubmitting = false,
  Option<Either<AppFailure, Unit>>? submissionResult,
}) => VenueLeadFormState(
  lead: lead,
  hasAttemptedSubmit: hasAttemptedSubmit,
  isSubmitting: isSubmitting,
  submissionResult: submissionResult ?? none(),
);

VenueLead _validLeadWithOptionals() => VenueLead(
  venueName: NonEmptySingleLineText('The Fun Venue'),
  venueType: some(NonEmptySingleLineText('Music venue')),
  chainStatus: some(NonEmptySingleLineText('Part of a chain')),
  venueCount: some(PositiveInteger('4')),
  venueCapacity: some(PositiveInteger('850')),
  website: Website('https://venue.example.com'),
  firstName: PersonalName('Alex'),
  lastName: PersonalName('Morgan'),
  role: NonEmptySingleLineText('General manager'),
  email: EmailAddress('alex@venue.example.com'),
  phoneNumber: some(PhoneNumber('0034123456789')),
);

class _FieldChange {
  const _FieldChange(this.name, this.event, this.expectedLead);

  final String name;
  final VenueLeadFormEvent event;
  final VenueLead expectedLead;
}

class _OptionalChange {
  const _OptionalChange(this.name, this.event, this.clear);

  final String name;
  final VenueLeadFormEvent Function(String input) event;
  final VenueLead Function(VenueLead lead) clear;
}

class _FakeVenueLeadRepository implements VenueLeadRepositoryInterface {
  Future<Either<AppFailure, Unit>> Function(VenueLead lead) onSubmit = (
    _,
  ) async => right(unit);
  void Function()? completePendingSubmission;
  final List<VenueLead> submittedLeads = [];

  @override
  Future<Either<AppFailure, Unit>> submitVenueLead(VenueLead lead) {
    submittedLeads.add(lead);
    return onSubmit(lead);
  }
}
