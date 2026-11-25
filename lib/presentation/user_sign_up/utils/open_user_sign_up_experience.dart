import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_router.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';

/// Opens the requested public prospective-user form.
void openUserSignUpExperience(
  BuildContext context,
  UserSignUpExperience experience,
) {
  if (experience == UserSignUpExperience.hereAndNow) {
    unawaited(context.router.push(HereAndNowRoute()));
  } else {
    unawaited(context.router.push(FoundingFriendRoute()));
  }
}
