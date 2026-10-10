import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_route_controller.dart';
import 'package:fun_app_landing_page/presentation/landing/navigation/landing_section_target.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/footer/landing_footer.dart';
import 'package:fun_app_landing_page/presentation/landing/sections/header/landing_header.dart';
import 'package:fun_app_landing_page/presentation/legal/legal_routes.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';
import 'package:fun_app_landing_page/presentation/user_sign_up/pages/here_and_now_page.dart';
import 'package:markdown/markdown.dart' as markdown;

/// Shared branded shell and Markdown renderer for public legal documents.
final class LegalDocumentPage extends StatelessWidget {
  /// Creates a legal-document route backed by [markdownData] or
  /// [markdownFuture].
  const LegalDocumentPage({
    required this.documentId,
    required this.title,
    required this.markdownFuture,
    required this.pageKey,
    required this.scrollKey,
    required this.contentKey,
    required this.markdownKey,
    this.markdownData,
    this.status,
    this.statusKey,
    this.showLocalizedHeading = false,
    this.headingKey,
    this.documentHeadingKey,
    this.onLinkLaunch,
    this.landingRouteController,
    super.key,
  });

  /// Stable non-user-visible document identifier.
  final String documentId;

  /// Localized browser and optional visible page title.
  final String title;

  /// Already-loaded Markdown used by deterministic tests.
  final String? markdownData;

  /// Cached Markdown-loading operation for the production asset.
  final Future<String> markdownFuture;

  /// Optional localized review status shown outside the legal copy.
  final String? status;

  /// Stable status key.
  final Key? statusKey;

  /// Whether [title] is rendered as the document's visible H1.
  final bool showLocalizedHeading;

  /// Stable visible-title key.
  final Key? headingKey;

  /// Stable H1 key for a heading supplied by Markdown.
  final Key? documentHeadingKey;

  /// Optional link-launch override used by deterministic tests.
  final ValueChanged<Uri>? onLinkLaunch;

  /// Coordinates navigation to landing-page anchors.
  final LandingRouteController? landingRouteController;

  /// Stable page key.
  final Key pageKey;

  /// Stable scroll-view key.
  final Key scrollKey;

  /// Stable constrained-content key.
  final Key contentKey;

  /// Stable Markdown-renderer key.
  final Key markdownKey;

