import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A soft rounded [Card]: section cards, review cards, added courses.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.outlined = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;

  /// Adds a thin grey outline, for cards that sit on a light surface.
  final bool outlined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surfaceMuted,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: outlined
            ? const BorderSide(color: AppColors.border)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
