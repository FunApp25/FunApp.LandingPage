import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_checkout_bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_payment_status_bloc.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_route_dependencies.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/utils/checkout_redirect.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/widgets/founding_friend_payment_panel.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_page.dart';

/// Creates one reloadable payment status BLoC for a route lifecycle.
typedef FoundingFriendPaymentStatusBlocFactory =
    FoundingFriendPaymentStatusBloc Function();

typedef _CheckoutBlocListener =
    BlocListener<FoundingFriendCheckoutBloc, FoundingFriendCheckoutState>;

/// Verifies a Checkout Session after the hosted Checkout redirect.
@RoutePage()
final class FoundingFriendPaymentReturnPage extends StatelessWidget {
  /// Creates the return page.
  const FoundingFriendPaymentReturnPage({
    @QueryParam('session_id') this.sessionId,
    this.createBloc,
    this.createCheckoutBloc,
    this.onCheckoutRedirect,
    super.key,
  });

  /// Canonical internal return route.
  static const routeName = '/founding-friend/payment';

  /// Opaque Checkout Session identifier supplied by Stripe.
  final String? sessionId;

  /// Optional BLoC factory for tests.
  final FoundingFriendPaymentStatusBlocFactory? createBloc;

  /// Optional Checkout BLoC factory for expired-session retries.
  final FoundingFriendCheckoutBlocFactory? createCheckoutBloc;

  /// Optional validated Checkout redirect override for tests.
  final FoundingFriendCheckoutRedirect? onCheckoutRedirect;

  @override
  Widget build(BuildContext context) {
    final opaqueSessionId = sessionId ?? '';
    final dependencies = AppRouteDependencies.maybeOf(context);
    final blocFactory =
        createBloc ??
        dependencies?.createFoundingFriendPaymentStatusBloc ??
        createDefaultFoundingFriendPaymentStatusBloc;
    final checkoutBlocFactory =
        createCheckoutBloc ??
        dependencies?.createFoundingFriendCheckoutBloc ??
        createDefaultFoundingFriendCheckoutBloc;
    final checkoutRedirect =
        onCheckoutRedirect ??
        dependencies?.onFoundingFriendCheckoutRedirect ??
        redirectToCheckout;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => blocFactory()
            ..add(
              FoundingFriendPaymentVerificationRequested(opaqueSessionId),
            ),
        ),
        BlocProvider(create: (_) => checkoutBlocFactory()),
      ],
      child: _CheckoutBlocListener(
        listenWhen: (previous, current) =>
            previous.phase != current.phase &&
            current.phase == FoundingFriendCheckoutPhase.ready,
        listener: (context, state) {
          final checkout = state.checkout;
          if (checkout != null) {
            unawaited(
              startFoundingFriendCheckoutRedirect(
                bloc: context.read<FoundingFriendCheckoutBloc>(),
                checkoutUrl: checkout.checkoutUrl,
                redirect: checkoutRedirect,
              ),
            );
          }
        },
        child:
            BlocBuilder<
              FoundingFriendCheckoutBloc,
              FoundingFriendCheckoutState
            >(
              builder: (context, checkoutState) => UserSignUpPage(
                experience: UserSignUpExperience.foundingFriend,
                contentOverride:
                    checkoutState.phase == FoundingFriendCheckoutPhase.idle
                    ? FoundingFriendPaymentStatusPanel(
                        sessionId: opaqueSessionId,
                        onExpiredCheckoutRetry: () =>
                            _retryExpiredCheckout(context),
                      )
                    : const FoundingFriendCheckoutPanel(),
              ),
            ),
      ),
    );
  }

  void _retryExpiredCheckout(BuildContext context) {
    context.read<FoundingFriendCheckoutBloc>().add(
      const FoundingFriendExpiredCheckoutRetryRequested(),
    );
  }
}
