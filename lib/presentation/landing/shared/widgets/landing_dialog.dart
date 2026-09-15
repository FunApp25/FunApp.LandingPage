import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_sizes.dart';

/// Shows a bounded, scroll-safe dialog for landing-page presentation content.
Future<T?> showLandingDialog<T>({
  required BuildContext context,
  required String semanticLabel,
  required String closeTooltip,
  required WidgetBuilder builder,
}) => showDialog<T>(
  context: context,
  barrierLabel: closeTooltip,
  builder: (dialogContext) => LandingDialog(
    semanticLabel: semanticLabel,
    closeTooltip: closeTooltip,
    onClose: () => Navigator.of(dialogContext).pop(),
    child: builder(dialogContext),
  ),
);

/// Shared responsive dialog shell for landing-page content.
///
/// The caller supplies content and owns any presentation action. This shell
/// deliberately contains no form, business, or routing state.
final class LandingDialog extends StatelessWidget {
  /// Creates a reusable landing dialog surface.
  const LandingDialog({
    required this.semanticLabel,
    required this.closeTooltip,
    required this.onClose,
    required this.child,
    super.key,
  });

  /// Meaningful route label announced for the dialog.
  final String semanticLabel;

  /// Localized tooltip and semantic label for the close control.
  final String closeTooltip;

  /// Dismisses the dialog.
  final VoidCallback onClose;

  /// Caller-supplied dialog content.
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    namesRoute: true,
    label: semanticLabel,
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
                  label: closeTooltip,
                  child: IconButton(
                    tooltip: closeTooltip,
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  key: const Key('landingDialogScrollView'),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
