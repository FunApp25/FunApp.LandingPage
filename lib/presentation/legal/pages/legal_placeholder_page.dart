import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_route_controller.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_section_target.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/landing_header.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/interested_user_coming_soon_dialog.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';

/// Review-only destinations for legal content that has not been approved.
enum LegalPlaceholderKind {
  /// Terms of Use placeholder.
  terms,

  /// Refund & Cancellation Policy placeholder.
  refunds,

  /// Cookie Policy placeholder.
  cookies,

  /// Nonfunctional cookie-preferences placeholder.
  cookieBanner,
}

/// Shared page shell for unfinished legal and cookie-preference destinations.
final class LegalPlaceholderPage extends StatelessWidget {
  /// Creates one explicitly non-authoritative placeholder page.
  const LegalPlaceholderPage({
    required this.kind,
    this.onPrivacyNoticeLaunch,
    this.landingRouteController,
    super.key,
  });

  /// Review-only Terms of Use route.
  static const termsRouteName = '/terms';

  /// Review-only Refund & Cancellation Policy route.
  static const refundsRouteName = '/refunds';

  /// Review-only Cookie Policy route.
  static const cookiesRouteName = '/cookies';

  /// Review-only nonfunctional cookie-preferences route.
  static const cookieBannerRouteName = '/cookie-banner';

  /// Determines the localized title and status body.
  final LegalPlaceholderKind kind;

  /// Optional browser-launch override for the approved Privacy Notice.
  final ValueChanged<Uri>? onPrivacyNoticeLaunch;

  /// Coordinates navigation back to an existing landing route.
  final LandingRouteController? landingRouteController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (kind) {
      LegalPlaceholderKind.terms => l10n.landingFooterTermsOfUse,
      LegalPlaceholderKind.refunds =>
        l10n.landingFooterRefundCancellationPolicy,
      LegalPlaceholderKind.cookies => l10n.landingFooterCookiePolicy,
      LegalPlaceholderKind.cookieBanner => l10n.landingFooterCookieBanner,
    };
    final body = kind == LegalPlaceholderKind.cookieBanner
        ? l10n.cookieBannerPlaceholderBody
        : l10n.legalPlaceholderReviewOnlyBody;

    void openLandingSection(LandingSectionTarget target) {
      final controller = landingRouteController;
      if (controller != null) {
        controller.openLandingSection(context, target);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
          arguments: target,
        );
      }
    }

    void openPrivacyNotice() {
      final uri = privacyNoticeUrlFor(Uri.base);
      (onPrivacyNoticeLaunch ?? launchExternalLinkInNewTab)(uri);
    }

    return Title(
      title: '$title | ${l10n.brandName}',
      color: AppColors.primary,
      child: Scaffold(
        key: Key('legalPlaceholderPage-${kind.name}'),
        backgroundColor: AppColors.lightForeground,
        body: SafeArea(
          child: Column(
            children: [
              LandingHeader(
                onLogoSelected: () =>
                    openLandingSection(LandingSectionTarget.ourBelief),
                onOurBeliefSelected: () =>
                    openLandingSection(LandingSectionTarget.ourBelief),
                onMembershipSelected: () =>
                    openLandingSection(LandingSectionTarget.membership),
                onFoundingFriendsSelected: () =>
                    openLandingSection(LandingSectionTarget.foundingFriends),
                onVenuesSelected: () =>
                    openLandingSection(LandingSectionTarget.venues),
                onContactSelected: () {
                  unawaited(showInterestedUserComingSoonDialog(context));
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: Key('legalPlaceholderScrollView-${kind.name}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LegalPlaceholderContent(
                        kind: kind,
                        title: title,
                        status: l10n.legalPlaceholderDraftStatus,
                        body: body,
                        releaseBlocker: l10n.legalPlaceholderReleaseBlocker,
                      ),
                      LandingFooter(
                        onLogoSelected: () =>
                            openLandingSection(LandingSectionTarget.ourBelief),
                        onOurBeliefSelected: () =>
                            openLandingSection(LandingSectionTarget.ourBelief),
                        onMembershipSelected: () =>
                            openLandingSection(LandingSectionTarget.membership),
                        onFoundingFriendsSelected: () => openLandingSection(
                          LandingSectionTarget.foundingFriends,
                        ),
                        onVenuesSelected: () =>
                            openLandingSection(LandingSectionTarget.venues),
                        onPrivacyNoticeSelected: openPrivacyNotice,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _LegalPlaceholderContent extends StatelessWidget {
  const _LegalPlaceholderContent({
    required this.kind,
    required this.title,
    required this.status,
    required this.body,
    required this.releaseBlocker,
  });

  final LegalPlaceholderKind kind;
  final String title;
  final String status;
  final String body;
  final String releaseBlocker;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      final pageGutter = AppSizes.pageGutterFor(constraints.maxWidth);
      final bodyStyle = AppTextStyles.bodyFontStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.bodyGray,
      );

      return Padding(
        padding: EdgeInsets.fromLTRB(
          pageGutter,
          isNarrow ? 40 : 64,
          pageGutter,
          isNarrow ? 64 : 96,
        ),
        child: Center(
          child: ConstrainedBox(
            key: Key('legalPlaceholderContent-${kind.name}'),
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    key: Key('legalPlaceholderHeading-${kind.name}'),
                    style: AppTextStyles.headlineFontStyle(
                      fontSize: isNarrow ? 36 : 48,
                      fontWeight: FontWeight.w400,
                      height: 1.15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.beigeAccent,
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status,
                          key: Key('legalPlaceholderStatus-${kind.name}'),
                          style: bodyStyle.copyWith(
                            color: AppColors.warmOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(body, style: bodyStyle),
                        const SizedBox(height: 16),
                        Text(
                          releaseBlocker,
                          key: Key(
                            'legalPlaceholderReleaseBlocker-${kind.name}',
                          ),
                          style: bodyStyle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
