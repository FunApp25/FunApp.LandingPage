import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_route_dependencies.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_router.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/interested_user_coming_soon_dialog.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';

/// Opens an unfinished form in preview builds or the public release message.
void openUserSignUpExperience(
  BuildContext context,
  UserSignUpExperience experience,
) {
  final releaseConfiguration = AppRouteDependencies.maybeOf(context)
      ?.releaseConfiguration;
  final previewEnabled = releaseConfiguration?.unfinishedPreviewEnabled ?? true;

  if (previewEnabled) {
    if (experience == UserSignUpExperience.hereAndNow) {
      unawaited(context.router.push(HereAndNowRoute()));
    } else {
      unawaited(context.router.push(FoundingFriendRoute()));
    }
  } else {
    unawaited(showInterestedUserComingSoonDialog(context));
  }
}
