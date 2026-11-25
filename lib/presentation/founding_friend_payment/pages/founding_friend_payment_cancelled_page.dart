import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_checkout_bloc.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_route_dependencies.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/utils/checkout_redirect.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/widgets/founding_friend_payment_panel.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_page.dart';

/// Cancellation page that never creates Checkout until the user retries.
@RoutePage()
final class FoundingFriendPaymentCancelledPage extends StatelessWidget {
  /// Creates the cancellation page.
  const FoundingFriendPaymentCancelledPage({
    this.createBloc,
    this.onCheckoutRedirect,
    super.key,
  });

  /// Canonical internal cancellation route.
  static const routeName = '/founding-friend/payment/cancelled';

  /// Optional BLoC factory for tests.
  final FoundingFriendCheckoutBlocFactory? createBloc;

  /// Optional redirect override for tests.
  final FoundingFriendCheckoutRedirect? onCheckoutRedirect;

  @override
  Widget build(BuildContext context) {
    final dependencies = AppRouteDependencies.maybeOf(context);
    final blocFactory =
        createBloc ??
        dependencies?.createFoundingFriendCheckoutBloc ??
        createDefaultFoundingFriendCheckoutBloc;
    final redirect =
        onCheckoutRedirect ??
        dependencies?.onFoundingFriendCheckoutRedirect ??
        redirectToCheckout;
    return BlocProvider(
      create: (_) => blocFactory(),
      child:
          BlocListener<FoundingFriendCheckoutBloc, FoundingFriendCheckoutState>(
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
                    redirect: redirect,
                  ),
                );
              }
            },
            child: const UserSignUpPage(
              experience: UserSignUpExperience.foundingFriend,
              contentOverride: FoundingFriendCheckoutPanel(cancelled: true),
            ),
          ),
    );
  }
}
