import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/research/friendship_project_link.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_text_styles.dart';

/// Source attribution displayed beneath the research statistic cards.
final class ResearchAttribution extends StatelessWidget {
  /// Creates the research source attribution.
  const ResearchAttribution({this.textAlign = TextAlign.start, super.key});

  /// Responsive text alignment.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final attributionStyle = LandingTextStyles.statsAttribution.copyWith(
      height: 24 / 16,
    );
    final sourceStyle = LandingTextStyles.statsAttributionSource.copyWith(
      height: 24 / 16,
    );
    final separatorStyle = LandingTextStyles.statsAttributionSeparator.copyWith(
      height: 24 / 16,
    );
    final thanks = context.l10n.landingStatsAttributionThanks;
    const projectName = 'The Great Friendship Project';
    final projectStart = thanks.indexOf(projectName);

    return Text.rich(
      key: const Key('researchStatsAttribution'),
      TextSpan(
        style: attributionStyle,
        children: [
          TextSpan(text: '${context.l10n.landingStatsAttributionIntro} '),
          TextSpan(
            text: context.l10n.landingStatsBelongingForum,
            style: sourceStyle,
          ),
          TextSpan(text: ' · ', style: separatorStyle),
          TextSpan(
            text: context.l10n.landingStatsMarmaladeTrust,
            style: sourceStyle,
          ),
          TextSpan(text: ' · ', style: separatorStyle),
          TextSpan(
            text: context.l10n.landingStatsBacpYouGov,
            style: sourceStyle,
          ),
          if (projectStart >= 0) ...[
            TextSpan(text: ' ${thanks.substring(0, projectStart)}'),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: FriendshipProjectLink(style: attributionStyle),
            ),
            TextSpan(
              text: thanks.substring(projectStart + projectName.length),
            ),
          ] else
            TextSpan(text: ' $thanks'),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
