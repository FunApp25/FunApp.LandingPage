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
  const PrivacyNoticePage({this.markdownData, super.key});

  /// Optional already-loaded canonical content used by deterministic tests.
  final String? markdownData;

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
                    : _PrivacyNoticeDocument(markdownData: markdownData!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _PrivacyNoticeDocument extends StatelessWidget {
  const _PrivacyNoticeDocument({required this.markdownData});

  final String markdownData;

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
              },
              onTapLink: _launchApprovedPrivacyNoticeLink,
              imageBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
    },
  );
}

void _launchApprovedPrivacyNoticeLink(
  String _,
  String? href,
  String title,
) {
  final uri = href == null ? null : Uri.tryParse(href);
  final isApprovedContact =
      uri?.scheme == 'mailto' && uri?.path == 'info@funapp.world';

  if (isApprovedContact && uri != null) {
    launchPrivacyNoticeLink(uri);
  }
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
