import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// The three parts of the course page.
enum CourseTab {
  overview('Overview'),
  sections('Sections'),
  reviews('Reviews');

  const CourseTab(this.label);
  final String label;
}

/// Overview / Sections / Reviews. The selected tab is bold with a green
/// line under it.
class CourseTabBar extends StatelessWidget {
  const CourseTabBar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.reviewCount,
  });

  final CourseTab selected;
  final ValueChanged<CourseTab> onSelected;

  /// Shown as "Reviews (4)"; null while the reviews are loading.
  final int? reviewCount;

  String _labelOf(CourseTab tab) =>
      tab == CourseTab.reviews && reviewCount != null
      ? '${tab.label} ($reviewCount)'
      : tab.label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.borderStrong)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final tab in CourseTab.values)
            Expanded(
              child: _Tab(
                label: _labelOf(tab),
                selected: tab == selected,
                onTap: () => onSelected(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 3,
                color: selected ? AppColors.primary : Colors.transparent,
              ),
            ),
          ),
          child: Center(
            // Shrinks to fit a third of a narrow screen.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTextStyles.body.copyWith(
                    height: 1.2,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Keeps the [CourseTabBar] at the top of the screen while the page
/// scrolls under it.
class CourseTabBarDelegate extends SliverPersistentHeaderDelegate {
  const CourseTabBarDelegate({required this.height, required this.child});

  final double height;
  final CourseTabBar child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: child);

  @override
  bool shouldRebuild(CourseTabBarDelegate oldDelegate) =>
      oldDelegate.height != height ||
      oldDelegate.child.selected != child.selected ||
      oldDelegate.child.reviewCount != child.reviewCount;
}
