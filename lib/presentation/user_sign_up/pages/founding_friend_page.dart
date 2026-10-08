import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_page.dart';

/// Dedicated Founding Friend sign-up route before payment integration.
final class FoundingFriendPage extends StatelessWidget {
  /// Creates the UI-only Founding Friend page.
  const FoundingFriendPage({this.onSubmit, super.key});

  /// Canonical internal route for the Founding Friend form.
  static const routeName = '/founding-friend';

  /// Optional test/development submission seam; absent in production.
  final UserSignUpSubmit? onSubmit;

  @override
  Widget build(BuildContext context) => UserSignUpPage(
    experience: UserSignUpExperience.foundingFriend,
    onSubmit: onSubmit,
  );
}
