import 'package:bloc/bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/founding_friend_payment_repository_interface.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/pending_founding_friend_payment_store_interface.dart';

/// Reloadable return-page verification phases.
enum FoundingFriendPaymentStatusPhase {
  /// Verification has not started.
  initial,

  /// The first-party service is checking the Checkout Session.
  verifying,

  /// Payment was verified as qualifying.
  confirmed,

  /// Payment is not yet confirmed.
  pending,

  /// The Checkout Session expired.
  expired,

  /// The payment was refunded.
  refunded,

  /// The payment is disputed.
  disputed,

  /// Provider data did not match the expected purchase.
  invalid,

  /// Verification could not currently be completed.
  unableToVerify,
}

/// Immutable payment return-page state.
final class FoundingFriendPaymentStatusState {
  /// Creates a status state.
  const FoundingFriendPaymentStatusState({
    required this.phase,
    this.purchaseReference,
    this.failure,
  });

  /// Initial state before explicit verification.
  const FoundingFriendPaymentStatusState.initial()
    : phase = FoundingFriendPaymentStatusPhase.initial,
      purchaseReference = null,
      failure = null;

  /// Current verification phase.
  final FoundingFriendPaymentStatusPhase phase;

  /// Reference shown only after verified success.
  final String? purchaseReference;

  /// Provider-neutral failure for an unavailable verification call.
  final AppFailure? failure;
}

/// Requests verification for one opaque Checkout Session.
final class FoundingFriendPaymentVerificationRequested {
  /// Creates the event.
  const FoundingFriendPaymentVerificationRequested(this.sessionId);

  /// Opaque Checkout Session identifier from the Stripe redirect.
  final String sessionId;
}

/// Owns read-only and reload-safe payment verification.
final class FoundingFriendPaymentStatusBloc
    extends
        Bloc<
          FoundingFriendPaymentVerificationRequested,
          FoundingFriendPaymentStatusState
        > {
  /// Creates the status BLoC.
  FoundingFriendPaymentStatusBloc({
    required FoundingFriendPaymentRepositoryInterface repository,
    required PendingFoundingFriendPaymentStoreInterface pendingStore,
  }) : this._(repository, pendingStore);

  FoundingFriendPaymentStatusBloc._(
    this._repository,
    this._pendingStore,
  ) : super(const FoundingFriendPaymentStatusState.initial()) {
    on<FoundingFriendPaymentVerificationRequested>(_onVerificationRequested);
  }

  final FoundingFriendPaymentRepositoryInterface _repository;
  final PendingFoundingFriendPaymentStoreInterface _pendingStore;

  Future<void> _onVerificationRequested(
    FoundingFriendPaymentVerificationRequested event,
    Emitter<FoundingFriendPaymentStatusState> emit,
  ) async {
    if (state.phase != FoundingFriendPaymentStatusPhase.verifying) {
      emit(
        const FoundingFriendPaymentStatusState(
          phase: FoundingFriendPaymentStatusPhase.verifying,
        ),
      );
      final result = await _repository.verifyCheckout(event.sessionId);
      result.fold(
        (failure) => emit(
          FoundingFriendPaymentStatusState(
            phase: FoundingFriendPaymentStatusPhase.unableToVerify,
            failure: failure,
          ),
        ),
        (verification) {
          final phase = switch (verification.status) {
            FoundingFriendPaymentStatus.confirmed =>
              FoundingFriendPaymentStatusPhase.confirmed,
            FoundingFriendPaymentStatus.pending =>
              FoundingFriendPaymentStatusPhase.pending,
            FoundingFriendPaymentStatus.expired =>
              FoundingFriendPaymentStatusPhase.expired,
            FoundingFriendPaymentStatus.refunded =>
              FoundingFriendPaymentStatusPhase.refunded,
            FoundingFriendPaymentStatus.disputed =>
              FoundingFriendPaymentStatusPhase.disputed,
            FoundingFriendPaymentStatus.invalid =>
              FoundingFriendPaymentStatusPhase.invalid,
          };
          if (phase == FoundingFriendPaymentStatusPhase.confirmed) {
            _pendingStore.clear();
          }
          emit(
            FoundingFriendPaymentStatusState(
              phase: phase,
              purchaseReference: verification.purchaseReference,
            ),
          );
        },
      );
    }
  }
}
