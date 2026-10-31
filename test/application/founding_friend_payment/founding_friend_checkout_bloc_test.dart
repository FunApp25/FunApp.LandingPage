import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_checkout_bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_payment_status_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/founding_friend_payment_repository_interface.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/pending_founding_friend_payment_store_interface.dart';

const _attempt = '123e4567-e89b-42d3-a456-426614174000';
const _replacement = 'd9428888-122b-4c5f-8e6a-cc2eeb112233';
const _session = 'cs_test_abcdefghijklmnopqrstuvwxyz123456';
const _newSession = 'cs_test_abcdefghijklmnopqrstuvwxyz654321';
const _email = 'founder@example.com';
const _open = FoundingFriendPaymentVerification(
  status: FoundingFriendPaymentStatus.pending,
  canResumeCheckout: true,
);
const _expired = FoundingFriendPaymentVerification(
  status: FoundingFriendPaymentStatus.expired,
);

FoundingFriendCheckout _checkout(String session) => FoundingFriendCheckout(
  checkoutUrl: Uri.https('checkout.stripe.com', '/c/pay/$session'),
  sessionId: session,
);

_PendingStore _store({String? session = _session}) => _PendingStore()
  ..save(
    PendingFoundingFriendPayment(
      email: _email,
      attemptId: _attempt,
      sessionId: session,
    ),
  );

Future<FoundingFriendCheckoutState> _dispatch(
  FoundingFriendCheckoutBloc bloc, [
  FoundingFriendCheckoutEvent event =
      const FoundingFriendCheckoutRetryRequested(),
]) {
  final completed = bloc.stream.firstWhere(
    (state) => switch (state.phase) {
      FoundingFriendCheckoutPhase.idle ||
      FoundingFriendCheckoutPhase.preparing ||
      FoundingFriendCheckoutPhase.verifying => false,
      _ => true,
    },
  );
  bloc.add(event);
  return completed;
}

