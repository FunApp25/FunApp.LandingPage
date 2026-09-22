import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:fun_app_landing_page/presentation/core/extensions/build_context_localizations_extension.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';
import 'package:fun_app_landing_page/presentation/privacy/utils/privacy_notice_link_launcher.dart';
import 'package:markdown/markdown.dart' as markdown;

/// Hosts the approved Fun App Ltd Privacy Notice as a dedicated web page.
final class PrivacyNoticePage extends StatelessWidget {
  /// Creates the Privacy Notice page.
  const PrivacyNoticePage({this.markdownData, this.onLinkLaunch, super.key});

  /// Optional already-loaded canonical content used by deterministic tests.
  final String? markdownData;

  /// Optional link-launch override used by deterministic tests.
  final ValueChanged<Uri>? onLinkLaunch;

  /// Flutter route represented by the GitHub-Pages-safe hash URL.
  static const routeName = '/privacy';

  /// Canonical public URL for the currently hosted Privacy Notice.
  static const canonicalUrl = 'https://funapp.world/#/privacy';

  /// Canonical website representation of the approved legal copy.
  static const assetPath = 'assets/legal/privacy_notice.md';

  static final Future<String> _privacyNotice = rootBundle.loadString(assetPath);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Title(
      title: '${l10n.privacyNoticeNavigationLabel} | ${l10n.brandName}',
      color: AppColors.primary,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: markdownData == null
                    ? FutureBuilder<String>(
                        future: _privacyNotice,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return _PrivacyNoticeDocument(
                              markdownData: snapshot.requireData,
                              onLinkLaunch: onLinkLaunch,
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  AppSizes.minimumPageGutter,
                                ),
                                child: Text(
                                  l10n.privacyNoticeLoadError,
                                  key: const Key('privacyNoticeLoadError'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                key: Key('privacyNoticeLoading'),
                              ),
                            );
                          }
                        },
                      )
                    : _PrivacyNoticeDocument(
                        markdownData: markdownData!,
                        onLinkLaunch: onLinkLaunch,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _PrivacyNoticeDocument extends StatelessWidget {
  const _PrivacyNoticeDocument({
    required this.markdownData,
    required this.onLinkLaunch,
  });

  final String markdownData;
  final ValueChanged<Uri>? onLinkLaunch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      final pageGutter = AppSizes.pageGutterFor(constraints.maxWidth);
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
      final styleSheet =
          MarkdownStyleSheet.fromTheme(
            Theme.of(context),
          ).copyWith(
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
      return SingleChildScrollView(
        key: const Key('privacyNoticeScrollView'),
        padding: EdgeInsets.fromLTRB(
          pageGutter,
          isNarrow ? 40 : 64,
          pageGutter,
          isNarrow ? 64 : 96,
        ),
        child: Center(
          child: ConstrainedBox(
            key: const Key('privacyNoticeContent'),
            constraints: const BoxConstraints(maxWidth: 800),
            child: MarkdownBody(
              key: const Key('privacyNoticeMarkdown'),
              data: markdownData,
              blockSyntaxes: const [_PrivacyContactBlockSyntax()],
              softLineBreak: true,
              styleSheet: styleSheet,
              listItemCrossAxisAlignment:
                  MarkdownListItemCrossAxisAlignment.start,
              builders: <String, MarkdownElementBuilder>{
                'h1': _PrivacyHeadingBuilder(
                  key: const Key('privacyNoticeDocumentHeading'),
                ),
                'h2': _PrivacyHeadingBuilder(),
                'h3': _PrivacyHeadingBuilder(),
                'privacy-contact': _PrivacyContactBlockBuilder(
                  bodyStyle: bodyStyle,
                  linkStyle: linkStyle,
                  onLinkLaunch: onLinkLaunch,
                ),
              },
              imageBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
    },
  );
}

final class _PrivacyContactBlockSyntax extends markdown.BlockSyntax {
  const _PrivacyContactBlockSyntax();

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

final class _PrivacyContactBlockBuilder extends MarkdownElementBuilder {
  _PrivacyContactBlockBuilder({
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
        _PrivacyContactLine(
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

final class _PrivacyContactLine extends StatelessWidget {
  const _PrivacyContactLine({
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
      return _PrivacyEmailLinkRow(
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
    } else {
      return null;
    }
  } else {
    return null;
  }
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

final class _PrivacyEmailLinkRow extends StatelessWidget {
  const _PrivacyEmailLinkRow({
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

final class _PrivacyHeadingBuilder extends MarkdownElementBuilder {
  _PrivacyHeadingBuilder({this.key});

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
    child: Text(
      element.textContent,
      style: preferredStyle,
    ),
  );
}
