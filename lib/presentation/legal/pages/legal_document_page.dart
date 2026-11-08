import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:fun_app_landing_page/core/injection/injection.dart';
import 'package:fun_app_landing_page/domain/legal/entities/legal_document.dart';
import 'package:fun_app_landing_page/domain/legal/legal_document_repository_interface.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/routing/app_router.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/core/widgets/viewport_footer_scroll_view.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_section_target.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/landing_header.dart';
import 'package:fun_app_landing_page/presentation/legal/widgets/legal_document_links.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/models/user_sign_up.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/utils/open_user_sign_up_experience.dart';
import 'package:markdown/markdown.dart' as markdown;

/// Shared branded page for one independently published legal document.
final class LegalDocumentPage extends StatefulWidget {
  /// Loads a new snapshot on route entry and on explicit retry.
  const LegalDocumentPage({
    required this.documentId,
    this.repository,
    this.onLinkLaunch,
    this.now,
    super.key,
  });

  /// Explicit supported document, independent of presentation routes.
  final LegalDocumentId documentId;

  /// Optional read boundary for deterministic tests.
  final LegalDocumentRepositoryInterface? repository;

  /// Optional browser navigation override.
  final ValueChanged<Uri>? onLinkLaunch;

  /// Optional clock for effective-date boundary tests.
  final DateTime Function()? now;

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

final class _LegalDocumentPageState extends State<LegalDocumentPage> {
  late Future<LegalDocument> _document;

  @override
  void initState() {
    super.initState();
    _document = _load();
  }

  @override
  void didUpdateWidget(LegalDocumentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentId != widget.documentId ||
        oldWidget.repository != widget.repository) {
      _document = _load();
    }
  }

  Future<LegalDocument> _load() async {
    final repository =
        widget.repository ??
        (getIt.isRegistered<LegalDocumentRepositoryInterface>()
            ? getIt<LegalDocumentRepositoryInterface>()
            : null);
    if (repository == null) {
      throw const LegalDocumentException(LegalDocumentFailure.unavailable);
    } else {
      final document = await repository.load(widget.documentId);
      validateLegalMarkdown(document.bodyMarkdown);
      return document;
    }
  }

  void _retry() => setState(() {
    // Observe immediate failures before FutureBuilder subscribes next frame.
    _document = _load()..ignore();
  });

