import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_section_target.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/landing_header.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/interested_user_coming_soon_dialog.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';
import 'package:fun_app_landing_page/presentation/venue/widgets/venue_page_form_region.dart';
import 'package:fun_app_landing_page/presentation/venue/widgets/venue_page_introduction.dart';

/// Creates the application-owned Venue form BLoC for one route lifecycle.
typedef VenueLeadFormBlocFactory = VenueLeadFormBloc Function();

/// Dedicated Venue sign-up route aligned with Figma nodes `2731:1392` and
/// `2733:2319`.
final class VenuePage extends StatelessWidget {
  /// Creates the routed Venue sign-up page.
  const VenuePage({
    this.createBloc,
    this.onPrivacyNoticeLaunch,
    super.key,
  });

  /// Canonical internal route for the Venue sign-up page.
  static const routeName = '/venues';

  /// Optional form BLoC factory override for presentation tests.
  final VenueLeadFormBlocFactory? createBloc;

  /// Optional browser-launch override for presentation tests.
  final ValueChanged<Uri>? onPrivacyNoticeLaunch;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => (createBloc ?? getIt.call<VenueLeadFormBloc>)(),
    child: _VenuePageView(onPrivacyNoticeLaunch: onPrivacyNoticeLaunch),
  );
}

final class _VenuePageView extends StatelessWidget {
  const _VenuePageView({this.onPrivacyNoticeLaunch});

  final ValueChanged<Uri>? onPrivacyNoticeLaunch;

  void _openLandingSection(
    BuildContext context,
    LandingSectionTarget target,
  ) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
      arguments: target,
    );
  }

  void _showInterestedUserComingSoonDialog(BuildContext context) {
    unawaited(showInterestedUserComingSoonDialog(context));
  }

  void _openPrivacyNotice() {
    final uri = privacyNoticeUrlFor(Uri.base);
    (onPrivacyNoticeLaunch ?? launchExternalLinkInNewTab)(uri);
  }

  void _closeSuccess(BuildContext context) {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('venuePage'),
    backgroundColor: AppColors.lightForeground,
    body: SafeArea(
      child: Column(
        children: [
          LandingHeader(
            onOurBeliefSelected: () => _openLandingSection(
              context,
              LandingSectionTarget.ourBelief,
            ),
            onMembershipSelected: () => _openLandingSection(
              context,
              LandingSectionTarget.membership,
            ),
            onFoundingFriendsSelected: () => _openLandingSection(
              context,
              LandingSectionTarget.foundingFriends,
            ),
            onVenuesSelected: () => _openLandingSection(
              context,
              LandingSectionTarget.venues,
            ),
            onContactSelected: () =>
                _showInterestedUserComingSoonDialog(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: const Key('venuePageScrollView'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _VenuePageMain(
                    onPrivacyNoticeSelected: _openPrivacyNotice,
                    onSuccessClose: () => _closeSuccess(context),
                  ),
                  LandingFooter(
                    onOurBeliefSelected: () => _openLandingSection(
                      context,
                      LandingSectionTarget.ourBelief,
                    ),
                    onMembershipSelected: () => _openLandingSection(
                      context,
                      LandingSectionTarget.membership,
                    ),
                    onFoundingFriendsSelected: () => _openLandingSection(
                      context,
                      LandingSectionTarget.foundingFriends,
                    ),
                    onVenuesSelected: () => _openLandingSection(
                      context,
                      LandingSectionTarget.venues,
                    ),
                    onPrivacyNoticeSelected: _openPrivacyNotice,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

final class _VenuePageMain extends StatelessWidget {
  const _VenuePageMain({
    required this.onPrivacyNoticeSelected,
    required this.onSuccessClose,
  });

  final VoidCallback onPrivacyNoticeSelected;
  final VoidCallback onSuccessClose;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final availableWidth = constraints.hasBoundedWidth
          ? constraints.maxWidth
          : AppSizes.desktopPageWidth;
      final mobile = availableWidth < 600;
      final outerGutter = mobile
          ? AppSizes.mobileLandingPageGutter
          : AppSizes.pageGutterFor(availableWidth);
      final wrapperPadding = EdgeInsets.only(
        left: outerGutter,
        top: mobile ? 16 : 20,
        right: outerGutter,
        bottom: mobile ? 16 : 40,
      );

      return ColoredBox(
        color: AppColors.lightForeground,
        child: Padding(
          key: const Key('venuePageOuterWrapper'),
          padding: wrapperPadding,
          child: DecoratedBox(
            key: const Key('venuePageCard'),
            decoration: BoxDecoration(
              color: AppColors.beigeAccent,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: Padding(
              key: const Key('venuePageCardPadding'),
              padding: EdgeInsets.fromLTRB(
                mobile ? 16 : 40,
                mobile ? 80 : 128,
                mobile ? 16 : 40,
                mobile ? 80 : 128,
              ),
              child: Center(
                child: ConstrainedBox(
                  key: const Key('venuePageContent'),
                  constraints: const BoxConstraints(maxWidth: 1016),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: VenuePageIntroduction(mobile: mobile)),
                      SizedBox(height: mobile ? 40 : 64),
                      VenuePageFormRegion(
                        onPrivacyNoticeSelected: onPrivacyNoticeSelected,
                        onSuccessClose: onSuccessClose,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
