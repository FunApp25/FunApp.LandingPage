import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/user_registration/founding_friend_registration_form_bloc/founding_friend_registration_form_bloc.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_route_dependencies.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_page.dart';

/// Creates one Founding Friend form BLoC for a route lifecycle.
typedef FoundingFriendRegistrationFormBlocFactory =
    FoundingFriendRegistrationFormBloc Function();

/// Dedicated Founding Friend sign-up route before payment integration.
@RoutePage()
final class FoundingFriendPage extends StatelessWidget {
  /// Creates the Founding Friend registration page.
  const FoundingFriendPage({
    this.createBloc,
    super.key,
  });

  /// Canonical internal route for the Founding Friend form.
  static const routeName = '/founding-friend';

  /// Optional BLoC factory override for presentation tests.
  final FoundingFriendRegistrationFormBlocFactory? createBloc;

  @override
  Widget build(BuildContext context) {
    final dependencies = AppRouteDependencies.maybeOf(context);
    final blocFactory =
        createBloc ??
        dependencies?.createFoundingFriendRegistrationFormBloc ??
        createDefaultFoundingFriendRegistrationFormBloc;

    return BlocProvider(
      create: (_) => blocFactory(),
      child:
          BlocBuilder<
            FoundingFriendRegistrationFormBloc,
            FoundingFriendRegistrationFormState
          >(
            buildWhen: (previous, current) =>
                _submissionSucceeded(previous) != _submissionSucceeded(current),
            builder: (context, state) => UserSignUpPage(
              experience: UserSignUpExperience.foundingFriend,
              showConfirmedSuccess: _submissionSucceeded(state),
            ),
          ),
    );
  }

  bool _submissionSucceeded(FoundingFriendRegistrationFormState state) =>
      state.submissionResult.fold(
        () => false,
        (result) => result.isRight(),
      );
}
