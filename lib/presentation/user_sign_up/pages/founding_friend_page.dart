import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/founding_friend_payment/founding_friend_checkout_bloc.dart';
import 'package:fun_app_landing_page/application/user_registration/founding_friend_registration_form_bloc/founding_friend_registration_form_bloc.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_route_dependencies.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/utils/checkout_redirect.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/widgets/founding_friend_payment_panel.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_page.dart';

/// Creates one Founding Friend form BLoC for a route lifecycle.
typedef FoundingFriendRegistrationFormBlocFactory =
    FoundingFriendRegistrationFormBloc Function();

/// Creates one Founding Friend Checkout BLoC for a route lifecycle.
typedef FoundingFriendPaymentCheckoutBlocFactory =
    FoundingFriendCheckoutBloc Function();

/// Browser redirect callback used by Founding Friend presentation tests.
typedef FoundingFriendPaymentCheckoutRedirect = Future<bool> Function(Uri uri);

/// Dedicated Founding Friend registration and Checkout-start route.
@RoutePage()
final class FoundingFriendPage extends StatelessWidget {
  /// Creates the Founding Friend registration page.
  const FoundingFriendPage({
    this.createBloc,
    this.createCheckoutBloc,
    this.onCheckoutRedirect,
    super.key,
  });

  /// Canonical internal route for the Founding Friend form.
  static const routeName = '/founding-friend';

  /// Optional BLoC factory override for presentation tests.
  final FoundingFriendRegistrationFormBlocFactory? createBloc;

  /// Optional Checkout BLoC factory override for presentation tests.
  final FoundingFriendPaymentCheckoutBlocFactory? createCheckoutBloc;

  /// Optional validated Checkout redirect override for presentation tests.
  final FoundingFriendPaymentCheckoutRedirect? onCheckoutRedirect;

  @override
  Widget build(BuildContext context) {
    final dependencies = AppRouteDependencies.maybeOf(context);
    final blocFactory =
        createBloc ??
        dependencies?.createFoundingFriendRegistrationFormBloc ??
        createDefaultFoundingFriendRegistrationFormBloc;
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
        BlocProvider(create: (_) => blocFactory()),
        BlocProvider(create: (_) => checkoutBlocFactory()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<
            FoundingFriendRegistrationFormBloc,
            FoundingFriendRegistrationFormState
          >(
            listenWhen: (previous, current) =>
                !_submissionSucceeded(previous) &&
                _submissionSucceeded(current),
            listener: (context, state) {
              context.read<FoundingFriendCheckoutBloc>().add(
                FoundingFriendRegistrationConfirmed(
                  state.registration.email.getOrCrash(),
                ),
              );
            },
          ),
          BlocListener<FoundingFriendCheckoutBloc, FoundingFriendCheckoutState>(
            listenWhen: (previous, current) =>
                previous.phase != current.phase &&
                current.phase == FoundingFriendCheckoutPhase.ready,
            listener: (context, state) {
              final checkout = state.checkout;
              if (checkout != null) {
                unawaited(
                  _redirect(context, checkout.checkoutUrl, checkoutRedirect),
                );
              }
            },
          ),
        ],
        child:
            BlocSelector<
              FoundingFriendRegistrationFormBloc,
              FoundingFriendRegistrationFormState,
              bool
            >(
              selector: _submissionSucceeded,
              builder: (context, submissionSucceeded) => UserSignUpPage(
                experience: UserSignUpExperience.foundingFriend,
                contentOverride: submissionSucceeded
                    ? const FoundingFriendCheckoutPanel()
                    : null,
              ),
            ),
      ),
    );
  }

  static bool _submissionSucceeded(
    FoundingFriendRegistrationFormState state,
  ) => state.submissionResult.fold(
    () => false,
    (result) => result.isRight(),
  );

  Future<void> _redirect(
    BuildContext context,
    Uri uri,
    FoundingFriendPaymentCheckoutRedirect redirect,
  ) async {
    final bloc = context.read<FoundingFriendCheckoutBloc>()
      ..add(const FoundingFriendCheckoutRedirectStarted());
    final redirected = await redirect(uri);
    if (!redirected && !bloc.isClosed) {
      bloc.add(const FoundingFriendCheckoutRedirectFailed());
    }
  }
}
