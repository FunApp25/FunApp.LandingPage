import 'package:flutter/material.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_colors.dart';
import 'package:fun_app_landing_page/presentation/core/theme/app_text_styles.dart';

/// Accessible in-page navigation control shared by the landing header/footer.
final class LandingNavigationItem extends StatelessWidget {
  /// Creates an in-page navigation item.
  const LandingNavigationItem({
    required this.label,
    required this.onSelected,
    super.key,
  });

  /// Localized visible and semantic label.
  final String label;

  /// Scrolls the landing page to the corresponding section.
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    onTap: onSelected,
    excludeSemantics: true,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        excludeFromSemantics: true,
        mouseCursor: SystemMouseCursors.click,
        focusColor: AppColors.energeticPlum.withValues(alpha: 0.1),
        hoverColor: AppColors.energeticPlum.withValues(alpha: 0.06),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Text(
          label,
          maxLines: 1,
          style: AppTextStyles.landingHeaderNavigation,
        ),
      ),
    ),
  );
}
