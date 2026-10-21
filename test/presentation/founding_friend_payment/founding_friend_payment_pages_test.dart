import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_checkout_bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_payment_status_bloc.dart';
import 'package:fun_app_landing_page/application/user_registration/founding_friend_registration_form_bloc/founding_friend_registration_form_bloc.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/founding_friend_payment_repository_interface.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/pending_founding_friend_payment_store_interface.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/founding_friend_registration_repository_interface.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/pages/founding_friend_payment_cancelled_page.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/pages/founding_friend_payment_return_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/founding_friend_page.dart';

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

  testWidgets(
    'registration transitions to Checkout and payment retry does not resubmit',
    (tester) async {
      final registrationRepository = _RegistrationRepository();
      final paymentRepository = _PaymentRepository([
        left(const AppFailure.serviceUnavailable()),
        right(checkout),
      ]);
      final pendingStore = _PendingStore();
      final redirects = <Uri>[];
      await _pump(
        tester,
        FoundingFriendPage(
          createBloc: () =>
              FoundingFriendRegistrationFormBloc(registrationRepository),
          createCheckoutBloc: () => FoundingFriendCheckoutBloc(
            repository: paymentRepository,
            pendingStore: pendingStore,
            createAttemptId: () => attemptId,
          ),
          onCheckoutRedirect: (uri) async {
            redirects.add(uri);
            return false;
          },
        ),
      );

      final context = tester.element(
        find.byKey(const Key('userSignUpPage-foundingFriend')),
      );
      final registrationBloc =
          context.read<FoundingFriendRegistrationFormBloc>()
            ..add(
              const FoundingFriendRegistrationFormEvent.firstNameChanged(
                'Alex',
              ),
            )
            ..add(
              const FoundingFriendRegistrationFormEvent.lastNameChanged(
                'Morgan',
              ),
            )
            ..add(
              const FoundingFriendRegistrationFormEvent.emailChanged(
                'founder@example.com',
              ),
            )
            ..add(const FoundingFriendRegistrationFormEvent.ageChanged('31'))
            ..add(
              const FoundingFriendRegistrationFormEvent.countryChanged(
                'United Kingdom',
              ),
            );
      await tester.pump();
      registrationBloc.add(
        const FoundingFriendRegistrationFormEvent.submitted(),
      );
      await tester.pumpAndSettle();

      expect(registrationRepository.submissions, hasLength(1));
      expect(paymentRepository.creates, hasLength(1));
      expect(find.text('Checkout could not be prepared'), findsOneWidget);
      expect(
        find.byKey(const Key('userSignUpForm-foundingFriend')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const Key('foundingFriendCheckoutRetry')),
      );
      await tester.pumpAndSettle();

      expect(registrationRepository.submissions, hasLength(1));
      expect(paymentRepository.creates, [
        (email: 'founder@example.com', attemptId: attemptId),
        (email: 'founder@example.com', attemptId: attemptId),
      ]);
      expect(redirects, [checkout.checkoutUrl]);
    },
  );

  testWidgets('cancelled page and reload never auto-create Checkout', (
    tester,
  ) async {
    final repository = _PaymentRepository([right(checkout)]);
    final store = _PendingStore()
      ..value = const PendingFoundingFriendPayment(
        email: 'founder@example.com',
        attemptId: attemptId,
      );

    Widget page() => FoundingFriendPaymentCancelledPage(
      createBloc: () => FoundingFriendCheckoutBloc(
        repository: repository,
        pendingStore: store,
      ),
      onCheckoutRedirect: (_) async => false,
    );

    await _pump(tester, page());
    expect(repository.creates, isEmpty);
    expect(find.text('Checkout cancelled'), findsOneWidget);

    await _pump(tester, page());
    expect(repository.creates, isEmpty);

    await tester.tap(find.byKey(const Key('foundingFriendCheckoutRetry')));
    await tester.pumpAndSettle();
    expect(repository.creates, hasLength(1));
  });

  testWidgets('paid return shows and copies only the purchase reference', (
    tester,
  ) async {
    MethodCall? clipboardCall;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        clipboardCall = call;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final store = _PendingStore()
      ..value = const PendingFoundingFriendPayment(
        email: 'founder@example.com',
        attemptId: attemptId,
      );
    await _pump(
      tester,
      FoundingFriendPaymentReturnPage(
        sessionId: checkout.sessionId,
        createBloc: () => FoundingFriendPaymentStatusBloc(
          repository: const _VerificationRepository(
            FoundingFriendPaymentVerification(
              status: FoundingFriendPaymentStatus.confirmed,
              purchaseReference: 'FF-1234567890ABCDEF',
            ),
          ),
          pendingStore: store,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Payment confirmed'), findsOneWidget);
    expect(find.text('FF-1234567890ABCDEF'), findsOneWidget);
    expect(
      find.textContaining('does not activate a Fun App membership yet'),
      findsOneWidget,
    );
    expect(find.textContaining('founder@example.com'), findsNothing);
    expect(store.value, isNull);

    await tester.tap(
      find.byKey(const Key('foundingFriendCopyPurchaseReference')),
    );
    await tester.pumpAndSettle();
    expect(clipboardCall?.method, 'Clipboard.setData');
    expect(clipboardCall?.arguments, {'text': 'FF-1234567890ABCDEF'});
    expect(find.text('Purchase reference copied'), findsOneWidget);
  });

  testWidgets(
    'expired return creates a new payment attempt without registration',
    (tester) async {
      const replacementAttemptId = 'd9428888-122b-4c5f-8e6a-cc2eeb112233';
      final repository = _ExpiredPaymentRepository(checkout);
      final store = _PendingStore()
        ..value = const PendingFoundingFriendPayment(
          email: 'founder@example.com',
          attemptId: attemptId,
        );
      final redirects = <Uri>[];
      await _pump(
        tester,
        FoundingFriendPaymentReturnPage(
          sessionId: checkout.sessionId,
          createBloc: () => FoundingFriendPaymentStatusBloc(
            repository: repository,
            pendingStore: store,
          ),
          createCheckoutBloc: () => FoundingFriendCheckoutBloc(
            repository: repository,
            pendingStore: store,
            createAttemptId: () => replacementAttemptId,
          ),
          onCheckoutRedirect: (uri) async {
            redirects.add(uri);
            return false;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Checkout expired'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('foundingFriendExpiredCheckoutRetry')),
      );
      await tester.pumpAndSettle();

      expect(repository.creates, [
        (email: 'founder@example.com', attemptId: replacementAttemptId),
      ]);
      expect(store.value?.attemptId, replacementAttemptId);
      expect(redirects, [checkout.checkoutUrl]);
    },
  );

  testWidgets('pending and unavailable verification can be retried safely', (
    tester,
  ) async {
    final repository = _SequencedVerificationRepository([
      left(const AppFailure.serviceUnavailable()),
      right(
        const FoundingFriendPaymentVerification(
          status: FoundingFriendPaymentStatus.pending,
        ),
      ),
    ]);
    await _pump(
      tester,
      FoundingFriendPaymentReturnPage(
        sessionId: checkout.sessionId,
        createBloc: () => FoundingFriendPaymentStatusBloc(
          repository: repository,
          pendingStore: _PendingStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unable to verify payment'), findsOneWidget);

    await tester.tap(find.byKey(const Key('foundingFriendVerificationRetry')));
    await tester.pumpAndSettle();
    expect(find.text('Payment pending'), findsOneWidget);
    expect(repository.verifications, 2);
  });
}

Future<void> _pump(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(390, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: page,
    ),
  );
  await tester.pump();
}

final class _RegistrationRepository
    implements FoundingFriendRegistrationRepositoryInterface {
  final List<FoundingFriendRegistration> submissions = [];

  @override
  Future<Either<AppFailure, Unit>> submitFoundingFriendRegistration(
    FoundingFriendRegistration registration,
  ) async {
    submissions.add(registration);
    return right(unit);
  }
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

final class _VerificationRepository
    implements FoundingFriendPaymentRepositoryInterface {
  const _VerificationRepository(this.verification);

  final FoundingFriendPaymentVerification verification;

  @override
  Future<Either<AppFailure, FoundingFriendCheckout>> createCheckout({
    required String email,
    required String attemptId,
  }) async => left(const AppFailure.unexpected());

  @override
  Future<Either<AppFailure, FoundingFriendPaymentVerification>> verifyCheckout(
    String sessionId,
  ) async => right(verification);
}

final class _SequencedVerificationRepository
    implements FoundingFriendPaymentRepositoryInterface {
  _SequencedVerificationRepository(this.results);

  final List<Either<AppFailure, FoundingFriendPaymentVerification>> results;
  int verifications = 0;

  @override
  Future<Either<AppFailure, FoundingFriendCheckout>> createCheckout({
    required String email,
    required String attemptId,
  }) async => left(const AppFailure.unexpected());

  @override
  Future<Either<AppFailure, FoundingFriendPaymentVerification>> verifyCheckout(
    String sessionId,
  ) async {
    verifications += 1;
    return results.removeAt(0);
  }
}

final class _ExpiredPaymentRepository
    implements FoundingFriendPaymentRepositoryInterface {
  _ExpiredPaymentRepository(this.checkout);

  final FoundingFriendCheckout checkout;
  final List<({String email, String attemptId})> creates = [];

  @override
  Future<Either<AppFailure, FoundingFriendCheckout>> createCheckout({
    required String email,
    required String attemptId,
  }) async {
    creates.add((email: email, attemptId: attemptId));
    return right(checkout);
  }

  @override
  Future<Either<AppFailure, FoundingFriendPaymentVerification>> verifyCheckout(
    String sessionId,
  ) async => right(
    const FoundingFriendPaymentVerification(
      status: FoundingFriendPaymentStatus.expired,
    ),
  );
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
