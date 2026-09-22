import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Builds a visual-only transition from one-time reveal [progress].
typedef LandingScrollRevealBuilder = Widget Function(
  BuildContext context,
  double progress,
  Widget child,
);

/// Reveals one landing presentation surface as it approaches the viewport.
///
/// The wrapper observes its nearest scroll position only until the first
/// reveal. Its child remains laid out and semantically available throughout.
final class LandingScrollReveal extends StatefulWidget {
  /// Creates a presentation-local, one-time scroll reveal.
  const LandingScrollReveal({
    required this.duration,
    required this.transitionBuilder,
    required this.child,
    this.triggerViewportFraction = 0.825,
    super.key,
  });

  /// Total duration of the visual transition.
  final Duration duration;

  /// Builds the paint-only transition for progress from zero to one.
  final LandingScrollRevealBuilder transitionBuilder;

  /// Content kept in the tree before, during, and after the reveal.
  final Widget child;

  /// Viewport fraction where the content's leading edge triggers its reveal.
  final double triggerViewportFraction;

  @override
  State<LandingScrollReveal> createState() => _LandingScrollRevealState();
}

final class _LandingScrollRevealState extends State<LandingScrollReveal> {
  ScrollPosition? _scrollPosition;
  var _disableAnimations = false;
  var _revealed = false;
  var _visibilityCheckScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final mediaQuery = MediaQuery.maybeOf(context);
    _disableAnimations = mediaQuery?.disableAnimations ?? false;

    if (_disableAnimations) {
      _revealed = true;
      _detachScrollPosition();
    } else if (!_revealed) {
      _replaceScrollPosition(Scrollable.maybeOf(context)?.position);
      _scheduleVisibilityCheck();
    }
  }

  @override
  void didUpdateWidget(LandingScrollReveal oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_disableAnimations && !_revealed) {
      _scheduleVisibilityCheck();
    }
  }

  @override
  void dispose() {
    _detachScrollPosition();
    super.dispose();
  }

  void _replaceScrollPosition(ScrollPosition? scrollPosition) {
    if (!identical(_scrollPosition, scrollPosition)) {
      _detachScrollPosition();
      _scrollPosition = scrollPosition;
      _scrollPosition?.addListener(_scheduleVisibilityCheck);
    }
  }

  void _detachScrollPosition() {
    _scrollPosition?.removeListener(_scheduleVisibilityCheck);
    _scrollPosition = null;
  }

  void _scheduleVisibilityCheck() {
    if (!_visibilityCheckScheduled && !_revealed && !_disableAnimations) {
      _visibilityCheckScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _visibilityCheckScheduled = false;
        if (mounted) {
          _checkVisibility();
        }
      });
    }
  }

  void _checkVisibility() {
    final scrollPosition = _scrollPosition;
    final renderObject = context.findRenderObject();
    final canCheck =
        scrollPosition != null &&
        scrollPosition.hasContentDimensions &&
        scrollPosition.viewportDimension > 0 &&
        renderObject is RenderBox &&
        renderObject.attached &&
        renderObject.hasSize;

    if (canCheck) {
      final viewport = RenderAbstractViewport.of(renderObject);
      final targetOffset = viewport.getOffsetToReveal(renderObject, 0).offset;
      final leadingEdge = targetOffset - scrollPosition.pixels;
      final trailingEdge = leadingEdge + renderObject.size.height;
      final triggerEdge =
          scrollPosition.viewportDimension * widget.triggerViewportFraction;
      final approachesViewport = leadingEdge <= triggerEdge && trailingEdge > 0;

      if (approachesViewport) {
        _detachScrollPosition();
        setState(() => _revealed = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_disableAnimations) {
      return widget.transitionBuilder(context, 1, widget.child);
    } else {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: _revealed ? 1 : 0,
          end: _revealed ? 1 : 0,
        ),
        duration: _revealed ? widget.duration : Duration.zero,
        builder: (context, progress, child) =>
            widget.transitionBuilder(context, progress, child!),
        child: widget.child,
      );
    }
  }
}
