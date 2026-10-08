import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/utils/app_assets.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_section_target.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/landing_header.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/interested_user_coming_soon_dialog.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/section_eyebrow.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_form.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/widgets/user_sign_up_success.dart';

/// Shared branded page shell for the two prospective-user forms.
final class UserSignUpPage extends StatefulWidget {
  /// Creates a presentation-only sign-up page.
  const UserSignUpPage({
    required this.experience,
    this.onSubmit,
    this.showConfirmedSuccess = false,
    this.onPrivacyNoticeLaunch,
    super.key,
  });

  /// Determines the approved copy and field surface.
  final UserSignUpExperience experience;

  /// Optional test/development submission seam; absent in production.
  final UserSignUpSubmit? onSubmit;

  /// Injected confirmed-success state for Here & Now previews/tests only.
  final bool showConfirmedSuccess;

  /// Optional browser-launch override for presentation tests.
  final ValueChanged<Uri>? onPrivacyNoticeLaunch;

  @override
  State<UserSignUpPage> createState() => _UserSignUpPageState();
}

final class _UserSignUpPageState extends State<UserSignUpPage> {
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
    (widget.onPrivacyNoticeLaunch ?? launchExternalLinkInNewTab)(uri);
  }

  @override
  Widget build(BuildContext context) {
    final showsConfirmedSuccess =
        widget.experience == UserSignUpExperience.hereAndNow &&
        widget.showConfirmedSuccess;

    return Scaffold(
      key: Key('userSignUpPage-${widget.experience.name}'),
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
                key: Key('userSignUpScrollView-${widget.experience.name}'),
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _UserSignUpMain(
                      experience: widget.experience,
                      onSubmit: widget.onSubmit,
                      showConfirmedSuccess: showsConfirmedSuccess,
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
}

final class _UserSignUpMain extends StatelessWidget {
  const _UserSignUpMain({
    required this.experience,
    required this.onSubmit,
    required this.showConfirmedSuccess,
  });

  final UserSignUpExperience experience;
  final UserSignUpSubmit? onSubmit;
  final bool showConfirmedSuccess;

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

      return ColoredBox(
        color: AppColors.lightForeground,
        child: Padding(
          key: Key('userSignUpOuterWrapper-${experience.name}'),
          padding: EdgeInsets.only(
            left: outerGutter,
            top: mobile ? 16 : 20,
            right: outerGutter,
            bottom: mobile ? 16 : 40,
          ),
          child: DecoratedBox(
            key: Key('userSignUpCard-${experience.name}'),
            decoration: BoxDecoration(
              color: AppColors.beigeAccent,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                mobile ? 16 : 40,
                mobile ? 80 : 128,
                mobile ? 16 : 40,
                mobile ? 80 : 128,
              ),
              child: Center(
                child: ConstrainedBox(
                  key: Key('userSignUpContent-${experience.name}'),
                  constraints: const BoxConstraints(maxWidth: 1016),
                  child: showConfirmedSuccess
                      ? UserSignUpSuccess(mobile: mobile)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _UserSignUpIntroduction(
                              experience: experience,
                              mobile: mobile,
                            ),
                            SizedBox(height: mobile ? 40 : 64),
                            UserSignUpForm(
                              experience: experience,
                              onSubmit: onSubmit,
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

final class _UserSignUpIntroduction extends StatelessWidget {
  const _UserSignUpIntroduction({
    required this.experience,
    required this.mobile,
  });

  final UserSignUpExperience experience;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final eyebrow = switch (experience) {
      UserSignUpExperience.hereAndNow => l10n.userSignUpHereAndNowEyebrow,
      UserSignUpExperience.foundingFriend =>
        l10n.userSignUpFoundingFriendEyebrow,
    };
    final introduction = switch (experience) {
      UserSignUpExperience.hereAndNow => l10n.userSignUpHereAndNowIntroduction,
      UserSignUpExperience.foundingFriend =>
        l10n.userSignUpFoundingFriendIntroduction,
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            SectionEyebrow(
              label: eyebrow.toUpperCase(),
              glyphAsset: AppAssets.heroEyebrowGlyph,
              foregroundColor: AppColors.blueMain,
              glyphSize: Size(18, mobile ? 16 : 12),
              alignment: MainAxisAlignment.center,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Semantics(
              key: Key('userSignUpIntroduction-${experience.name}'),
              header: true,
              child: Text(
                introduction,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyFontStyle(
                  fontSize: mobile ? 18 : 20,
                  fontWeight: FontWeight.w500,
                  height: mobile ? 28 / 18 : 30 / 20,
                  letterSpacing: mobile ? 0.36 : 0.4,
                  color: AppColors.bodyGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
