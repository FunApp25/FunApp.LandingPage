import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/user_registration/here_and_now_registration_form_bloc/here_and_now_registration_form_bloc.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_route_dependencies.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_page.dart';

/// Creates one Here & Now form BLoC for a route lifecycle.
typedef HereAndNowRegistrationFormBlocFactory =
    HereAndNowRegistrationFormBloc Function();

/// Dedicated Here & Now membership waitlist route.
@RoutePage()
final class HereAndNowPage extends StatelessWidget {
  /// Creates the Here & Now waitlist page.
  const HereAndNowPage({
    this.createBloc,
    super.key,
  });

  /// Canonical internal route for the Here & Now waitlist.
  static const routeName = '/here-and-now';

  /// Optional BLoC factory override for presentation tests.
  final HereAndNowRegistrationFormBlocFactory? createBloc;

  @override
  Widget build(BuildContext context) {
    final dependencies = AppRouteDependencies.maybeOf(context);
    final blocFactory =
        createBloc ??
        dependencies?.createHereAndNowRegistrationFormBloc ??
        createDefaultHereAndNowRegistrationFormBloc;

    return BlocProvider(
      create: (_) => blocFactory(),
      child:
          BlocBuilder<
            HereAndNowRegistrationFormBloc,
            HereAndNowRegistrationFormState
          >(
            buildWhen: (previous, current) =>
                _submissionSucceeded(previous) != _submissionSucceeded(current),
            builder: (context, state) => UserSignUpPage(
              experience: UserSignUpExperience.hereAndNow,
              showConfirmedSuccess: _submissionSucceeded(state),
            ),
          ),
    );
  }

  bool _submissionSucceeded(HereAndNowRegistrationFormState state) =>
      state.submissionResult.fold(
        () => false,
        (result) => result.isRight(),
      );
}