void main() {
  test(
    'registration stores the Session before redirect; starts only once',
    () async {
      final repository = _PaymentRepository([right(_checkout(_session))]);
      final store = _PendingStore();
      var attempts = 0;
      final bloc = FoundingFriendCheckoutBloc(
        repository: repository,
        pendingStore: store,
        createAttemptId: () {
          attempts++;
          return _attempt;
        },
      );
      addTearDown(bloc.close);
      final result = await _dispatch(
        bloc,
        const FoundingFriendRegistrationConfirmed(_email),
      );
      bloc.add(const FoundingFriendRegistrationConfirmed(_email));
      await Future<void>.delayed(Duration.zero);
      expect(result.phase, FoundingFriendCheckoutPhase.ready);
      expect(store.read()?.sessionId, _session);
      expect(store.read()?.attemptId, _attempt);
      expect(repository.creates, [_attempt]);
      expect(repository.verifications, isEmpty);
      expect(attempts, 1);
    },
  );

  test('cancel retry verifies open Checkout and retains its attempt', () async {
    final repository = _PaymentRepository(
      [right(_checkout(_session))],
      [right(_open), right(_open)],
    );
    final store = _store();
    final bloc = FoundingFriendCheckoutBloc(
      repository: repository,
      pendingStore: store,
      createAttemptId: () => throw StateError('must not rotate'),
    );
    addTearDown(bloc.close);
    await Future<void>.delayed(Duration.zero);
    expect(repository.calls, isEmpty);
    final result = await _dispatch(bloc);
    expect(result.checkout?.sessionId, _session);
    expect(repository.calls, [
      'verify:$_session',
      'create:$_attempt',
      'verify:$_session',
    ]);
    expect(store.read()?.attemptId, _attempt);
    bloc.add(const FoundingFriendCheckoutRetryRequested());
    await Future<void>.delayed(Duration.zero);
    expect(repository.creates, [_attempt]);
  });

  test(
    'verified expiry rotates; later retries and reload use the rotated attempt',
    () async {
      final repository = _PaymentRepository(
        [
          left(const AppFailure.serviceUnavailable()),
          right(_checkout(_newSession)),
          right(_checkout(_newSession)),
        ],
        [right(_expired), right(_open), right(_open), right(_open)],
      );
      final store = _store();
      var rotations = 0;
      FoundingFriendCheckoutBloc createBloc() => FoundingFriendCheckoutBloc(
        repository: repository,
        pendingStore: store,
        createAttemptId: () {
          rotations++;
          return _replacement;
        },
      );
      final bloc = createBloc();
      expect((await _dispatch(bloc)).phase, FoundingFriendCheckoutPhase.failed);
      expect(store.read()?.attemptId, _replacement);
      expect(store.read()?.sessionId, isNull);
      expect((await _dispatch(bloc)).checkout?.sessionId, _newSession);
      await bloc.close();
      final reloaded = createBloc();
      addTearDown(reloaded.close);
      expect((await _dispatch(reloaded)).checkout?.sessionId, _newSession);
      expect(repository.creates, [_replacement, _replacement, _replacement]);
      expect(repository.emails, everyElement(_email));
      expect(rotations, 1);
      expect(store.read()?.sessionId, _newSession);
    },
  );

  test(
    'cancel retry never redirects to an expired replay from legacy data',
    () async {
      final repository = _PaymentRepository(
        [
          right(_checkout(_session)),
          right(_checkout(_newSession)),
        ],
        [right(_expired), right(_open)],
      );
      final bloc = FoundingFriendCheckoutBloc(
        repository: repository,
        pendingStore: _store(session: null),
        createAttemptId: () => _replacement,
      );
      addTearDown(bloc.close);
      final ready = <String>[];
      final subscription = bloc.stream.listen((state) {
        if (state.phase == FoundingFriendCheckoutPhase.ready) {
          ready.add(state.checkout!.sessionId);
        }
      });
      addTearDown(subscription.cancel);
      await _dispatch(bloc);
      expect(repository.calls, [
        'create:$_attempt',
        'verify:$_session',
        'create:$_replacement',
        'verify:$_newSession',
      ]);
      expect(ready, [_newSession]);
    },
  );

  test('failed creation replays and verifies the same attempt', () async {
    final repository = _PaymentRepository(
      [
        left(const AppFailure.serviceUnavailable()),
        right(_checkout(_session)),
      ],
      [right(_open)],
    );
    final store = _PendingStore();
    var attempts = 0;
    final bloc = FoundingFriendCheckoutBloc(
      repository: repository,
      pendingStore: store,
      createAttemptId: () {
        attempts++;
        return _attempt;
      },
    );
    addTearDown(bloc.close);
    expect(
      (await _dispatch(
        bloc,
        const FoundingFriendRegistrationConfirmed(_email),
      )).phase,
      FoundingFriendCheckoutPhase.failed,
    );
    expect(store.read()?.sessionId, isNull);
    expect((await _dispatch(bloc)).phase, FoundingFriendCheckoutPhase.ready);
    expect(repository.creates, [_attempt, _attempt]);
    expect(repository.verifications, [_session]);
    expect(attempts, 1);
  });

  test(
    'legacy pending data recovers and persists its Session before verification',
    () async {
      final response =
          Completer<Either<AppFailure, FoundingFriendPaymentVerification>>();
      final repository = _PaymentRepository(
        [right(_checkout(_session))],
        [response.future],
      );
      final store = _store(session: null);
      final bloc = FoundingFriendCheckoutBloc(
        repository: repository,
        pendingStore: store,
        createAttemptId: () => throw StateError('must not rotate'),
      );
      addTearDown(bloc.close);
      final finished = _dispatch(bloc);
      await bloc.stream.firstWhere(
        (state) => state.phase == FoundingFriendCheckoutPhase.verifying,
      );
      expect(store.read()?.sessionId, _session);
      response.complete(right(_open));
      expect((await finished).phase, FoundingFriendCheckoutPhase.ready);
      expect(repository.creates, [_attempt]);
    },
  );

  for (final status in [
    FoundingFriendPaymentStatus.confirmed,
    FoundingFriendPaymentStatus.refunded,
    FoundingFriendPaymentStatus.disputed,
    FoundingFriendPaymentStatus.invalid,
    FoundingFriendPaymentStatus.pending,
  ]) {
    for (final hasSession in [true, false]) {
      test(
        '$status with stored Session=$hasSession never creates a fresh attempt',
        () async {
          final verification = FoundingFriendPaymentVerification(
            status: status,
            purchaseReference: status == FoundingFriendPaymentStatus.confirmed
                ? 'FF-1234567890ABCDEF'
                : null,
          );
          final repository = _PaymentRepository(
            hasSession ? [] : [right(_checkout(_session))],
            [right(verification)],
          );
          final store = _store(session: hasSession ? _session : null);
          final bloc = FoundingFriendCheckoutBloc(
            repository: repository,
            pendingStore: store,
            createAttemptId: () => throw StateError('must not rotate'),
          );
          addTearDown(bloc.close);
          final result = await _dispatch(bloc);
          expect(result.phase, FoundingFriendCheckoutPhase.verified);
          expect(
            result.paymentStatus?.phase,
            FoundingFriendPaymentStatusState.verified(verification).phase,
          );
          expect(result.checkout, isNull);
          expect(repository.creates, hasSession ? isEmpty : [_attempt]);
          if (status == FoundingFriendPaymentStatus.confirmed) {
            expect(store.read(), isNull);
          }
          if (status != FoundingFriendPaymentStatus.pending) {
            bloc
              ..add(const FoundingFriendCheckoutRetryRequested())
              ..add(const FoundingFriendExpiredCheckoutRetryRequested());
            await Future<void>.delayed(Duration.zero);
            expect(repository.verifications, [_session]);
          }
        },
      );
    }
  }

  for (final failure in [
    const AppFailure.serviceUnavailable(),
    const AppFailure.unexpected(),
  ]) {
    test(
      'verification $failure preserves attempt and can recheck without '
      'creation',
      () async {
        final repository = _PaymentRepository([], [
          left(failure),
          right(
            const FoundingFriendPaymentVerification(
              status: FoundingFriendPaymentStatus.pending,
            ),
          ),
        ]);
        final store = _store();
        final bloc = FoundingFriendCheckoutBloc(
          repository: repository,
          pendingStore: store,
          createAttemptId: () => throw StateError('must not rotate'),
        );
        addTearDown(bloc.close);
        expect(
          (await _dispatch(bloc)).paymentStatus?.phase,
          FoundingFriendPaymentStatusPhase.unableToVerify,
        );
        expect(store.read()?.attemptId, _attempt);
        expect(
          (await _dispatch(bloc)).paymentStatus?.phase,
          FoundingFriendPaymentStatusPhase.pending,
        );
        expect(repository.creates, isEmpty);
        expect(repository.verifications, [_session, _session]);
      },
    );
  }

  test('mixed double clicks cannot overlap payment operations', () async {
    final verification =
        Completer<Either<AppFailure, FoundingFriendPaymentVerification>>();
    final creation = Completer<Either<AppFailure, FoundingFriendCheckout>>();
    final repository = _PaymentRepository(
      [creation.future],
      [verification.future, right(_open)],
    );
    var rotations = 0;
    final bloc = FoundingFriendCheckoutBloc(
      repository: repository,
      pendingStore: _store(),
      createAttemptId: () {
        rotations++;
        return _replacement;
      },
    );
    addTearDown(bloc.close);
    final finished = _dispatch(bloc);
    await bloc.stream.firstWhere(
      (state) => state.phase == FoundingFriendCheckoutPhase.verifying,
    );
    bloc
      ..add(const FoundingFriendCheckoutRetryRequested())
      ..add(const FoundingFriendExpiredCheckoutRetryRequested())
      ..add(const FoundingFriendRegistrationConfirmed(_email));
    await Future<void>.delayed(Duration.zero);
    final preparing = bloc.stream.firstWhere(
      (state) => state.phase == FoundingFriendCheckoutPhase.preparing,
    );
    verification.complete(right(_expired));
    await preparing;
    bloc
      ..add(const FoundingFriendExpiredCheckoutRetryRequested())
      ..add(const FoundingFriendCheckoutRetryRequested());
    await Future<void>.delayed(Duration.zero);
    creation.complete(right(_checkout(_newSession)));
    expect((await finished).checkout?.sessionId, _newSession);
    bloc
      ..add(const FoundingFriendCheckoutRedirectStarted())
      ..add(const FoundingFriendCheckoutRetryRequested())
      ..add(const FoundingFriendExpiredCheckoutRetryRequested());
    await Future<void>.delayed(Duration.zero);
    expect(repository.creates, [_replacement]);
    expect(repository.verifications, [_session, _newSession]);
    expect(rotations, 1);
  });

  test('expiry during idempotent replay is verified before redirect', () async {
    final repository = _PaymentRepository(
      [right(_checkout(_session)), right(_checkout(_newSession))],
      [right(_open), right(_expired), right(_open)],
    );
    final bloc = FoundingFriendCheckoutBloc(
      repository: repository,
      pendingStore: _store(),
      createAttemptId: () => _replacement,
    );
    addTearDown(bloc.close);
    expect((await _dispatch(bloc)).checkout?.sessionId, _newSession);
    expect(repository.creates, [_attempt, _replacement]);
  });

  test(
    'an expired replacement is never redirected or retried in a loop',
    () async {
      final repository = _PaymentRepository(
        [right(_checkout(_newSession))],
        [right(_expired), right(_expired)],
      );
      var rotations = 0;
      final bloc = FoundingFriendCheckoutBloc(
        repository: repository,
        pendingStore: _store(),
        createAttemptId: () {
          rotations++;
          return _replacement;
        },
      );
      addTearDown(bloc.close);
      final result = await _dispatch(bloc);
      expect(result.checkout, isNull);
      expect(
        result.paymentStatus?.phase,
        FoundingFriendPaymentStatusPhase.expired,
      );
      expect(rotations, 1);
    },
  );

  test('a different replayed Session never replaces a known Session', () async {
    final repository = _PaymentRepository(
      [right(_checkout(_newSession))],
      [right(_open)],
    );
    final store = _store();
    final bloc = FoundingFriendCheckoutBloc(
      repository: repository,
      pendingStore: store,
      createAttemptId: () => throw StateError('must not rotate'),
    );
    addTearDown(bloc.close);
    expect((await _dispatch(bloc)).phase, FoundingFriendCheckoutPhase.failed);
    expect(store.read()?.sessionId, _session);
  });

  test('missing tab state fails without payment work', () async {
    final repository = _PaymentRepository([]);
    final bloc = FoundingFriendCheckoutBloc(
      repository: repository,
      pendingStore: _PendingStore(),
    );
    addTearDown(bloc.close);
    expect(
      (await _dispatch(bloc)).phase,
      FoundingFriendCheckoutPhase.recoveryUnavailable,
    );
    expect(repository.calls, isEmpty);
  });

  test(
    'legacy verification failure retains the recovered Session for recheck',
    () async {
      final repository = _PaymentRepository(
        [right(_checkout(_session))],
        [
          left(const AppFailure.serviceUnavailable()),
          right(_open),
          right(_open),
        ],
      );
      final store = _store(session: null);
      final bloc = FoundingFriendCheckoutBloc(
        repository: repository,
        pendingStore: store,
        createAttemptId: () => throw StateError('must not rotate'),
      );
      addTearDown(bloc.close);
      expect(
        (await _dispatch(bloc)).paymentStatus?.phase,
        FoundingFriendPaymentStatusPhase.unableToVerify,
      );
      expect(store.read()?.sessionId, _session);
      // The next check completes payment instead of replaying creation.
      repository.verificationResults.clear();
      repository.verificationResults.add(
        right(
          const FoundingFriendPaymentVerification(
            status: FoundingFriendPaymentStatus.confirmed,
            purchaseReference: 'FF-1234567890ABCDEF',
          ),
        ),
      );
      expect(
        (await _dispatch(bloc)).paymentStatus?.phase,
        FoundingFriendPaymentStatusPhase.confirmed,
      );
      expect(repository.creates, [_attempt]);
      expect(store.read(), isNull);
    },
  );

  test('stale expired retry event rechecks the current open Session', () async {
    final repository = _PaymentRepository(
      [right(_checkout(_session))],
      [right(_open), right(_open)],
    );
    final bloc = FoundingFriendCheckoutBloc(
      repository: repository,
      pendingStore: _store(),
      createAttemptId: () => throw StateError('event alone must not rotate'),
    );
    addTearDown(bloc.close);
    expect(
      (await _dispatch(
        bloc,
        const FoundingFriendExpiredCheckoutRetryRequested(),
      )).checkout?.sessionId,
      _session,
    );
    expect(repository.creates, [_attempt]);
  });

  for (final status in [
    FoundingFriendPaymentStatus.confirmed,
    FoundingFriendPaymentStatus.pending,
    FoundingFriendPaymentStatus.refunded,
    FoundingFriendPaymentStatus.disputed,
    FoundingFriendPaymentStatus.invalid,
  ]) {
    test('Session becoming $status during replay is not redirected', () async {
      final repository = _PaymentRepository(
        [right(_checkout(_session))],
        [
          right(_open),
          right(
            FoundingFriendPaymentVerification(
              status: status,
              purchaseReference: status == FoundingFriendPaymentStatus.confirmed
                  ? 'FF-1234567890ABCDEF'
                  : null,
            ),
          ),
        ],
      );
      final bloc = FoundingFriendCheckoutBloc(
        repository: repository,
        pendingStore: _store(),
        createAttemptId: () => throw StateError('must not rotate'),
      );
      addTearDown(bloc.close);
      final result = await _dispatch(bloc);
      expect(result.phase, FoundingFriendCheckoutPhase.verified);
      expect(result.checkout, isNull);
      expect(repository.creates, [_attempt]);
    });
  }

  test('attempt generator produces UUIDv4-compatible values', () {
    expect(
      generateCheckoutAttemptId(),
      matches(
        RegExp(
          '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-'
          r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });
}

final class _PaymentRepository
    implements FoundingFriendPaymentRepositoryInterface {
  _PaymentRepository(this.results, [this.verificationResults = const []]);
  final List<FutureOr<Either<AppFailure, FoundingFriendCheckout>>> results;
  final List<FutureOr<Either<AppFailure, FoundingFriendPaymentVerification>>>
  verificationResults;
  final List<String> creates = [];
  final List<String> emails = [];
  final List<String> verifications = [];
  final List<String> calls = [];

  @override
  Future<Either<AppFailure, FoundingFriendCheckout>> createCheckout({
    required String email,
    required String attemptId,
  }) async {
    creates.add(attemptId);
    emails.add(email);
    calls.add('create:$attemptId');
    return results.removeAt(0);
  }

  @override
  Future<Either<AppFailure, FoundingFriendPaymentVerification>> verifyCheckout(
    String sessionId,
  ) async {
    verifications.add(sessionId);
    calls.add('verify:$sessionId');
    return verificationResults.removeAt(0);
  }
}

final class _PendingStore
    implements PendingFoundingFriendPaymentStoreInterface {
  PendingFoundingFriendPayment? value;
  @override
  void clear() => value = null;
  @override
  PendingFoundingFriendPayment? read() => value;
  @override
  void save(PendingFoundingFriendPayment payment) => value = payment;
}