  @override
  Widget build(BuildContext context) {
    void openLandingSection(LandingSectionTarget target) {
      final controller = landingRouteController;
      if (controller != null) {
        controller.openLandingSection(context, target);
      } else {
        Navigator.of(context).pushNamed('/', arguments: target);
      }
    }

    void openRoute(String routeName) {
      if (ModalRoute.of(context)?.settings.name != routeName) {
        Navigator.of(context).pushNamed(routeName);
      }
    }

    return Title(
      title: '$title | ${context.l10n.brandName}',
      color: AppColors.primary,
      child: Scaffold(
        key: pageKey,
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
                onContactSelected: () => openRoute(HereAndNowPage.routeName),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: scrollKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LegalDocumentCard(
                        documentId: documentId,
                        title: title,
                        markdownData: markdownData,
                        markdownFuture: markdownFuture,
                        status: status,
                        statusKey: statusKey,
                        showLocalizedHeading: showLocalizedHeading,
                        headingKey: headingKey,
                        documentHeadingKey: documentHeadingKey,
                        contentKey: contentKey,
                        markdownKey: markdownKey,
                        onLinkLaunch: onLinkLaunch,
                      ),
                      LandingFooter(
                        onLogoSelected: () =>
                            openLandingSection(LandingSectionTarget.ourBelief),
                        onOurBeliefSelected: () =>
                            openLandingSection(LandingSectionTarget.ourBelief),
                        onMembershipSelected: () => openLandingSection(
                          LandingSectionTarget.membership,
                        ),
                        onFoundingFriendsSelected: () => openLandingSection(
                          LandingSectionTarget.foundingFriends,
                        ),
                        onVenuesSelected: () =>
                            openLandingSection(LandingSectionTarget.venues),
                        onPrivacyNoticeSelected: () =>
                            openRoute(LegalRoutes.privacy),
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

final class _LegalDocumentCard extends StatelessWidget {
  const _LegalDocumentCard({
    required this.documentId,
    required this.title,
    required this.markdownFuture,
    required this.showLocalizedHeading,
    required this.contentKey,
    required this.markdownKey,
    this.markdownData,
    this.status,
    this.statusKey,
    this.headingKey,
    this.documentHeadingKey,
    this.onLinkLaunch,
  });

  final String documentId;
  final String title;
  final String? markdownData;
  final Future<String> markdownFuture;
  final String? status;
  final Key? statusKey;
  final bool showLocalizedHeading;
  final Key? headingKey;
  final Key? documentHeadingKey;
  final Key contentKey;
  final Key markdownKey;
  final ValueChanged<Uri>? onLinkLaunch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      final pageGutter = AppSizes.pageGutterFor(constraints.maxWidth);

      return Padding(
        padding: EdgeInsets.only(
          left: pageGutter,
          top: isNarrow ? 16 : 20,
          right: pageGutter,
          bottom: isNarrow ? 16 : 40,
        ),
        child: DecoratedBox(
          key: Key('legalDocumentCard-$documentId'),
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
                key: contentKey,
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLocalizedHeading) ...[
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          key: headingKey,
                          style: AppTextStyles.headlineFontStyle(
                            fontSize: isNarrow ? 36 : 48,
                            fontWeight: FontWeight.w400,
                            height: 1.15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: isNarrow ? 24 : 32),
                    ],
                    if (status case final status?) ...[
                      Text(
                        status,
                        key: statusKey,
                        style: AppTextStyles.bodyFontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          color: AppColors.warmOrange,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (markdownData case final data?)
                      LegalMarkdownDocument(
                        markdownData: data,
                        markdownKey: markdownKey,
                        documentHeadingKey: documentHeadingKey,
                        onLinkLaunch: onLinkLaunch,
                      )
                    else
                      FutureBuilder<String>(
                        future: markdownFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return LegalMarkdownDocument(
                              markdownData: snapshot.requireData,
                              markdownKey: markdownKey,
                              documentHeadingKey: documentHeadingKey,
                              onLinkLaunch: onLinkLaunch,
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              context.l10n.legalDocumentLoadError,
                              key: Key('legalDocumentLoadError-$documentId'),
                              style: AppTextStyles.bodyFontStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.65,
                                color: AppColors.textPrimary,
                              ),
                            );
                          } else {
                            return KeyedSubtree(
                              key: Key('legalDocumentLoading-$documentId'),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Shared accessible Markdown renderer for approved and review-only documents.
final class LegalMarkdownDocument extends StatelessWidget {
  /// Creates the shared Markdown document.
  const LegalMarkdownDocument({
    required this.markdownData,
    required this.markdownKey,
    this.documentHeadingKey,
    this.onLinkLaunch,
    super.key,
  });

  /// Markdown source loaded from the repository asset.
  final String markdownData;

  /// Stable renderer key.
  final Key markdownKey;

  /// Optional stable H1 key.
  final Key? documentHeadingKey;

  /// Optional link-launch override used by deterministic tests.
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
      decorationColor: AppColors.energeticPlum,
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
      blockSyntaxes: const [_LegalContactBlockSyntax()],
      softLineBreak: true,
      styleSheet: styleSheet,
      listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
      builders: <String, MarkdownElementBuilder>{
        'h1': _LegalHeadingBuilder(key: documentHeadingKey),
        'h2': _LegalHeadingBuilder(),
        'h3': _LegalHeadingBuilder(),
        'privacy-contact': _LegalContactBlockBuilder(
          bodyStyle: bodyStyle,
          linkStyle: linkStyle,
          onLinkLaunch: onLinkLaunch,
        ),
      },
      imageBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}

final class _LegalContactBlockSyntax extends markdown.BlockSyntax {
  const _LegalContactBlockSyntax();

  @override
  RegExp get pattern => RegExp('.*');

  @override
  bool canEndBlock(markdown.BlockParser parser) => false;

  @override
  bool canParse(markdown.BlockParser parser) {
    const approvedContactLink = '[info@funapp.world](mailto:info@funapp.world)';
    final startIndex = parser.lines.indexOf(parser.current);

    if (startIndex < 0) {
      return false;
    } else {
      for (var index = startIndex; index < parser.lines.length; index++) {
        final content = parser.lines[index].content;
        if (content.isEmpty) {
          return false;
        } else if (content.contains(approvedContactLink)) {
          return true;
        }
      }
      return false;
    }
  }

  @override
  markdown.Node parse(markdown.BlockParser parser) {
    final lines = <String>[parser.current.content];
    parser.advance();
    while (!parser.isDone && interruptedBy(parser) == null) {
      lines.add(parser.current.content);
      parser.advance();
    }
    return markdown.Element('privacy-contact', [
      markdown.UnparsedContent(lines.join('\n').trimRight()),
    ]);
  }
}

final class _LegalContactBlockBuilder extends MarkdownElementBuilder {
  _LegalContactBlockBuilder({
    required this.bodyStyle,
    required this.linkStyle,
    required this.onLinkLaunch,
  });

  final TextStyle bodyStyle;
  final TextStyle linkStyle;
  final ValueChanged<Uri>? onLinkLaunch;

  @override
  bool isBlockElement() => true;

  @override
  Widget visitElementAfter(
    markdown.Element element,
    TextStyle? preferredStyle,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final line in _splitContactLines(element.children))
        _LegalContactLine(
          nodes: line,
          bodyStyle: bodyStyle,
          linkStyle: linkStyle,
          onLinkLaunch: onLinkLaunch,
        ),
    ],
  );
}

List<List<markdown.Node>> _splitContactLines(List<markdown.Node>? nodes) {
  final lines = <List<markdown.Node>>[<markdown.Node>[]];
  for (final node in nodes ?? const <markdown.Node>[]) {
    if (node is markdown.Element && node.tag == 'br') {
      lines.add(<markdown.Node>[]);
    } else {
      lines.last.add(node);
    }
  }
  return lines;
}

final class _LegalContactLine extends StatelessWidget {
  const _LegalContactLine({
    required this.nodes,
    required this.bodyStyle,
    required this.linkStyle,
    required this.onLinkLaunch,
  });

  final List<markdown.Node> nodes;
  final TextStyle bodyStyle;
  final TextStyle linkStyle;
  final ValueChanged<Uri>? onLinkLaunch;

  @override
  Widget build(BuildContext context) {
    final contactUri = _approvedContactUri(nodes);
    if (contactUri != null) {
      return _LegalEmailLinkRow(
        uri: contactUri,
        label: nodes.single.textContent,
        linkStyle: linkStyle,
        onLinkLaunch: onLinkLaunch,
      );
    } else {
      return Text.rich(
        TextSpan(
          style: bodyStyle,
          children: [
            for (final node in nodes)
              _contactInlineSpan(
                node,
                strongStyle: const TextStyle(fontWeight: FontWeight.w700),
                linkStyle: linkStyle,
              ),
          ],
        ),
      );
    }
  }
}

Uri? _approvedContactUri(List<markdown.Node> nodes) {
  if (nodes.length == 1 && nodes.single is markdown.Element) {
    final element = nodes.single as markdown.Element;
    final uri = Uri.tryParse(element.attributes['href'] ?? '');
    if (element.tag == 'a' &&
        uri?.scheme == 'mailto' &&
        uri?.path == 'info@funapp.world') {
      return uri;
    }
  }
  return null;
}

InlineSpan _contactInlineSpan(
  markdown.Node node, {
  required TextStyle strongStyle,
  required TextStyle linkStyle,
}) {
  if (node is markdown.Text) {
    return TextSpan(text: node.text);
  } else if (node is markdown.Element) {
    final style = switch (node.tag) {
      'strong' => strongStyle,
      'em' => const TextStyle(fontStyle: FontStyle.italic),
      'a' => linkStyle,
      _ => null,
    };
    return TextSpan(
      style: style,
      children: [
        for (final child in node.children ?? const <markdown.Node>[])
          _contactInlineSpan(
            child,
            strongStyle: strongStyle,
            linkStyle: linkStyle,
          ),
      ],
    );
  } else {
    return TextSpan(text: node.textContent);
  }
}

final class _LegalEmailLinkRow extends StatelessWidget {
  const _LegalEmailLinkRow({
    required this.uri,
    required this.label,
    required this.linkStyle,
    required this.onLinkLaunch,
  });

  final Uri uri;
  final String label;
  final TextStyle linkStyle;
  final ValueChanged<Uri>? onLinkLaunch;

  void _launch() {
    final launchOverride = onLinkLaunch;
    if (launchOverride != null) {
      launchOverride(uri);
    } else {
      launchPrivacyNoticeLink(uri);
    }
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 44),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Semantics(
        label: label,
        link: true,
        onTap: _launch,
        child: ExcludeSemantics(
          child: TextButton(
            key: const Key('privacyNoticeEmailButton'),
            onPressed: _launch,
            style:
                TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  alignment: AlignmentDirectional.centerStart,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.energeticPlum,
                  textStyle: linkStyle,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ).copyWith(
                  side: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.focused)
                        ? const BorderSide(
                            color: AppColors.energeticPlum,
                            width: 2,
                          )
                        : BorderSide.none,
                  ),
                ),
            child: Text(label),
          ),
        ),
      ),
    ),
  );
}

final class _LegalHeadingBuilder extends MarkdownElementBuilder {
  _LegalHeadingBuilder({this.key});

  final Key? key;

  @override
  bool isBlockElement() => true;

  @override
  Widget visitElementAfter(
    markdown.Element element,
    TextStyle? preferredStyle,
  ) => Semantics(
    key: key,
    header: true,
    child: Text(element.textContent, style: preferredStyle),
  );
}
