import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/core/config/release_configuration.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_section_target.dart';
import 'package:fun_app_landing_page/presentation/landing/pages/landing_page.dart';
import 'package:fun_app_landing_page/presentation/legal/pages/legal_route_pages.dart';
import 'package:fun_app_landing_page/presentation/privacy/pages/privacy_notice_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/founding_friend_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/here_and_now_page.dart';
import 'package:fun_app_landing_page/presentation/venue/pages/venue_page.dart';

part 'app_router.gr.dart';

/// Generated, typed public-web route configuration.
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
final class AppRouter extends RootStackRouter {
  /// Creates routing for the selected release feature set.
  AppRouter({
    required this.releaseConfiguration,
  });

  /// Build-time feature configuration used to protect unfinished routes.
  final ReleaseConfiguration releaseConfiguration;

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LandingRoute.page, path: '/', initial: true),
    if (releaseConfiguration.unfinishedPreviewEnabled) ...[
      AutoRoute(page: HereAndNowRoute.page, path: '/here-and-now'),
      AutoRoute(page: FoundingFriendRoute.page, path: '/founding-friend'),
    ] else ...[
      RedirectRoute(path: '/here-and-now', redirectTo: '/'),
      RedirectRoute(path: '/founding-friend', redirectTo: '/'),
    ],
    AutoRoute(page: VenueRoute.page, path: '/venues'),
    AutoRoute(page: PrivacyNoticeRoute.page, path: '/privacy'),
    if (releaseConfiguration.unfinishedPreviewEnabled) ...[
      AutoRoute(page: TermsRoute.page, path: '/terms'),
      AutoRoute(page: RefundsRoute.page, path: '/refunds'),
      AutoRoute(page: CookiePolicyRoute.page, path: '/cookies'),
      AutoRoute(page: CookieBannerRoute.page, path: '/cookie-banner'),
    ] else ...[
      RedirectRoute(path: '/terms', redirectTo: '/'),
      RedirectRoute(path: '/refunds', redirectTo: '/'),
      RedirectRoute(path: '/cookies', redirectTo: '/'),
      RedirectRoute(path: '/cookie-banner', redirectTo: '/'),
    ],
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}
