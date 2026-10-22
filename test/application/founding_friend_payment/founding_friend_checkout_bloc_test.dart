import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_checkout_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/founding_friend_payment_repository_interface.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/pending_founding_friend_payment_store_interface.dart';

void main() {
  const attemptId = '123e4567-e89b-42d3-a456-426614174000';
  final checkout = FoundingFriendCheckout(
    checkoutUrl: Uri(
      scheme: 'https',
      host: 'checkout.stripe.com',
      path: '/c/pay/safe',
    ),
    sessionId: 'cs_test_abcdefghijklmnopqrstuvwxyz123456',
  );

  blocTest<FoundingFriendCheckoutBloc, FoundingFriendCheckoutState>(
    'registration success stores one attempt and prepares Checkout',
    build: () {
      final repository = _PaymentRepository([right(checkout)]);
      final store = _PendingStore();
      return FoundingFriendCheckoutBloc(
        repository: repository,
        pendingStore: store,
        createAttemptId: () => attemptId,
      );
    },
    act: (bloc) => bloc.add(
      const FoundingFriendRegistrationConfirmed('founder@example.com'),
    ),
    expect: () => [
      isA<FoundingFriendCheckoutState>().having(
        (state) => state.phase,
        'phase',
        FoundingFriendCheckoutPhase.preparing,
      ),
      isA<FoundingFriendCheckoutState>()
          .having(
            (state) => state.phase,
            'phase',
            FoundingFriendCheckoutPhase.ready,
          )
          .having((state) => state.checkout, 'checkout', same(checkout)),
    ],
  );

  test('retry reuses email and attempt ID without registration work', () async {
    final repository = _PaymentRepository([
      left(const AppFailure.serviceUnavailable()),
      right(checkout),
    ]);
    final store = _PendingStore();
    final bloc =
        FoundingFriendCheckoutBloc(
          repository: repository,
          pendingStore: store,
          createAttemptId: () => attemptId,
        )..add(
          const FoundingFriendRegistrationConfirmed('founder@example.com'),
        );
    await bloc.stream.firstWhere(
      (state) => state.phase == FoundingFriendCheckoutPhase.failed,
    );
    bloc.add(const FoundingFriendCheckoutRetryRequested());
    await bloc.stream.firstWhere(
      (state) => state.phase == FoundingFriendCheckoutPhase.ready,
    );

    expect(repository.creates, [
      (email: 'founder@example.com', attemptId: attemptId),
      (email: 'founder@example.com', attemptId: attemptId),
    ]);
    expect(store.saved, hasLength(1));
    await bloc.close();
  });

  test(
    'cancel-page retry restores tab-scoped state only on user action',
    () async {
      final repository = _PaymentRepository([right(checkout)]);
      final store = _PendingStore()
        ..saved.add(
          const PendingFoundingFriendPayment(
            email: 'founder@example.com',
            attemptId: attemptId,
          ),
        );
      final bloc = FoundingFriendCheckoutBloc(
        repository: repository,
        pendingStore: store,
      );

      await Future<void>.delayed(Duration.zero);
      expect(repository.creates, isEmpty);
      bloc.add(const FoundingFriendCheckoutRetryRequested());
      await bloc.stream.firstWhere(
        (state) => state.phase == FoundingFriendCheckoutPhase.ready,
      );
      expect(repository.creates, hasLength(1));
      await bloc.close();
    },
  );

  test('expired Checkout retry rotates only the payment attempt', () async {
    const replacementAttemptId = 'd9428888-122b-4c5f-8e6a-cc2eeb112233';
    final repository = _PaymentRepository([right(checkout)]);
    final store = _PendingStore()
      ..saved.add(
        const PendingFoundingFriendPayment(
          email: 'founder@example.com',
          attemptId: attemptId,
        ),
      );
    final bloc = FoundingFriendCheckoutBloc(
      repository: repository,
      pendingStore: store,
      createAttemptId: () => replacementAttemptId,
    )..add(const FoundingFriendExpiredCheckoutRetryRequested());
    await bloc.stream.firstWhere(
      (state) => state.phase == FoundingFriendCheckoutPhase.ready,
    );

    expect(repository.creates, [
      (email: 'founder@example.com', attemptId: replacementAttemptId),
    ]);
    expect(store.saved.last.attemptId, replacementAttemptId);
    expect(store.saved, hasLength(2));
    await bloc.close();
  });

  test('expired Checkout retry is accepted only once', () async {
    const replacementAttemptId = 'd9428888-122b-4c5f-8e6a-cc2eeb112233';
    final repository = _PaymentRepository([right(checkout)]);
    final store = _PendingStore()
      ..saved.add(
        const PendingFoundingFriendPayment(
          email: 'founder@example.com',
          attemptId: attemptId,
        ),
      );
    final bloc =
        FoundingFriendCheckoutBloc(
            repository: repository,
            pendingStore: store,
            createAttemptId: () => replacementAttemptId,
          )
          ..add(const FoundingFriendExpiredCheckoutRetryRequested())
          ..add(const FoundingFriendExpiredCheckoutRetryRequested());
    await bloc.stream.firstWhere(
      (state) => state.phase == FoundingFriendCheckoutPhase.ready,
    );

    expect(repository.creates, [
      (email: 'founder@example.com', attemptId: replacementAttemptId),
    ]);
    expect(store.saved, hasLength(2));
    await bloc.close();
  });

  test('attempt generator produces UUIDv4-compatible values', () {
    final value = generateCheckoutAttemptId();
    expect(
      value,
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
  _PaymentRepository(this.results);

  final List<Either<AppFailure, FoundingFriendCheckout>> results;
  final List<({String email, String attemptId})> creates = [];

  @override
  Future<Either<AppFailure, FoundingFriendCheckout>> createCheckout({
    required String email,
    required String attemptId,
  }) async {
    creates.add((email: email, attemptId: attemptId));
    return results.removeAt(0);
  }

  @override
  Future<Either<AppFailure, FoundingFriendPaymentVerification>> verifyCheckout(
    String sessionId,
  ) async => left(const AppFailure.unexpected());
}

final class _PendingStore
    implements PendingFoundingFriendPaymentStoreInterface {
  final List<PendingFoundingFriendPayment> saved = [];

  @override
  void clear() => saved.clear();

  @override
  PendingFoundingFriendPayment? read() => saved.lastOrNull;

  @override
  void save(PendingFoundingFriendPayment payment) => saved.add(payment);
}
