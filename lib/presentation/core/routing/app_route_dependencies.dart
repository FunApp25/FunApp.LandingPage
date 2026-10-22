import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/pages/founding_friend_payment_return_page.dart';
import 'package:fun_app_landing_page/presentation/founding_friend_payment/utils/checkout_redirect.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/founding_friend_page.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/here_and_now_page.dart';
import 'package:fun_app_landing_page/presentation/venue/pages/venue_page.dart';

/// App-level test and development seams consumed by routed pages.
final class AppRouteDependencies extends InheritedWidget {
  /// Creates the dependency scope installed above the router outlet.
  const AppRouteDependencies({
    required super.child,
    this.onPrivacyNoticeLaunch,
    this.createVenueLeadFormBloc,
    this.createHereAndNowRegistrationFormBloc,
    this.createFoundingFriendRegistrationFormBloc,
    this.createFoundingFriendCheckoutBloc,
    this.createFoundingFriendPaymentStatusBloc,
    this.onFoundingFriendCheckoutRedirect,
    super.key,
  });

  /// Optional browser-launch override for presentation tests.
  final ValueChanged<Uri>? onPrivacyNoticeLaunch;

  /// Optional Venue form BLoC factory override for presentation tests.
  final VenueLeadFormBlocFactory? createVenueLeadFormBloc;

  /// Optional Here & Now BLoC factory override for presentation tests.
  final HereAndNowRegistrationFormBlocFactory?
  createHereAndNowRegistrationFormBloc;

  /// Optional Founding Friend BLoC factory override for presentation tests.
  final FoundingFriendRegistrationFormBlocFactory?
  createFoundingFriendRegistrationFormBloc;

  /// Optional Founding Friend Checkout BLoC factory override.
  final FoundingFriendCheckoutBlocFactory? createFoundingFriendCheckoutBloc;

  /// Optional return-page payment status BLoC factory override.
  final FoundingFriendPaymentStatusBlocFactory?
  createFoundingFriendPaymentStatusBloc;

  /// Optional hosted Checkout redirect override.
  final FoundingFriendCheckoutRedirect? onFoundingFriendCheckoutRedirect;

  /// Returns the nearest route dependency scope, when installed.
  static AppRouteDependencies? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppRouteDependencies>();

  @override
  bool updateShouldNotify(AppRouteDependencies oldWidget) =>
      onPrivacyNoticeLaunch != oldWidget.onPrivacyNoticeLaunch ||
      createVenueLeadFormBloc != oldWidget.createVenueLeadFormBloc ||
      createHereAndNowRegistrationFormBloc !=
          oldWidget.createHereAndNowRegistrationFormBloc ||
      createFoundingFriendRegistrationFormBloc !=
          oldWidget.createFoundingFriendRegistrationFormBloc ||
      createFoundingFriendCheckoutBloc !=
          oldWidget.createFoundingFriendCheckoutBloc ||
      createFoundingFriendPaymentStatusBloc !=
          oldWidget.createFoundingFriendPaymentStatusBloc ||
      onFoundingFriendCheckoutRedirect !=
          oldWidget.onFoundingFriendCheckoutRedirect;
}
