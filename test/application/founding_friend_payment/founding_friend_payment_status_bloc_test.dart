import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_payment_status_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/founding_friend_payment_repository_interface.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/pending_founding_friend_payment_store_interface.dart';

void main() {
  const sessionId = 'cs_test_abcdefghijklmnopqrstuvwxyz123456';

  for (final entry
      in <FoundingFriendPaymentStatus, FoundingFriendPaymentStatusPhase>{
        FoundingFriendPaymentStatus.pending:
            FoundingFriendPaymentStatusPhase.pending,
        FoundingFriendPaymentStatus.expired:
            FoundingFriendPaymentStatusPhase.expired,
        FoundingFriendPaymentStatus.refunded:
            FoundingFriendPaymentStatusPhase.refunded,
        FoundingFriendPaymentStatus.disputed:
            FoundingFriendPaymentStatusPhase.disputed,
        FoundingFriendPaymentStatus.invalid:
            FoundingFriendPaymentStatusPhase.invalid,
      }.entries) {
    blocTest<FoundingFriendPaymentStatusBloc, FoundingFriendPaymentStatusState>(
      'maps ${entry.key.name} without exposing a reference',
      build: () => FoundingFriendPaymentStatusBloc(
        repository: _VerificationRepository(
          right(FoundingFriendPaymentVerification(status: entry.key)),
        ),
        pendingStore: _PendingStore(),
      ),
      act: (bloc) => bloc.add(
        const FoundingFriendPaymentVerificationRequested(sessionId),
      ),
      expect: () => [
        isA<FoundingFriendPaymentStatusState>().having(
          (state) => state.phase,
          'phase',
          FoundingFriendPaymentStatusPhase.verifying,
        ),
        isA<FoundingFriendPaymentStatusState>()
            .having((state) => state.phase, 'phase', entry.value)
            .having(
              (state) => state.purchaseReference,
              'purchaseReference',
              isNull,
            ),
      ],
    );
  }

  test(
    'paid verification clears pending state and retains reference',
    () async {
      final store = _PendingStore()..hasValue = true;
      final bloc = FoundingFriendPaymentStatusBloc(
        repository: _VerificationRepository(
          right(
            const FoundingFriendPaymentVerification(
              status: FoundingFriendPaymentStatus.confirmed,
              purchaseReference: 'FF-1234567890ABCDEF',
            ),
          ),
        ),
        pendingStore: store,
      )..add(const FoundingFriendPaymentVerificationRequested(sessionId));
      final result = await bloc.stream.firstWhere(
        (state) => state.phase == FoundingFriendPaymentStatusPhase.confirmed,
      );

      expect(result.purchaseReference, 'FF-1234567890ABCDEF');
      expect(store.hasValue, isFalse);
      await bloc.close();
    },
  );

  blocTest<FoundingFriendPaymentStatusBloc, FoundingFriendPaymentStatusState>(
    'provider failure becomes retryable unable-to-verify state',
    build: () => FoundingFriendPaymentStatusBloc(
      repository: _VerificationRepository(
        left(const AppFailure.serviceUnavailable()),
      ),
      pendingStore: _PendingStore(),
    ),
    act: (bloc) => bloc.add(
      const FoundingFriendPaymentVerificationRequested(sessionId),
    ),
    expect: () => [
      isA<FoundingFriendPaymentStatusState>().having(
        (state) => state.phase,
        'phase',
        FoundingFriendPaymentStatusPhase.verifying,
      ),
      isA<FoundingFriendPaymentStatusState>().having(
        (state) => state.phase,
        'phase',
        FoundingFriendPaymentStatusPhase.unableToVerify,
      ),
    ],
  );
}

final class _VerificationRepository
    implements FoundingFriendPaymentRepositoryInterface {
  const _VerificationRepository(this.result);

  final Either<AppFailure, FoundingFriendPaymentVerification> result;

  @override
  Future<Either<AppFailure, FoundingFriendCheckout>> createCheckout({
    required String email,
    required String attemptId,
  }) async => left(const AppFailure.unexpected());

  @override
  Future<Either<AppFailure, FoundingFriendPaymentVerification>> verifyCheckout(
    String sessionId,
  ) async => result;
}

final class _PendingStore
    implements PendingFoundingFriendPaymentStoreInterface {
  bool hasValue = false;

  @override
  void clear() => hasValue = false;

  @override
  PendingFoundingFriendPayment? read() => null;

  @override
  void save(PendingFoundingFriendPayment payment) => hasValue = true;
}
