import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/founding_friend_payment_repository_interface.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/pending_founding_friend_payment_store_interface.dart';

/// Checkout preparation lifecycle after confirmed Founding Friend registration.
enum FoundingFriendCheckoutPhase {
  /// No registration success or retry has started Checkout preparation.
  idle,

  /// The first-party service is preparing a Checkout Session.
  preparing,

  /// A validated hosted Checkout destination is ready.
  ready,

  /// Browser navigation to hosted Checkout has begun.
  redirecting,

  /// Checkout preparation or browser navigation failed.
  failed,

  /// Tab-scoped retry state is no longer available.
  recoveryUnavailable,
}

/// Immutable Checkout preparation state.
final class FoundingFriendCheckoutState {
  /// Creates a Checkout state.
  const FoundingFriendCheckoutState({
    required this.phase,
    this.checkout,
    this.failure,
  });

  /// Initial state before a registration success or explicit retry.
  const FoundingFriendCheckoutState.initial()
    : phase = FoundingFriendCheckoutPhase.idle,
      checkout = null,
      failure = null;

  /// Current lifecycle phase.
  final FoundingFriendCheckoutPhase phase;

  /// Validated Checkout destination when [phase] is ready or redirecting.
  final FoundingFriendCheckout? checkout;

  /// Provider-neutral operational failure when preparation failed.
  final AppFailure? failure;
}

/// Intents accepted by [FoundingFriendCheckoutBloc].
sealed class FoundingFriendCheckoutEvent {
  const FoundingFriendCheckoutEvent();
}

/// Starts Checkout exactly once after confirmed registration.
final class FoundingFriendRegistrationConfirmed
    extends FoundingFriendCheckoutEvent {
  /// Creates the event.
  const FoundingFriendRegistrationConfirmed(this.email);

  /// Validated registration email used to prefill Checkout.
  final String email;
}

/// Explicitly retries Checkout without resubmitting registration.
final class FoundingFriendCheckoutRetryRequested
    extends FoundingFriendCheckoutEvent {
  /// Creates the event.
  const FoundingFriendCheckoutRetryRequested();
}

/// Starts a fresh payment attempt after a verified expired Checkout.
final class FoundingFriendExpiredCheckoutRetryRequested
    extends FoundingFriendCheckoutEvent {
  /// Creates the event.
  const FoundingFriendExpiredCheckoutRetryRequested();
}

/// Marks a validated browser redirect as started.
final class FoundingFriendCheckoutRedirectStarted
    extends FoundingFriendCheckoutEvent {
  /// Creates the event.
  const FoundingFriendCheckoutRedirectStarted();
}

/// Marks a browser redirect failure so the user can retry safely.
final class FoundingFriendCheckoutRedirectFailed
    extends FoundingFriendCheckoutEvent {
  /// Creates the event.
  const FoundingFriendCheckoutRedirectFailed();
}

