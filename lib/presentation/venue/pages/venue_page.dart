import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fun_app_landing_page/application/venue/venue_lead_form_bloc/venue_lead_form_bloc.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_route_dependencies.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_router.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/viewport_footer_scroll_view.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_section_target.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/landing_header.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/utils/open_user_sign_up_experience.dart';
import 'package:fun_app_landing_page/presentation/venue/widgets/venue_page_form_region.dart';
import 'package:fun_app_landing_page/presentation/venue/widgets/venue_page_introduction.dart';
import 'package:fun_app_landing_page/presentation/venue/widgets/venue_success_content.dart';

/// Creates the application-owned Venue form BLoC for one route lifecycle.
typedef VenueLeadFormBlocFactory = VenueLeadFormBloc Function();

/// Dedicated Venue route aligned with form nodes `2731:1392` and `2733:2319`
/// and success nodes `2733:2857` and `2733:3031`.
@RoutePage()
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
  Widget build(BuildContext context) {
    final dependencies = AppRouteDependencies.maybeOf(context);
    final blocFactory =
        createBloc ??
        dependencies?.createVenueLeadFormBloc ??
        getIt.call<VenueLeadFormBloc>;

    return BlocProvider(
      create: (_) => blocFactory(),
      child: _VenuePageView(
        onPrivacyNoticeLaunch:
            onPrivacyNoticeLaunch ?? dependencies?.onPrivacyNoticeLaunch,
      ),
    );
  }
}

final class _VenuePageView extends StatefulWidget {
  const _VenuePageView({this.onPrivacyNoticeLaunch});

  final ValueChanged<Uri>? onPrivacyNoticeLaunch;

  @override
  State<_VenuePageView> createState() => _VenuePageViewState();
}

final class _VenuePageViewState extends State<_VenuePageView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openLandingSection(
    BuildContext context,
    LandingSectionTarget target,
  ) {
    unawaited(context.router.push(LandingRoute(initialSection: target)));
  }

  void _openPrivacyNotice() {
    final uri = privacyNoticeUrlFor(Uri.base);
    (widget.onPrivacyNoticeLaunch ?? launchExternalLinkInNewTab)(uri);
  }

  bool _submissionSucceeded(VenueLeadFormState state) =>
      state.submissionResult.fold(
        () => false,
        (result) => result.isRight(),
      );

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<VenueLeadFormBloc, VenueLeadFormState>(
        listenWhen: (previous, current) =>
            !_submissionSucceeded(previous) && _submissionSucceeded(current),
        listener: (context, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              _scrollController.jumpTo(0);
            }
          });
        },
        buildWhen: (previous, current) =>
            previous.isSubmitting != current.isSubmitting ||
            _submissionSucceeded(previous) != _submissionSucceeded(current),
        builder: (context, state) {
          final submissionSucceeded = _submissionSucceeded(state);

          return PopScope<void>(
            key: const Key('venuePagePopScope'),
            canPop: !state.isSubmitting,
            child: Scaffold(
              key: const Key('venuePage'),
              backgroundColor: AppColors.lightForeground,
              body: SafeArea(
                child: Column(
                  children: [
                    LandingHeader(
                      onLogoSelected: () => _openLandingSection(
                        context,
                        LandingSectionTarget.ourBelief,
                      ),
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
                      onContactSelected: () => openUserSignUpExperience(
                        context,
                        UserSignUpExperience.hereAndNow,
                      ),
                    ),
                    Expanded(
                      child: ViewportFooterScrollView(
                        scrollKey: const Key('venuePageScrollView'),
                        controller: _scrollController,
                        content: _VenuePageMain(
                          submissionSucceeded: submissionSucceeded,
                          onPrivacyNoticeSelected: _openPrivacyNotice,
                        ),
                        footer: LandingFooter(
                          onLogoSelected: () => _openLandingSection(
                            context,
                            LandingSectionTarget.ourBelief,
                          ),
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
                          onPrivacyNoticeSelected: () => unawaited(
                            context.router.push(PrivacyNoticeRoute()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

final class _VenuePageMain extends StatelessWidget {
  const _VenuePageMain({
    required this.submissionSucceeded,
    required this.onPrivacyNoticeSelected,
  });

  final bool submissionSucceeded;
  final VoidCallback onPrivacyNoticeSelected;

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
            child: submissionSucceeded
                ? VenueSuccessContent(mobile: mobile)
                : Padding(
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
                            Center(
                              child: VenuePageIntroduction(mobile: mobile),
                            ),
                            SizedBox(height: mobile ? 40 : 64),
                            VenuePageFormRegion(
                              onPrivacyNoticeSelected: onPrivacyNoticeSelected,
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
