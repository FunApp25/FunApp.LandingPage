import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_checkout_bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_payment_status_bloc.dart';
import 'package:fun_app_landing_page/application/user_registration/founding_friend_registration_form_bloc/founding_friend_registration_form_bloc.dart';
import 'package:fun_app_landing_page/core/config/app_environment.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/domain/core/failures/app_failure.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_checkout.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/founding_friend_payment_verification.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/entities/pending_founding_friend_payment.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/founding_friend_payment_repository_interface.dart';
import 'package:fun_app_landing_page/domain/founding_friend_payment/pending_founding_friend_payment_store_interface.dart';
import 'package:fun_app_landing_page/domain/user_registration/entities/founding_friend_registration.dart';
import 'package:fun_app_landing_page/domain/user_registration/founding_friend_registration_repository_interface.dart';
import 'package:fun_app_landing_page/l10n/app_localizations.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_theme.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/pages/founding_friend_payment_cancelled_page.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/pages/founding_friend_payment_return_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/founding_friend_page.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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
      final preparation =
          Completer<Either<AppFailure, FoundingFriendCheckout>>();
      final paymentRepository = _PaymentRepository([
        preparation.future,
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
      await tester.pump();
      await tester.pump();
      expect(find.text('Preparing secure Checkout'), findsOneWidget);
      expect(find.text('Payment confirmed'), findsNothing);
      expect(
        find.byKey(const Key('foundingFriendPaymentSameEmailReminder')),
        findsNothing,
      );
      preparation.complete(left(const AppFailure.serviceUnavailable()));
      await tester.pumpAndSettle();

      expect(registrationRepository.submissions, hasLength(1));
      expect(paymentRepository.creates, hasLength(1));
      expect(find.text("We couldn't open checkout"), findsOneWidget);
      expect(
        find.text(
          "Your registration step is complete, but payment hasn't been "
          'confirmed. You can try again without filling in the form again '
          'in this browser tab.',
        ),
        findsOneWidget,
      );
      expect(find.text('Try checkout again'), findsOneWidget);
      expect(find.text('Payment confirmed'), findsNothing);
      expect(
        find.byKey(const Key('foundingFriendPaymentSameEmailReminder')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('foundingFriendPurchaseReference')),
        findsNothing,
      );
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

  testWidgets(
    'cancel recovery is inert after reload and blocks double clicks while '
    'verifying',
    (tester) async {
      final verification =
          Completer<Either<AppFailure, FoundingFriendPaymentVerification>>();
      final creation = Completer<Either<AppFailure, FoundingFriendCheckout>>();
      final repository = _RecoveryRepository(
        [creation.future],
        [
          verification.future,
          right(
            const FoundingFriendPaymentVerification(
              status: FoundingFriendPaymentStatus.pending,
              canResumeCheckout: true,
            ),
          ),
        ],
      );
      final store = _PendingStore()
        ..value = PendingFoundingFriendPayment(
          email: 'founder@example.com',
          attemptId: attemptId,
          sessionId: checkout.sessionId,
        );
      final redirects = <Uri>[];
      Widget page() => FoundingFriendPaymentCancelledPage(
        createBloc: () => FoundingFriendCheckoutBloc(
          repository: repository,
          pendingStore: store,
          createAttemptId: () =>
              throw StateError('open Session must retain attempt'),
        ),
        onCheckoutRedirect: (uri) async {
          redirects.add(uri);
          return false;
        },
      );
      await _pump(tester, page());
      await tester.pumpWidget(const SizedBox.shrink());
      await _pump(tester, page());
      expect(repository.verifications, isEmpty);
      expect(repository.creates, isEmpty);
      final retry = find.byKey(const Key('foundingFriendCheckoutRetry'));
      await tester.tap(retry);
      await tester.tap(retry);
      await tester.pump();
      expect(find.text('Verifying your payment'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(retry, findsNothing);
      expect(redirects, isEmpty);
      verification.complete(
        right(
          const FoundingFriendPaymentVerification(
            status: FoundingFriendPaymentStatus.pending,
            canResumeCheckout: true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Preparing secure Checkout'), findsOneWidget);
      creation.complete(right(checkout));
      await tester.pumpAndSettle();
      expect(repository.creates, [attemptId]);
      expect(repository.verifications, [
        checkout.sessionId,
        checkout.sessionId,
      ]);
      expect(redirects, [checkout.checkoutUrl]);
      expect(store.value?.sessionId, checkout.sessionId);
    },
  );

  testWidgets(
    'cancel expiry rotates once and repeated retry uses the new attempt',
    (tester) async {
      const replacementAttemptId = 'd9428888-122b-4c5f-8e6a-cc2eeb112233';
      const oldSession = 'cs_test_originalExpiredSession123456';
      final creation = Completer<Either<AppFailure, FoundingFriendCheckout>>();
      final repository = _RecoveryRepository(
        [creation.future, right(checkout)],
        [
          right(
            const FoundingFriendPaymentVerification(
              status: FoundingFriendPaymentStatus.expired,
            ),
          ),
          for (var i = 0; i < 3; i++)
            right(
              const FoundingFriendPaymentVerification(
                status: FoundingFriendPaymentStatus.pending,
                canResumeCheckout: true,
              ),
            ),
        ],
      );
      final store = _PendingStore()
        ..value = const PendingFoundingFriendPayment(
          email: 'founder@example.com',
          attemptId: attemptId,
          sessionId: oldSession,
        );
      var rotations = 0;
      final redirects = <Uri>[];
      await _pump(
        tester,
        FoundingFriendPaymentCancelledPage(
          createBloc: () => FoundingFriendCheckoutBloc(
            repository: repository,
            pendingStore: store,
            createAttemptId: () {
              rotations++;
              return replacementAttemptId;
            },
          ),
          onCheckoutRedirect: (uri) async {
            redirects.add(uri);
            return false;
          },
        ),
      );
      final retry = find.byKey(const Key('foundingFriendCheckoutRetry'));
      await tester.tap(retry);
      await tester.tap(retry);
      await tester.pump();
      expect(repository.creates, [replacementAttemptId]);
      expect(redirects, isEmpty);
      creation.complete(right(checkout));
      await tester.pumpAndSettle();
      expect(repository.creates, [replacementAttemptId]);
      expect(store.value?.sessionId, checkout.sessionId);
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(repository.creates, [replacementAttemptId, replacementAttemptId]);
      expect(rotations, 1);
      expect(redirects, [checkout.checkoutUrl, checkout.checkoutUrl]);
      expect(repository.verifications, [
        oldSession,
        checkout.sessionId,
        checkout.sessionId,
        checkout.sessionId,
      ]);
    },
  );

  for (final entry in <FoundingFriendPaymentStatus, String>{
    FoundingFriendPaymentStatus.confirmed: 'Payment confirmed',
    FoundingFriendPaymentStatus.pending: 'Payment pending',
    FoundingFriendPaymentStatus.refunded: 'Payment refunded',
    FoundingFriendPaymentStatus.disputed: 'Payment disputed',
    FoundingFriendPaymentStatus.invalid: 'Payment could not be confirmed',
  }.entries) {
    testWidgets(
      'cancel recovery shows verified ${entry.key.name} without creating '
      'Checkout',
      (tester) async {
        final repository = _RecoveryRepository([], [
          right(
            FoundingFriendPaymentVerification(
              status: entry.key,
              purchaseReference:
                  entry.key == FoundingFriendPaymentStatus.confirmed
                  ? 'FF-1234567890ABCDEF'
                  : null,
            ),
          ),
        ]);
        final store = _PendingStore()
          ..value = PendingFoundingFriendPayment(
            email: 'founder@example.com',
            attemptId: attemptId,
            sessionId: checkout.sessionId,
          );
        final redirects = <Uri>[];
        await _pump(
          tester,
          FoundingFriendPaymentCancelledPage(
            createBloc: () => FoundingFriendCheckoutBloc(
              repository: repository,
              pendingStore: store,
            ),
            onCheckoutRedirect: (uri) async {
              redirects.add(uri);
              return true;
            },
          ),
        );
        await tester.tap(find.byKey(const Key('foundingFriendCheckoutRetry')));
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byKey(const Key('foundingFriendPaymentHeading'))),
        );
        final title = switch (entry.key) {
          FoundingFriendPaymentStatus.confirmed =>
            l10n.foundingFriendPaymentConfirmedTitle,
          FoundingFriendPaymentStatus.pending =>
            l10n.foundingFriendPaymentPendingTitle,
          FoundingFriendPaymentStatus.refunded =>
            l10n.foundingFriendPaymentRefundedTitle,
          FoundingFriendPaymentStatus.disputed =>
            l10n.foundingFriendPaymentDisputedTitle,
          _ => l10n.foundingFriendPaymentInvalidTitle,
        };
        expect(find.text(title), findsOneWidget);
        expect(repository.creates, isEmpty);
        expect(redirects, isEmpty);
        expect(
          find.byKey(const Key('foundingFriendCheckoutRetry')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('foundingFriendPurchaseReference')),
          entry.key == FoundingFriendPaymentStatus.confirmed
              ? findsOneWidget
              : findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'cancel verification failure is localized and retryable at 320px and '
      '2x text in $locale',
      (tester) async {
        final repository = _RecoveryRepository([], [
          left(const AppFailure.serviceUnavailable()),
          right(
            const FoundingFriendPaymentVerification(
              status: FoundingFriendPaymentStatus.pending,
            ),
          ),
        ]);
        final store = _PendingStore()
          ..value = PendingFoundingFriendPayment(
            email: 'founder@example.com',
            attemptId: attemptId,
            sessionId: checkout.sessionId,
          );
        await _pump(
          tester,
          FoundingFriendPaymentCancelledPage(
            createBloc: () => FoundingFriendCheckoutBloc(
              repository: repository,
              pendingStore: store,
              createAttemptId: () =>
                  throw StateError('verification failure must retain attempt'),
            ),
          ),
          width: 320,
          textScale: 2,
          locale: locale,
        );
        final checkoutRetry = find.byKey(
          const Key('foundingFriendCheckoutRetry'),
        );
        await tester.ensureVisible(checkoutRetry);
        await tester.tap(checkoutRetry);
        await tester.pumpAndSettle();
        final retry = find.byKey(const Key('foundingFriendVerificationRetry'));
        final l10n = AppLocalizations.of(tester.element(retry));
        expect(
          find.text(l10n.foundingFriendPaymentUnableTitle),
          findsOneWidget,
        );
        expect(
          find.text(l10n.foundingFriendPaymentConfirmedTitle),
          findsNothing,
        );
        final semantics = tester.ensureSemantics();
        expect(
          tester.getSemantics(retry),
          matchesSemantics(
            isButton: true,
            hasTapAction: true,
            hasFocusAction: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            label: l10n.foundingFriendPaymentRetryVerification,
          ),
        );
        semantics.dispose();
        for (final text in [
          l10n.foundingFriendPaymentUnableTitle,
          l10n.foundingFriendPaymentUnableBody,
          l10n.foundingFriendPaymentRetryVerification,
        ]) {
          final paragraph = tester.renderObject<RenderParagraph>(
            find.text(text),
          );
          expect(paragraph.didExceedMaxLines, isFalse);
          expect(paragraph.maxLines, isNull);
        }
        await tester.ensureVisible(retry);
        await tester.tap(retry);
        await tester.pumpAndSettle();
        expect(
          find.text(l10n.foundingFriendPaymentPendingTitle),
          findsOneWidget,
        );
        expect(repository.creates, isEmpty);
        expect(store.value?.attemptId, attemptId);
        expect(tester.takeException(), isNull);
      },
    );
  }

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
          sessionId: 'cs_test_originalExpiredSession123456',
        );
      final redirects = <Uri>[];
      await _pump(
        tester,
        FoundingFriendPaymentReturnPage(
          sessionId: 'cs_test_originalExpiredSession123456',
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
    final verification =
        Completer<Either<AppFailure, FoundingFriendPaymentVerification>>();
    final repository = _SequencedVerificationRepository([
      verification.future,
      right(
        const FoundingFriendPaymentVerification(
          status: FoundingFriendPaymentStatus.pending,
        ),
      ),
      right(
        const FoundingFriendPaymentVerification(
          status: FoundingFriendPaymentStatus.confirmed,
          purchaseReference: 'FF-1234567890ABCDEF',
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
    expect(find.text('Verifying your payment'), findsOneWidget);
    expect(find.text('Payment confirmed'), findsNothing);
    expect(
      find.byKey(const Key('foundingFriendPurchaseReference')),
      findsNothing,
    );
    verification.complete(left(const AppFailure.serviceUnavailable()));
    await tester.pumpAndSettle();
    expect(find.text('Unable to verify payment'), findsOneWidget);

    await tester.tap(find.byKey(const Key('foundingFriendVerificationRetry')));
    await tester.pumpAndSettle();
    expect(find.text('Payment pending'), findsOneWidget);
    expect(find.text('Payment confirmed'), findsNothing);
    expect(
      find.byKey(const Key('foundingFriendPurchaseReference')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('foundingFriendPaymentSameEmailReminder')),
      findsNothing,
    );
    expect(repository.verifications, 2);

    await tester.tap(find.byKey(const Key('foundingFriendVerificationRetry')));
    await tester.pumpAndSettle();
    expect(find.text('Payment confirmed'), findsOneWidget);
    expect(find.text('FF-1234567890ABCDEF'), findsOneWidget);
    expect(
      find.byKey(const Key('foundingFriendPaymentSameEmailReminder')),
      findsOneWidget,
    );
    expect(repository.verifications, 3);
  });

  for (final environment in [
    AppEnvironment.staging,
    AppEnvironment.production,
  ]) {
    testWidgets('${environment.name} uses the same checkout failure UI', (
      tester,
    ) async {
      final client = MockClient((_) async => http.Response('', 404));
      configureDependencies(
        environment,
        stagingHttpClient: client,
        productionHttpClient: client,
      );
      addTearDown(getIt.reset);
      final store = _PendingStore()
        ..value = const PendingFoundingFriendPayment(
          email: 'founder@example.com',
          attemptId: attemptId,
        );
      await _pump(
        tester,
        FoundingFriendPaymentCancelledPage(
          createBloc: () => FoundingFriendCheckoutBloc(
            repository: getIt<FoundingFriendPaymentRepositoryInterface>(),
            pendingStore: store,
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('foundingFriendCheckoutRetry')));
      await tester.pumpAndSettle();
      expect(find.text("We couldn't open checkout"), findsOneWidget);
      expect(find.text('Try checkout again'), findsOneWidget);
      expect(find.text('Payment confirmed'), findsNothing);
      expect(
        find.byKey(const Key('foundingFriendPaymentSameEmailReminder')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in AppLocalizations.supportedLocales) {
    for (final width in [320.0, 390.0, 599.0, 600.0, 768.0, 1440.0]) {
      testWidgets(
        'localized checkout failure fits $locale at $width and 2x text',
        (
          tester,
        ) async {
          final repository = _PaymentRepository([
            left(const AppFailure.serviceUnavailable()),
          ]);
          final store = _PendingStore()
            ..value = const PendingFoundingFriendPayment(
              email: 'founder@example.com',
              attemptId: attemptId,
            );
          await _pump(
            tester,
            FoundingFriendPaymentCancelledPage(
              createBloc: () => FoundingFriendCheckoutBloc(
                repository: repository,
                pendingStore: store,
              ),
            ),
            width: width,
            locale: locale,
            textScale: 2,
          );
          final retry = find.byKey(const Key('foundingFriendCheckoutRetry'));
          await tester.ensureVisible(retry);
          await tester.tap(retry);
          await tester.pumpAndSettle();
          final l10n = AppLocalizations.of(tester.element(retry));
          expect(
            find.text(l10n.foundingFriendPaymentPreparationFailedTitle),
            findsOneWidget,
          );
          expect(
            find.text(l10n.foundingFriendPaymentPreparationFailedBody),
            findsOneWidget,
          );
          expect(
            find.text(l10n.foundingFriendPaymentRetryCheckout),
            findsOneWidget,
          );
          expect(
            find.text(l10n.foundingFriendPaymentConfirmedTitle),
            findsNothing,
          );
          expect(
            find.text(l10n.foundingFriendPaymentSameEmailReminder),
            findsNothing,
          );
          for (final text in [
            l10n.foundingFriendPaymentPreparationFailedTitle,
            l10n.foundingFriendPaymentPreparationFailedBody,
            l10n.foundingFriendPaymentRetryCheckout,
          ]) {
            final paragraph = tester.renderObject<RenderParagraph>(
              find.text(text),
            );
            expect(paragraph.didExceedMaxLines, isFalse);
            expect(paragraph.maxLines, isNull);
            expect(paragraph.size.width, lessThanOrEqualTo(width));
          }
          final heading = tester.widget<Text>(
            find.byKey(const Key('foundingFriendPaymentHeading')),
          );
          expect(heading.style?.fontFamily, AppTextStyles.headlineFontFamily);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Future<void> _pump(
  WidgetTester tester,
  Widget page, {
  double width = 390,
  Locale locale = const Locale('en'),
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: appTheme,
      locale: locale,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
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

  final List<FutureOr<Either<AppFailure, FoundingFriendCheckout>>> results;
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
  ) async => right(
    const FoundingFriendPaymentVerification(
      status: FoundingFriendPaymentStatus.pending,
      canResumeCheckout: true,
    ),
  );
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

  final List<FutureOr<Either<AppFailure, FoundingFriendPaymentVerification>>>
  results;
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
    FoundingFriendPaymentVerification(
      status: sessionId == checkout.sessionId
          ? FoundingFriendPaymentStatus.pending
          : FoundingFriendPaymentStatus.expired,
      canResumeCheckout: sessionId == checkout.sessionId,
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

final class _RecoveryRepository
    implements FoundingFriendPaymentRepositoryInterface {
  _RecoveryRepository(this.checkouts, this.results);
  final List<FutureOr<Either<AppFailure, FoundingFriendCheckout>>> checkouts;
  final List<FutureOr<Either<AppFailure, FoundingFriendPaymentVerification>>>
  results;
  final List<String> creates = [];
  final List<String> verifications = [];
  @override
  Future<Either<AppFailure, FoundingFriendCheckout>> createCheckout({
    required String email,
    required String attemptId,
  }) async {
    creates.add(attemptId);
    return checkouts.removeAt(0);
  }

  @override
  Future<Either<AppFailure, FoundingFriendPaymentVerification>> verifyCheckout(
    String sessionId,
  ) async {
    verifications.add(sessionId);
    return results.removeAt(0);
  }
}
