import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/landing/shared/widgets/landing_carousel_control.dart';

/// Shared arrow controls and decorative page indicators for mobile carousels.
final class LandingCarouselNavigation extends StatelessWidget {
  /// Creates carousel navigation for the current page.
  const LandingCarouselNavigation({
    required this.currentPage,
    required this.pageCount,
    required this.previousSemanticLabel,
    required this.nextSemanticLabel,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  /// Zero-based current page.
  final int currentPage;

  /// Total number of pages.
  final int pageCount;

  /// Localized label for the previous control.
  final String previousSemanticLabel;

  /// Localized label for the next control.
  final String nextSemanticLabel;

  /// Requests the preceding page, or null at the first page.
  final VoidCallback? onPrevious;

  /// Requests the following page, or null at the last page.
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const Key('landingCarouselNavigation'),
    height: 44,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        LandingCarouselControl(
          key: const Key('landingCarouselPrevious'),
          semanticLabel: previousSemanticLabel,
          onPressed: onPrevious,
          pointsForward: false,
        ),
        ExcludeSemantics(
          child: Row(
            key: const Key('landingCarouselPagination'),
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < pageCount; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                DecoratedBox(
                  key: Key('landingCarouselDot$index'),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(
                      alpha: index == currentPage ? 1 : 0.2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 10),
                ),
              ],
            ],
          ),
        ),
        LandingCarouselControl(
          key: const Key('landingCarouselNext'),
          semanticLabel: nextSemanticLabel,
          onPressed: onNext,
          pointsForward: true,
        ),
      ],
    ),
  );
}
