import 'package:fun_app_landing_page/l10n/app_localizations.dart';

/// Localized presentation content for one FAQ item.
final class FaqItemContent {
  /// Creates an FAQ item with ordered answer paragraphs.
  const FaqItemContent({required this.question, required this.paragraphs});

  /// Localized question shown by the expandable control.
  final String question;

  /// Localized answer paragraphs in reading order.
  final List<FaqParagraphContent> paragraphs;
}

/// One localized FAQ answer paragraph and its emphasized terms.
final class FaqParagraphContent {
  /// Creates an answer paragraph.
  const FaqParagraphContent(
    this.text, {
    this.emphasizedTerms = const [],
  });

  /// Complete localized paragraph text.
  final String text;

  /// Terms rendered with the approved FAQ emphasis style.
  final List<String> emphasizedTerms;
}

/// Builds the complete ordered FAQ presentation content for [l10n].
List<FaqItemContent> buildFaqItems(AppLocalizations l10n) => [
  FaqItemContent(
    question: l10n.landingFaqFreeQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqFreeAnswer1),
      FaqParagraphContent(l10n.landingFaqFreeAnswer2),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqLifetimeQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqLifetimeAnswer1),
      FaqParagraphContent(l10n.landingFaqLifetimeAnswer2),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqCancelQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqCancelAnswer1),
      FaqParagraphContent(l10n.landingFaqCancelAnswer2),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqPhotoQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqPhotoAnswer1),
      FaqParagraphContent(l10n.landingFaqPhotoAnswer2),
      FaqParagraphContent(l10n.landingFaqPhotoAnswer3),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqBioQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqBioAnswer1),
      FaqParagraphContent(l10n.landingFaqBioAnswer2),
      FaqParagraphContent(l10n.landingFaqBioAnswer3),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqEventsQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqEventsAnswer1),
      FaqParagraphContent(l10n.landingFaqEventsAnswer2),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqMatchingQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqMatchingAnswer1),
      FaqParagraphContent(
        l10n.landingFaqMatchingAnswer2,
        emphasizedTerms: [l10n.landingFaqSharedIntentTerm],
      ),
      FaqParagraphContent(l10n.landingFaqMatchingAnswer3),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqLoveQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqLoveAnswer1),
      FaqParagraphContent(l10n.landingFaqLoveAnswer2),
      FaqParagraphContent(l10n.landingFaqLoveAnswer3),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqSafetyQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqSafetyAnswer1),
      FaqParagraphContent(
        l10n.landingFaqSafetyAnswer2,
        emphasizedTerms: const ['Safe Guard', 'Footprint'],
      ),
      FaqParagraphContent(l10n.landingFaqSafetyAnswer3),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqSafeGuardQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqSafeGuardAnswer1),
      FaqParagraphContent(l10n.landingFaqSafeGuardAnswer2),
      FaqParagraphContent(l10n.landingFaqSafeGuardAnswer3),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqFootprintQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqFootprintAnswer1),
      FaqParagraphContent(l10n.landingFaqFootprintAnswer2),
      FaqParagraphContent(l10n.landingFaqFootprintAnswer3),
      FaqParagraphContent(l10n.landingFaqFootprintAnswer4),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqGroupsQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqGroupsAnswer1),
      FaqParagraphContent(l10n.landingFaqGroupsAnswer2),
    ],
  ),
  FaqItemContent(
    question: l10n.landingFaqHarassmentQuestion,
    paragraphs: [
      FaqParagraphContent(l10n.landingFaqHarassmentAnswer1),
      FaqParagraphContent(l10n.landingFaqHarassmentAnswer2),
      FaqParagraphContent(l10n.landingFaqHarassmentAnswer3),
    ],
  ),
];
