import 'package:flutter/material.dart';
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
final class LandingPage extends StatelessWidget {
  /// Creates the landing page.
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          key: Key('landingPageSections'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LandingHeader(),
            HeroSection(),
            ProblemStatementSection(),
            ResearchStatsSection(),
            ConnectionExperienceSection(),
            MembershipSection(),
            FoundingOfferSection(),
            FoundingFriendsSection(),
            VenueSection(),
            WelcomeStatementSection(),
            FaqSection(),
            LandingFooter(),
          ],
        ),
      ),
    ),
  );
}
