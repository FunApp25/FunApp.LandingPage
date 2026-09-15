import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/connection/connection_experience_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/faq/faq_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_friends/founding_friends_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_member/founding_member_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/founding_offer/founding_offer_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/landing_header.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/hero/hero_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/problem/problem_statement_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/research_stats_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/venue/venue_section.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/welcome/welcome_statement_section.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/interested_user_coming_soon_dialog.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';

/// Composes the complete Fun App landing page in Figma order.
final class LandingPage extends StatefulWidget {
  /// Creates the landing page.
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

final class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _heroKey = GlobalKey(debugLabel: 'landingHeroSection');
  final GlobalKey _foundingFriendsKey = GlobalKey(
    debugLabel: 'landingFoundingFriendsSection',
  );
  final GlobalKey _venueKey = GlobalKey(debugLabel: 'landingVenueSection');
  GlobalKey? _activeNavigationTarget;
  var _navigationRequest = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey sectionKey, {bool retryAfterLayout = true}) {
    final renderObject = sectionKey.currentContext?.findRenderObject();
    final canScroll =
        _scrollController.hasClients &&
        renderObject != null &&
        renderObject.attached;

    if (canScroll) {
      final viewport = RenderAbstractViewport.of(renderObject);
      final position = _scrollController.position;
      final targetOffset = viewport
          .getOffsetToReveal(renderObject, 0)
          .offset
          .clamp(position.minScrollExtent, position.maxScrollExtent);
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      final distance = (targetOffset - position.pixels).abs();
      final duration = LandingMotion.navigationDurationFor(
        distance: distance,
        viewportDimension: position.viewportDimension,
      );

      if (disableAnimations) {
        _navigationRequest++;
        _activeNavigationTarget = null;
        if (distance > 1 || position.isScrollingNotifier.value) {
          position.jumpTo(targetOffset);
        }
      } else if (_activeNavigationTarget == sectionKey) {
        // The active movement already owns this destination.
      } else if (duration == Duration.zero) {
        if (_activeNavigationTarget != null) {
          _navigationRequest++;
          _activeNavigationTarget = null;
          position.jumpTo(targetOffset);
        }
      } else {
        final request = ++_navigationRequest;
        _activeNavigationTarget = sectionKey;
        unawaited(
          _animateTo(
            position: position,
            targetOffset: targetOffset,
            duration: duration,
            request: request,
          ),
        );
      }
    } else if (retryAfterLayout) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (mounted) {
            _scrollTo(sectionKey, retryAfterLayout: false);
          }
        },
      );
    }
  }

  Future<void> _animateTo({
    required ScrollPosition position,
    required double targetOffset,
    required Duration duration,
    required int request,
  }) async {
    await position.animateTo(
      targetOffset,
      duration: duration,
      curve: LandingMotion.navigationCurve,
    );

    if (request == _navigationRequest) {
      _activeNavigationTarget = null;
    }
  }

  void _showInterestedUserComingSoonDialog() {
    unawaited(showInterestedUserComingSoonDialog(context));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          LandingHeader(
            onOurBeliefSelected: () => _scrollTo(_heroKey),
            onFoundingFriendsSelected: () => _scrollTo(_foundingFriendsKey),
            onVenuesSelected: () => _scrollTo(_venueKey),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: const Key('landingPageScrollView'),
              controller: _scrollController,
              child: Column(
                key: const Key('landingPageSections'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeroSection(key: _heroKey),
                  const ProblemStatementSection(),
                  const ResearchStatsSection(),
                  const ConnectionExperienceSection(),
                  // MVP: Membership is temporarily hidden from the rendered
                  // composition. Its implementation remains available.
                  const FoundingOfferSection(),
                  const FoundingMemberSection(),
                  FoundingFriendsSection(
                    key: _foundingFriendsKey,
                    onCtaPressed: _showInterestedUserComingSoonDialog,
                  ),
                  VenueSection(key: _venueKey),
                  const WelcomeStatementSection(),
                  const FaqSection(),
                  LandingFooter(
                    onOurBeliefSelected: () => _scrollTo(_heroKey),
                    onFoundingFriendsSelected: () =>
                        _scrollTo(_foundingFriendsKey),
                    onVenuesSelected: () => _scrollTo(_venueKey),
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