  @override
  Widget build(BuildContext context) {
    void openLandingSection(LandingSectionTarget target) {
      unawaited(context.router.push(LandingRoute(initialSection: target)));
    }

    return FutureBuilder<LegalDocument>(
      future: _document,
      builder: (context, snapshot) {
        // Do not label retained FutureBuilder data as a fresh publication.
        final document =
            snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError
            ? snapshot.data
            : null;
        return Title(
          title:
              '${document?.title ?? context.l10n.legalDocumentsLabel}'
              ' | ${context.l10n.brandName}',
          color: AppColors.primary,
          child: Scaffold(
            key: Key('legalDocumentPage-${widget.documentId.value}'),
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
                    onFoundingFriendsSelected: () => openLandingSection(
                      LandingSectionTarget.foundingFriends,
                    ),
                    onVenuesSelected: () =>
                        openLandingSection(LandingSectionTarget.venues),
                    onContactSelected: () => openUserSignUpExperience(
                      context,
                      UserSignUpExperience.hereAndNow,
                    ),
                  ),
                  Expanded(
                    child: ViewportFooterScrollView(
                      scrollKey: const Key('legalDocumentScrollView'),
                      content: _LegalDocumentCard(
                        document: document,
                        loading:
                            snapshot.connectionState != ConnectionState.done,
                        retry: _retry,
                        onLinkLaunch: widget.onLinkLaunch,
                        now: (widget.now ?? DateTime.now)(),
                      ),
                      footer: LandingFooter(
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
                        onPrivacyNoticeSelected: () {
                          if (widget.documentId !=
                              LegalDocumentId.privacyNotice) {
                            unawaited(
                              context.router.push(PrivacyNoticeRoute()),
                            );
                          }
                        },
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
}

final class _LegalDocumentCard extends StatelessWidget {
  const _LegalDocumentCard({
    required this.document,
    required this.loading,
    required this.retry,
    required this.now,
    this.onLinkLaunch,
  });

  final LegalDocument? document;
  final bool loading;
  final VoidCallback retry;
  final DateTime now;
  final ValueChanged<Uri>? onLinkLaunch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      final pageGutter = AppSizes.pageGutterFor(constraints.maxWidth);
      final bodyStyle = AppTextStyles.bodyFontStyle(
        fontSize: 16,
        height: 1.65,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );
      return Padding(
        padding: EdgeInsets.fromLTRB(
          pageGutter,
          isNarrow ? 16 : 20,
          pageGutter,
          isNarrow ? 16 : 40,
        ),
        child: DecoratedBox(
          key: const Key('legalDocumentCard'),
          decoration: BoxDecoration(
            color: AppColors.beigeAccent,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 24 : 56,
              vertical: isNarrow ? 48 : 72,
            ),
            child: Center(
              child: ConstrainedBox(
                key: const Key('legalDocumentContent'),
                constraints: const BoxConstraints(maxWidth: 800),
                child: document != null
                    ? SelectionArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              headingLevel: 1,
                              localeForSubtree: const Locale('en'),
                              child: Text(
                                document!.title,
                                key: const Key('legalDocumentHeading'),
                                style: AppTextStyles.headlineFontStyle(
                                  fontSize: isNarrow ? 36 : 48,
                                  fontWeight: FontWeight.w400,
                                  height: 1.15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              context.l10n.legalDocumentVersion(
                                document!.version,
                              ),
                              style: bodyStyle,
                            ),
                            Text(
                              context.l10n.legalDocumentLanguage,
                              style: bodyStyle,
                            ),
                            Text(
                              context.l10n.legalDocumentPublished(
                                document!.publishedAt,
                              ),
                              style: bodyStyle,
                            ),
                            Text(
                              context.l10n.legalDocumentEffective(
                                document!.effectiveAt,
                              ),
                              style: bodyStyle,
                            ),
                            if (Localizations.localeOf(context).languageCode !=
                                'en')
                              Text(
                                context.l10n.legalDocumentEnglishOnly,
                                style: bodyStyle,
                              ),
                            if (document!.isFutureEffective(now)) ...[
                              const SizedBox(height: 16),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  context.l10n.legalDocumentFutureEffective,
                                  key: const Key(
                                    'legalDocumentFutureEffective',
                                  ),
                                  style: bodyStyle.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            LegalTextLink(
                              label: context.l10n.legalDocumentViewPdf,
                              uri: document!.pdfUrl,
                              onOpen: onLinkLaunch,
                            ),
                            const SizedBox(height: 24),
                            Semantics(
                              localeForSubtree: const Locale('en'),
                              child: LegalMarkdownDocument(
                                markdownData: document!.bodyMarkdown,
                                markdownKey: const Key('legalDocumentMarkdown'),
                                onLinkLaunch: onLinkLaunch,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Semantics(
                        liveRegion: true,
                        child: loading
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    semanticsLabel:
                                        context.l10n.legalDocumentLoading,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.l10n.legalDocumentLoading,
                                    style: bodyStyle,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    context.l10n.legalDocumentLoadError,
                                    key: const Key('legalDocumentLoadError'),
                                    style: bodyStyle,
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    key: const Key('legalDocumentRetry'),
                                    onPressed: retry,
                                    child: Text(
                                      context.l10n.legalDocumentRetry,
                                    ),
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

/// Validates the supported Markdown subset before any legal text is displayed.
void validateLegalMarkdown(String source) {
  if (source.trim().isEmpty ||
      RegExp(r'<(?:/?[A-Za-z][A-Za-z0-9-]*(?:\s[^<>]*|/?)>|!|\?)')
          .hasMatch(source)) {
    throw const FormatException('Unsupported legal Markdown');
  }
  const supported = {
    'p',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'ul',
    'ol',
    'li',
    'strong',
    'em',
    'a',
    'br',
  };
  void visit(List<markdown.Node> nodes, {bool inHeading = false}) {
    for (final node in nodes) {
      if (node is markdown.Element) {
        if (!supported.contains(node.tag) ||
            (node.tag == 'a' &&
                (inHeading ||
                    !isSafeLegalLink(
                      Uri.tryParse(node.attributes['href'] ?? ''),
                    )))) {
          throw const FormatException('Unsupported legal Markdown');
        }
        visit(
          node.children ?? const [],
          inHeading: inHeading || RegExp(r'^h[1-6]$').hasMatch(node.tag),
        );
      }
    }
  }

  visit(
    markdown.Document(
      encodeHtml: false,
      extensionSet: markdown.ExtensionSet.gitHubFlavored,
    ).parseLines(source.split('\n')),
  );
}

/// Existing Markdown presentation, with generic selectable, accessible links.
final class LegalMarkdownDocument extends StatelessWidget {
  /// Renders the publisher's Markdown without rewriting its content.
  const LegalMarkdownDocument({
    required this.markdownData,
    required this.markdownKey,
    this.onLinkLaunch,
    super.key,
  });

  /// Exact document body.
  final String markdownData;

  /// Stable renderer key.
  final Key markdownKey;

  /// Optional browser navigation override.
  final ValueChanged<Uri>? onLinkLaunch;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final bodyStyle = AppTextStyles.bodyFontStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.65,
      color: AppColors.textPrimary,
    );
    final linkStyle = bodyStyle.copyWith(
      color: AppColors.energeticPlum,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );
    final styleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      a: linkStyle,
      p: bodyStyle,
      pPadding: const EdgeInsets.only(bottom: 8),
      h1: AppTextStyles.headlineFontStyle(
        fontSize: isNarrow ? 36 : 48,
        fontWeight: FontWeight.w400,
        height: 1.15,
        color: AppColors.textPrimary,
      ),
      h1Padding: const EdgeInsets.only(bottom: 12),
      h2: AppTextStyles.headlineFontStyle(
        fontSize: isNarrow ? 28 : 32,
        fontWeight: FontWeight.w400,
        height: 1.2,
        color: AppColors.textPrimary,
      ),
      h2Padding: const EdgeInsets.only(top: 28, bottom: 8),
      h3: AppTextStyles.bodyFontStyle(
        fontSize: isNarrow ? 18 : 20,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: AppColors.textPrimary,
      ),
      h3Padding: const EdgeInsets.only(top: 20, bottom: 4),
      strong: const TextStyle(fontWeight: FontWeight.w700),
      blockSpacing: 12,
      listIndent: isNarrow ? 24 : 32,
      listBullet: bodyStyle,
      listBulletPadding: const EdgeInsets.only(right: 8),
    );

    return MarkdownBody(
      key: markdownKey,
      data: markdownData,
      extensionSet: markdown.ExtensionSet.gitHubFlavored,
      styleSheet: styleSheet,
      listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
      builders: {
        for (var level = 1; level <= 6; level++)
          'h$level': _LegalHeadingBuilder(level),
        'a': _LegalLinkBuilder(onLinkLaunch),
      },
    );
  }
}

final class _LegalHeadingBuilder extends MarkdownElementBuilder {
  _LegalHeadingBuilder(this.level);
  final int level;

  @override
  bool isBlockElement() => true;

  @override
  Widget visitElementAfter(
    markdown.Element element,
    TextStyle? preferredStyle,
  ) => Semantics(
    header: true,
    headingLevel: level,
    child: Text.rich(_headingSpan(element), style: preferredStyle),
  );
}

final class _LegalLinkBuilder extends MarkdownElementBuilder {
  _LegalLinkBuilder(this.onOpen);
  final ValueChanged<Uri>? onOpen;

  @override
  Widget visitElementAfter(
    markdown.Element element,
    TextStyle? preferredStyle,
  ) => LegalTextLink(
    label: element.textContent,
    uri: Uri.parse(element.attributes['href']!),
    style: preferredStyle,
    onOpen: onOpen,
  );
}

TextSpan _headingSpan(markdown.Node node) {
  if (node is markdown.Element) {
    return TextSpan(
      text: node.tag == 'br' ? '\n' : null,
      style: switch (node.tag) {
        'strong' => const TextStyle(fontWeight: FontWeight.w700),
        'em' => const TextStyle(fontStyle: FontStyle.italic),
        _ => null,
      },
      children: [
        for (final child in node.children ?? const <markdown.Node>[])
          _headingSpan(child),
      ],
    );
  } else {
    return TextSpan(text: node.textContent);
  }
}
