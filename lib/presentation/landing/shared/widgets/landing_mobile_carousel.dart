import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_carousel_navigation.dart';
import 'package:fun_app_landing_page/presentation/landing/theme/landing_motion.dart';

/// Minimal page, input, and navigation shell shared by landing carousels.
final class LandingMobileCarousel extends StatefulWidget {
  /// Creates a clamped, non-looping mobile carousel.
  const LandingMobileCarousel({
    required this.itemCount,
    required this.itemBuilder,
    required this.viewportFraction,
    required this.pageHeight,
    required this.itemGap,
    required this.previousSemanticLabel,
    required this.nextSemanticLabel,
    required this.pageSemanticLabelBuilder,
    super.key,
  }) : assert(itemCount > 0, 'A carousel needs at least one page.'),
       assert(
         viewportFraction > 0 && viewportFraction <= 1,
         'The page extent must fit within the clipped viewport.',
       ),
       assert(pageHeight > 0, 'The carousel viewport must have height.'),
       assert(itemGap >= 0, 'The page gap cannot be negative.');

  /// Number of pages in display order.
  final int itemCount;

  /// Builds one section-owned page.
  final IndexedWidgetBuilder itemBuilder;

  /// Portion of the locally clipped viewport occupied by one page extent.
  final double viewportFraction;

  /// Fixed viewport height selected by the consuming section.
  final double pageHeight;

  /// Trailing space included in every page extent.
  final double itemGap;

  /// Localized previous-control label.
  final String previousSemanticLabel;

  /// Localized next-control label.
  final String nextSemanticLabel;

  /// Builds the localized, one-based current-page announcement.
  final String Function(int currentPage, int pageCount)
  pageSemanticLabelBuilder;

  @override
  State<LandingMobileCarousel> createState() => _LandingMobileCarouselState();
}

final class _LandingMobileCarouselState extends State<LandingMobileCarousel> {
  PageController? _controller;
  var _currentPage = 0;
  var _pageMovementPending = false;

  PageController get _pageController => _controller!;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  @override
  void didUpdateWidget(LandingMobileCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final lastPage = widget.itemCount - 1;
    final clampedPage = _currentPage.clamp(0, lastPage);
    final geometryChanged =
        oldWidget.viewportFraction != widget.viewportFraction;
    final countChanged = oldWidget.itemCount != widget.itemCount;

    if (geometryChanged || countChanged) {
      final oldController = _controller;
      _currentPage = clampedPage;
      _pageMovementPending = false;
      _controller = _createController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        oldController?.dispose();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  PageController _createController() => PageController(
    initialPage: _currentPage,
    viewportFraction: widget.viewportFraction,
  );

  Future<void> _moveTo(int requestedPage) async {
    final targetPage = requestedPage.clamp(0, widget.itemCount - 1);

    if (!_pageMovementPending &&
        targetPage != _currentPage &&
        _pageController.hasClients) {
      _pageMovementPending = true;
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;

      if (disableAnimations) {
        _pageController.jumpToPage(targetPage);
      } else {
        await _pageController.animateToPage(
          targetPage,
          duration: LandingMotion.standardDuration,
          curve: LandingMotion.standardCurve,
        );
      }

      if (mounted) {
        _pageMovementPending = false;
      }
    }
  }

  void _handlePageChanged(int page) {
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  void _handleHorizontalKey(bool pointsRight) {
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    final movesForward = pointsRight == isLtr;
    final destination = _currentPage + (movesForward ? 1 : -1);
    unawaited(_moveTo(destination));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final navigationWidth =
          (constraints.maxWidth * widget.viewportFraction) - widget.itemGap;

      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              _handleHorizontalKey(false),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              _handleHorizontalKey(true),
        },
        child: Column(
          key: const Key('landingMobileCarousel'),
          children: [
            SizedBox(
              key: const Key('landingMobileCarouselViewport'),
              height: widget.pageHeight,
              child: PageView.builder(
                key: const Key('landingMobileCarouselPageView'),
                controller: _pageController,
                itemCount: widget.itemCount,
                padEnds: false,
                onPageChanged: _handlePageChanged,
                itemBuilder: (context, index) => Padding(
                  key: Key('landingMobileCarouselPage$index'),
                  padding: EdgeInsetsDirectional.only(end: widget.itemGap),
                  child: widget.itemBuilder(context, index),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                width: navigationWidth,
                child: LandingCarouselNavigation(
                  currentPage: _currentPage,
                  pageCount: widget.itemCount,
                  previousSemanticLabel: widget.previousSemanticLabel,
                  nextSemanticLabel: widget.nextSemanticLabel,
                  onPrevious: _currentPage > 0
                      ? () => _moveTo(_currentPage - 1)
                      : null,
                  onNext: _currentPage < widget.itemCount - 1
                      ? () => _moveTo(_currentPage + 1)
                      : null,
                ),
              ),
            ),
            Semantics(
              key: const Key('landingCarouselCurrentPageSemantics'),
              label: widget.pageSemanticLabelBuilder(
                _currentPage + 1,
                widget.itemCount,
              ),
              liveRegion: true,
              container: true,
              excludeSemantics: true,
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      );
    },
  );
}
