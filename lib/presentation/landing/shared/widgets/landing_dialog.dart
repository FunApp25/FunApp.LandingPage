import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';

/// Shows a bounded, scroll-safe dialog for landing-page presentation content.
Future<T?> showLandingDialog<T>({
  required BuildContext context,
  required String semanticLabel,
  required String closeTooltip,
  required WidgetBuilder builder,
}) => showLandingDialogRoute<T>(
  context: context,
  barrierLabel: closeTooltip,
  builder: (dialogContext) => LandingDialog(
    semanticLabel: semanticLabel,
    closeTooltip: closeTooltip,
    onClose: () => Navigator.of(dialogContext).pop(),
    child: builder(dialogContext),
  ),
);

/// Applies the same restrained route transition to every landing popup.
Future<T?> showLandingDialogRoute<T>({
  required BuildContext context,
  required String barrierLabel,
  required WidgetBuilder builder,
}) {
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return showGeneralDialog<T>(
    context: context,
    barrierLabel: barrierLabel,
    barrierDismissible: true,
    transitionDuration: reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 180),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            ),
            child: child,
          ),
        ),
  );
}

/// Shared responsive dialog shell for landing-page content.
///
/// The caller supplies content and owns any presentation action. This shell
/// deliberately contains no form, business, or routing state.
final class LandingDialog extends StatefulWidget {
  /// Creates a reusable landing dialog surface.
  const LandingDialog({
    required this.semanticLabel,
    required this.closeTooltip,
    required this.onClose,
    required this.child,
    this.footer,
    super.key,
  });

  /// Meaningful route label announced for the dialog.
  final String semanticLabel;

  /// Localized tooltip and semantic label for the close control.
  final String closeTooltip;

  /// Dismisses the dialog, or null while dismissal is unavailable.
  final VoidCallback? onClose;

  /// Caller-supplied dialog content.
  final Widget child;

  /// Optional action area kept outside the independently scrolling content.
  final Widget? footer;

  @override
  State<LandingDialog> createState() => _LandingDialogState();
}

final class _LandingDialogState extends State<LandingDialog> {
  var _showTopFade = false;
  var _showBottomFade = false;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth == 0) {
      _updateFades(notification.metrics);
    }
    return false;
  }

  bool _onMetricsChanged(ScrollMetricsNotification notification) {
    if (notification.depth == 0) {
      _updateFades(notification.metrics);
    }
    return false;
  }

  void _updateFades(ScrollMetrics metrics) {
    final showTopFade = metrics.extentBefore > 0.5;
    final showBottomFade = widget.footer != null && metrics.extentAfter > 0.5;
    if (showTopFade != _showTopFade || showBottomFade != _showBottomFade) {
      setState(() {
        _showTopFade = showTopFade;
        _showBottomFade = showBottomFade;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    namesRoute: true,
    label: widget.semanticLabel,
    child: Dialog(
      key: const Key('landingDialog'),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.minimumPageGutter,
        vertical: 24,
      ),
      constraints: const BoxConstraints(maxWidth: 560),
      backgroundColor: AppColors.lightForeground,
      surfaceTintColor: AppColors.lightForeground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.cardRadius)),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          key: const Key('landingDialogSurface'),
          constraints: BoxConstraints(maxHeight: constraints.maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Semantics(
                  key: const Key('landingDialogCloseButton'),
                  container: true,
                  button: true,
                  enabled: widget.onClose != null,
                  label: widget.closeTooltip,
                  child: IconButton(
                    tooltip: widget.closeTooltip,
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
              Flexible(
                child: NotificationListener<ScrollMetricsNotification>(
                  onNotification: _onMetricsChanged,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          key: const Key('landingDialogScrollView'),
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: widget.child,
                        ),
                        if (_showTopFade)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: SizedBox(
                                key: const Key('landingDialogTopFade'),
                                height: 24,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.lightForeground,
                                        AppColors.lightForeground.withValues(
                                          alpha: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_showBottomFade)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: SizedBox(
                                key: const Key('landingDialogBottomFade'),
                                height: 24,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.lightForeground.withValues(
                                          alpha: 0,
                                        ),
                                        AppColors.lightForeground,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.footer != null)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: (constraints.maxHeight - 96).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: Padding(
                    key: const Key('landingDialogFooter'),
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: widget.footer,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
