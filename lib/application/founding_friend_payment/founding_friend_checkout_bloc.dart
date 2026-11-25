import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_payment_status_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/founding_friend_payment_repository_interface.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/pending_founding_friend_payment_store_interface.dart';

/// Recovery stops well before Stripe can prune API v1 idempotency keys.
const foundingFriendCheckoutReplayWindow = Duration(hours: 1);

/// Checkout preparation lifecycle after confirmed Founding Friend registration.
enum FoundingFriendCheckoutPhase {
  /// No registration success or retry has started Checkout preparation.
  idle,

  /// The current tab has an earlier attempt that needs an explicit retry.
  recoveryRequired,

  /// The first-party service is preparing a Checkout Session.
  preparing,

  /// Recovery is checking the existing Session through the payment service.
  verifying,

  /// Recovery resolved to a payment status rather than a usable Checkout.
  verified,

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
    this.paymentStatus,
  });

  /// Initial state before a registration success or explicit retry.
  const FoundingFriendCheckoutState.initial()
    : phase = FoundingFriendCheckoutPhase.idle,
      checkout = null,
      failure = null,
      paymentStatus = null;

  /// Current lifecycle phase.
  final FoundingFriendCheckoutPhase phase;

  /// Validated Checkout destination when [phase] is ready or redirecting.
  final FoundingFriendCheckout? checkout;

  /// Provider-neutral operational failure when preparation failed.
  final AppFailure? failure;

  /// Read-only status shown when recovery cannot resume Checkout.
  final FoundingFriendPaymentStatusState? paymentStatus;
}

/// Intents accepted by [FoundingFriendCheckoutBloc].
sealed class FoundingFriendCheckoutEvent {
  const FoundingFriendCheckoutEvent();
}