/// Coordinates idempotent Checkout preparation independently of registration.
final class FoundingFriendCheckoutBloc
    extends Bloc<FoundingFriendCheckoutEvent, FoundingFriendCheckoutState> {
  /// Creates the Checkout BLoC.
  FoundingFriendCheckoutBloc({
    required FoundingFriendPaymentRepositoryInterface repository,
    required PendingFoundingFriendPaymentStoreInterface pendingStore,
    String Function()? createAttemptId,
  }) : this._(
         repository,
         pendingStore,
         createAttemptId ?? generateCheckoutAttemptId,
       );

  FoundingFriendCheckoutBloc._(
    this._repository,
    this._pendingStore,
    this._createAttemptId,
  ) : super(const FoundingFriendCheckoutState.initial()) {
    on<FoundingFriendRegistrationConfirmed>(_onRegistrationConfirmed);
    on<FoundingFriendCheckoutRetryRequested>(_onRetryRequested);
    on<FoundingFriendExpiredCheckoutRetryRequested>(_onExpiredRetryRequested);
    on<FoundingFriendCheckoutRedirectStarted>(_onRedirectStarted);
    on<FoundingFriendCheckoutRedirectFailed>(_onRedirectFailed);
  }

  final FoundingFriendPaymentRepositoryInterface _repository;
  final PendingFoundingFriendPaymentStoreInterface _pendingStore;
  final String Function() _createAttemptId;
  PendingFoundingFriendPayment? _pendingPayment;

  Future<void> _onRegistrationConfirmed(
    FoundingFriendRegistrationConfirmed event,
    Emitter<FoundingFriendCheckoutState> emit,
  ) async {
    if (state.phase == FoundingFriendCheckoutPhase.idle) {
      final pending = PendingFoundingFriendPayment(
        email: event.email,
        attemptId: _createAttemptId(),
      );
      _pendingPayment = pending;
      _pendingStore.save(pending);
      await _prepare(pending, emit);
    }
  }

  Future<void> _onRetryRequested(
    FoundingFriendCheckoutRetryRequested event,
    Emitter<FoundingFriendCheckoutState> emit,
  ) async {
    if (state.phase != FoundingFriendCheckoutPhase.preparing) {
      final pending = _pendingPayment ?? _pendingStore.read();
      if (pending == null) {
        emit(
          const FoundingFriendCheckoutState(
            phase: FoundingFriendCheckoutPhase.recoveryUnavailable,
          ),
        );
      } else {
        _pendingPayment = pending;
        await _prepare(pending, emit);
      }
    }
  }

  Future<void> _onExpiredRetryRequested(
    FoundingFriendExpiredCheckoutRetryRequested event,
    Emitter<FoundingFriendCheckoutState> emit,
  ) async {
    if (state.phase != FoundingFriendCheckoutPhase.preparing) {
      final prior = _pendingPayment ?? _pendingStore.read();
      if (prior == null) {
        emit(
          const FoundingFriendCheckoutState(
            phase: FoundingFriendCheckoutPhase.recoveryUnavailable,
          ),
        );
      } else {
        final pending = PendingFoundingFriendPayment(
          email: prior.email,
          attemptId: _createAttemptId(),
        );
        _pendingPayment = pending;
        _pendingStore.save(pending);
        await _prepare(pending, emit);
      }
    }
  }

  void _onRedirectStarted(
    FoundingFriendCheckoutRedirectStarted event,
    Emitter<FoundingFriendCheckoutState> emit,
  ) {
    if (state.phase == FoundingFriendCheckoutPhase.ready) {
      emit(
        FoundingFriendCheckoutState(
          phase: FoundingFriendCheckoutPhase.redirecting,
          checkout: state.checkout,
        ),
      );
    }
  }

  void _onRedirectFailed(
    FoundingFriendCheckoutRedirectFailed event,
    Emitter<FoundingFriendCheckoutState> emit,
  ) {
    if (state.phase == FoundingFriendCheckoutPhase.ready ||
        state.phase == FoundingFriendCheckoutPhase.redirecting) {
      emit(
        const FoundingFriendCheckoutState(
          phase: FoundingFriendCheckoutPhase.failed,
          failure: AppFailure.unexpected(),
        ),
      );
    }
  }

  Future<void> _prepare(
    PendingFoundingFriendPayment pending,
    Emitter<FoundingFriendCheckoutState> emit,
  ) async {
    emit(
      const FoundingFriendCheckoutState(
        phase: FoundingFriendCheckoutPhase.preparing,
      ),
    );
    final result = await _repository.createCheckout(
      email: pending.email,
      attemptId: pending.attemptId,
    );
    result.fold(
      (failure) => emit(
        FoundingFriendCheckoutState(
          phase: FoundingFriendCheckoutPhase.failed,
          failure: failure,
        ),
      ),
      (checkout) => emit(
        FoundingFriendCheckoutState(
          phase: FoundingFriendCheckoutPhase.ready,
          checkout: checkout,
        ),
      ),
    );
  }
}

/// Generates a UUIDv4-compatible, non-personal Checkout correlation value.
String generateCheckoutAttemptId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}
