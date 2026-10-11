/// Build-time feature configuration for the public landing-page release.
final class ReleaseConfiguration {
  /// Creates an explicit release configuration.
  const ReleaseConfiguration({
    required this.unfinishedPreviewEnabled,
  });

  /// Reads the opt-in preview flag embedded at compile time.
  const ReleaseConfiguration.fromEnvironment()
    : unfinishedPreviewEnabled = const bool.fromEnvironment(
        previewDefineName,
      );

  /// Creates the default intermediate public-release configuration.
  const ReleaseConfiguration.intermediateProduction()
    : unfinishedPreviewEnabled = false;

  /// Creates an explicit development/review preview configuration.
  const ReleaseConfiguration.preview() : unfinishedPreviewEnabled = true;

  /// Dart define required to expose unfinished forms and draft legal pages.
  static const previewDefineName = 'FUN_APP_ENABLE_UNFINISHED_PREVIEW';

  /// Whether unfinished prospective-user and legal routes are available.
  final bool unfinishedPreviewEnabled;
}