/// Checks the current tab before displaying the registration form.
final class FoundingFriendCheckoutRecoveryOpened
    extends FoundingFriendCheckoutEvent {
  /// Creates the event.
  const FoundingFriendCheckoutRecoveryOpened();
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
  const FoundingFriendExpiredCheckoutRetryRequested(this.sessionId);

  /// Session ID from the verified return route.
  final String sessionId;
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
    DateTime Function()? now,
  }) : this._(
         repository,
         pendingStore,
         createAttemptId ?? generateCheckoutAttemptId,
         now ?? DateTime.now,
       );

  FoundingFriendCheckoutBloc._(
    this._repository,
    this._pendingStore,
    this._createAttemptId,
    this._now,
  ) : super(const FoundingFriendCheckoutState.initial()) {
    on<FoundingFriendRegistrationConfirmed>(_onRegistrationConfirmed);
    on<FoundingFriendCheckoutRecoveryOpened>(_onRecoveryOpened);
    on<FoundingFriendCheckoutRetryRequested>(_onRetryRequested);
    on<FoundingFriendExpiredCheckoutRetryRequested>(_onExpiredRetryRequested);
    on<FoundingFriendCheckoutRedirectStarted>(_onRedirectStarted);
    on<FoundingFriendCheckoutRedirectFailed>(_onRedirectFailed);
  }

  final FoundingFriendPaymentRepositoryInterface _repository;
  final PendingFoundingFriendPaymentStoreInterface _pendingStore;
  final String Function() _createAttemptId;
  final DateTime Function() _now;
  PendingFoundingFriendPayment? _pendingPayment;

  void _onRecoveryOpened(
    FoundingFriendCheckoutRecoveryOpened event,
    Emitter<FoundingFriendCheckoutState> emit,
  ) {
    if (state.phase == FoundingFriendCheckoutPhase.idle) {
      final snapshot = _pendingStore.readForRecovery();
      if (snapshot.unavailable) {
        _recoveryUnavailable(emit);
      } else if (snapshot.payment != null) {
        _pendingPayment = snapshot.payment;
        emit(
          const FoundingFriendCheckoutState(
            phase: FoundingFriendCheckoutPhase.recoveryRequired,
          ),
        );
      }
    }
  }

  Future<void> _onRegistrationConfirmed(
    FoundingFriendRegistrationConfirmed event,
    Emitter<FoundingFriendCheckoutState> emit,
  ) async {
    if (state.phase == FoundingFriendCheckoutPhase.idle) {
      final snapshot = _pendingStore.readForRecovery();
      if (!snapshot.unavailable && snapshot.payment == null) {
        final pending = _newAttempt(event.email);
        _pendingPayment = pending;
        _pendingStore.save(pending);
        await _prepare(pending, emit);
      } else {
        _recoveryUnavailable(emit);
      }
    }
  }

  Future<void> _onRetryRequested(
    FoundingFriendCheckoutRetryRequested event,
    Emitter<FoundingFriendCheckoutState> emit,
  ) async {
    if (_canRetry) {
      await _recover(emit);
    }
  }

  Future<void> _onExpiredRetryRequested(
    FoundingFriendExpiredCheckoutRetryRequested event,
    Emitter<FoundingFriendCheckoutState> emit,
  ) async {
    if (state.phase == FoundingFriendCheckoutPhase.idle) {
      await _recover(emit, expectedSessionId: event.sessionId);
    }
  }

  bool get _canRetry =>
      state.phase == FoundingFriendCheckoutPhase.idle ||
      state.phase == FoundingFriendCheckoutPhase.recoveryRequired ||
      state.phase == FoundingFriendCheckoutPhase.failed ||
      (state.phase == FoundingFriendCheckoutPhase.verified &&
          (state.paymentStatus?.phase ==
                  FoundingFriendPaymentStatusPhase.pending ||
              state.paymentStatus?.phase ==
                  FoundingFriendPaymentStatusPhase.expired ||
              state.paymentStatus?.phase ==
                  FoundingFriendPaymentStatusPhase.unableToVerify));

  Future<void> _recover(
    Emitter<FoundingFriendCheckoutState> emit, {
    String? expectedSessionId,
  }) async {
    final pending = _pendingPayment ?? _pendingStore.readForRecovery().payment;
    if (pending == null ||
        (expectedSessionId != null && pending.sessionId != expectedSessionId)) {
      _recoveryUnavailable(emit);
    } else {
      _pendingPayment = pending;
      if (pending.sessionId != null) {
        await _verify(pending, emit);
      } else if (_canReplay(pending)) {
        await _prepare(pending, emit, verify: true);
      } else {
        _recoveryUnavailable(emit);
      }
    }
  }

  PendingFoundingFriendPayment _newAttempt(String email) =>
      PendingFoundingFriendPayment(
        email: email,
        attemptId: _createAttemptId(),
        createdAt: _now().millisecondsSinceEpoch,
      );

  bool _canReplay(PendingFoundingFriendPayment pending) {
    final createdAt = pending.createdAt;
    if (createdAt == null || createdAt <= 0) {
      return false;
    }
    final age = _now().millisecondsSinceEpoch - createdAt;
    return age >= 0 && age < foundingFriendCheckoutReplayWindow.inMilliseconds;
  }

  void _recoveryUnavailable(Emitter<FoundingFriendCheckoutState> emit) => emit(
    const FoundingFriendCheckoutState(
      phase: FoundingFriendCheckoutPhase.recoveryUnavailable,
    ),
  );

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

  bool _canContinue(
    PendingFoundingFriendPayment pending,
    Emitter<FoundingFriendCheckoutState> emit,
  ) {
    if (emit.isDone) {
      return false;
    } else {
      final ownsPending = pending.matches(
        _pendingStore.readForRecovery().payment,
      );
      if (!ownsPending) {
        _recoveryUnavailable(emit);
      }
      return ownsPending;
    }
  }

  Future<void> _prepare(
    PendingFoundingFriendPayment pending,
    Emitter<FoundingFriendCheckoutState> emit, {
    bool verify = false,
    bool allowRotation = true,
  }) async {
    if (!_canContinue(pending, emit)) {
      return;
    }
    emit(
      const FoundingFriendCheckoutState(
        phase: FoundingFriendCheckoutPhase.preparing,
      ),
    );
    final result = await _repository.createCheckout(
      email: pending.email,
      attemptId: pending.attemptId,
    );
    if (!_canContinue(pending, emit)) {
      return;
    }
    await result.fold(
      (failure) async => emit(
        FoundingFriendCheckoutState(
          phase: FoundingFriendCheckoutPhase.failed,
          failure: failure,
        ),
      ),
      (checkout) async {
        final saved = PendingFoundingFriendPayment(
          email: pending.email,
          attemptId: pending.attemptId,
          sessionId: checkout.sessionId,
          createdAt: pending.createdAt,
          checkoutUrl: checkout.checkoutUrl,
        );
        _pendingPayment = saved;
        _pendingStore.save(saved);
        if (_canContinue(saved, emit)) {
          if (verify) {
            await _verify(
              saved,
              emit,
              allowRotation: allowRotation,
            );
          } else {
            emit(
              FoundingFriendCheckoutState(
                phase: FoundingFriendCheckoutPhase.ready,
                checkout: checkout,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _verify(
    PendingFoundingFriendPayment pending,
    Emitter<FoundingFriendCheckoutState> emit, {
    bool allowRotation = true,
  }) async {
    if (!_canContinue(pending, emit)) {
      return;
    }
    emit(
      const FoundingFriendCheckoutState(
        phase: FoundingFriendCheckoutPhase.verifying,
        paymentStatus: FoundingFriendPaymentStatusState(
          phase: FoundingFriendPaymentStatusPhase.verifying,
        ),
      ),
    );
    final result = await _repository.verifyCheckout(pending.sessionId!);
    if (!_canContinue(pending, emit)) {
      return;
    }
    await result.fold(
      (failure) async => emit(
        FoundingFriendCheckoutState(
          phase: FoundingFriendCheckoutPhase.verified,
          paymentStatus: FoundingFriendPaymentStatusState(
            phase: FoundingFriendPaymentStatusPhase.unableToVerify,
            failure: failure,
          ),
        ),
      ),
      (verification) async {
        if (verification.status == FoundingFriendPaymentStatus.expired &&
            allowRotation) {
          final replacement = _newAttempt(pending.email);
          _pendingPayment = replacement;
          _pendingStore.save(replacement);
          await _prepare(replacement, emit, verify: true, allowRotation: false);
        } else if (verification.status == FoundingFriendPaymentStatus.pending &&
            verification.canResumeCheckout) {
          final checkoutUrl = pending.checkoutUrl;
          if (checkoutUrl == null) {
            _recoveryUnavailable(emit);
          } else {
            emit(
              FoundingFriendCheckoutState(
                phase: FoundingFriendCheckoutPhase.ready,
                checkout: FoundingFriendCheckout(
                  checkoutUrl: checkoutUrl,
                  sessionId: pending.sessionId!,
                ),
              ),
            );
          }
        } else {
          if (verification.status == FoundingFriendPaymentStatus.confirmed) {
            _pendingStore.clear();
          }
          emit(
            FoundingFriendCheckoutState(
              phase: FoundingFriendCheckoutPhase.verified,
              paymentStatus: FoundingFriendPaymentStatusState.verified(
                verification,
              ),
            ),
          );
        }
      },
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
