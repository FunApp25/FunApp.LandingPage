import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/connection_experience_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/faq_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/founding_friends_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/founding_offer_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/hero_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/landing_header.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/membership_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/problem_statement_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/research_stats_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/venue_section.dart';
import 'package:fun_app_landing_page/presentation/landing/widgets/welcome_statement_section.dart';

/// Composes the complete Fun App landing page in Figma order.
final class LandingPage extends StatefulWidget {
  /// Creates the landing page.
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

final class _LandingPageState extends State<LandingPage> {
  static const _navigationDuration = Duration(milliseconds: 300);
  static const Curve _navigationCurve = Curves.easeOutCubic;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _heroKey = GlobalKey(debugLabel: 'landingHeroSection');
  final GlobalKey _membershipKey = GlobalKey(
    debugLabel: 'landingMembershipSection',
  );
  final GlobalKey _foundingFriendsKey = GlobalKey(
    debugLabel: 'landingFoundingFriendsSection',
  );
  final GlobalKey _venueKey = GlobalKey(debugLabel: 'landingVenueSection');

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

      if (disableAnimations) {
        position.jumpTo(targetOffset);
      } else {
        unawaited(
          position.animateTo(
            targetOffset,
            duration: _navigationDuration,
            curve: _navigationCurve,
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

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          LandingHeader(
            onOurBeliefSelected: () => _scrollTo(_heroKey),
            onMembershipSelected: () => _scrollTo(_membershipKey),
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
                  MembershipSection(key: _membershipKey),
                  const FoundingOfferSection(),
                  FoundingFriendsSection(key: _foundingFriendsKey),
                  VenueSection(key: _venueKey),
                  const WelcomeStatementSection(),
                  const FaqSection(),
                  LandingFooter(
                    onOurBeliefSelected: () => _scrollTo(_heroKey),
                    onMembershipSelected: () => _scrollTo(_membershipKey),
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
