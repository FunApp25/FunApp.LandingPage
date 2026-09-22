import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/email_address.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/non_empty_single_line_text.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/personal_name.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/phone_number.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/positive_integer.dart';
import 'package:fun_app_landing_page/domain/core/value_objects/website.dart';
import 'package:fun_app_landing_page/domain/venue/entities/venue_lead.dart';
import 'package:fun_app_landing_page/domain/venue/venue_lead_repository_interface.dart';
import 'package:injectable/injectable.dart';

part 'venue_lead_form_bloc.freezed.dart';
part 'venue_lead_form_event.dart';
part 'venue_lead_form_state.dart';

/// Owns the prospective-venue form draft and submission workflow.
@injectable
class VenueLeadFormBloc extends Bloc<VenueLeadFormEvent, VenueLeadFormState> {
  /// Creates a [VenueLeadFormBloc] backed by a provider-neutral repository.
  VenueLeadFormBloc(this._repository) : super(VenueLeadFormState.initial()) {
    on<_VenueNameChanged>(_onVenueNameChanged);
    on<_VenueTypeChanged>(_onVenueTypeChanged);
    on<_ChainStatusChanged>(_onChainStatusChanged);
    on<_VenueCountChanged>(_onVenueCountChanged);
    on<_VenueCapacityChanged>(_onVenueCapacityChanged);
    on<_WebsiteChanged>(_onWebsiteChanged);
    on<_FirstNameChanged>(_onFirstNameChanged);
    on<_LastNameChanged>(_onLastNameChanged);
    on<_RoleChanged>(_onRoleChanged);
    on<_EmailChanged>(_onEmailChanged);
    on<_PhoneNumberChanged>(_onPhoneNumberChanged);
    on<_Submitted>(_onSubmitted);
  }

  final VenueLeadRepositoryInterface _repository;

  void _onVenueNameChanged(
    _VenueNameChanged event,
    Emitter<VenueLeadFormState> emit,
  ) => _emitLeadChange(
    emit,
    state.lead.copyWith(
      venueName: NonEmptySingleLineText(event.venueName),
    ),
  );

  void _onVenueTypeChanged(
    _VenueTypeChanged event,
    Emitter<VenueLeadFormState> emit,
  ) => _emitLeadChange(
    emit,
    state.lead.copyWith(
      venueType: _optionalValue(
        event.venueType,
        NonEmptySingleLineText.new,
      ),
    ),
  );

  void _onChainStatusChanged(
    _ChainStatusChanged event,
    Emitter<VenueLeadFormState> emit,
  ) => _emitLeadChange(
    emit,
    state.lead.copyWith(
      chainStatus: _optionalValue(
        event.chainStatus,
        NonEmptySingleLineText.new,
      ),
    ),
  );

  void _onVenueCountChanged(
    _VenueCountChanged event,
    Emitter<VenueLeadFormState> emit,
  ) => _emitLeadChange(
    emit,
    state.lead.copyWith(
      venueCount: _optionalValue(
        event.venueCount,
        PositiveInteger.new,
      ),
    ),
  );

  void _onVenueCapacityChanged(
    _VenueCapacityChanged event,
    Emitter<VenueLeadFormState> emit,
  ) => _emitLeadChange(
    emit,
    state.lead.copyWith(
      venueCapacity: _optionalValue(
        event.venueCapacity,
        PositiveInteger.new,
      ),
    ),
  );

  void _onWebsiteChanged(
    _WebsiteChanged event,
    Emitter<VenueLeadFormState> emit,
  ) => _emitLeadChange(
    emit,
    state.lead.copyWith(
      website: Website(event.website),
    ),
  );

  void _onFirstNameChanged(
    _FirstNameChanged event,
    Emitter<VenueLeadFormState> emit,
  ) => _emitLeadChange(
    emit,
    state.lead.copyWith(
      firstName: PersonalName(event.firstName),
    ),
  );

  void _onLastNameChanged(
    _LastNameChanged event,
    Emitter<VenueLeadFormState> emit,
  ) => _emitLeadChange(
    emit,
    state.lead.copyWith(
      lastName: PersonalName(event.lastName),
    ),
  );

  void _onRoleChanged(
    _RoleChanged event,
    Emitter<VenueLeadFormState> emit,
  ) => _emitLeadChange(
    emit,
    state.lead.copyWith(
      role: NonEmptySingleLineText(event.role),
    ),
  );

  void _onEmailChanged(
    _EmailChanged event,
    Emitter<VenueLeadFormState> emit,
  ) => _emitLeadChange(
    emit,
    state.lead.copyWith(
      email: EmailAddress(event.email),
    ),
  );

  void _onPhoneNumberChanged(
    _PhoneNumberChanged event,
    Emitter<VenueLeadFormState> emit,
  ) => _emitLeadChange(
    emit,
    state.lead.copyWith(
      phoneNumber: _optionalValue(
        event.phoneNumber,
        PhoneNumber.new,
      ),
    ),
  );

  Future<void> _onSubmitted(
    _Submitted event,
    Emitter<VenueLeadFormState> emit,
  ) async {
    if (!state.isSubmitting) {
      final attemptedState = state.copyWith(
        hasAttemptedSubmit: true,
        submissionResult: none(),
      );

      if (state.lead.isValid) {
        final submittedLead = state.lead;
        emit(attemptedState.copyWith(isSubmitting: true));

        final submissionResult = await _repository.submitVenueLead(
          submittedLead,
        );
        final isCurrentDraftSubmitted = state.lead == submittedLead;

        emit(
          state.copyWith(
            isSubmitting: false,
            hasAttemptedSubmit: true,
            submissionResult: isCurrentDraftSubmitted
                ? some(submissionResult)
                : none(),
          ),
        );
      } else {
        emit(attemptedState.copyWith(isSubmitting: false));
      }
    }
  }

  void _emitLeadChange(
    Emitter<VenueLeadFormState> emit,
    VenueLead lead,
  ) => emit(
    state.copyWith(
      lead: lead,
      submissionResult: none(),
    ),
  );

  Option<T> _optionalValue<T>(
    String input,
    T Function(String input) createValue,
  ) {
    if (input.trim().isEmpty) {
      return none();
    } else {
      return some(createValue(input));
    }
  }
}
