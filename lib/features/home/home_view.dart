import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/text_link.dart';
import '../../models/course.dart';
import '../../models/review.dart';
import '../exchange/exchange_screen.dart';
import 'widgets/course_cover.dart';

/// The default state of the Courses tab.
class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.courses,
    required this.reviews,
    required this.onSearch,
    required this.onOpenCourse,
  });

  final List<Course> courses;
  final List<Review> reviews;
  final VoidCallback onSearch;
  final ValueChanged<Course> onOpenCourse;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text('Courses', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.sm),
        Text('Find a course and see what students say.', style: AppTextStyles.lead),
        const SizedBox(height: AppSpacing.xl),
        _SearchBar(onTap: onSearch),
        const SizedBox(height: AppSpacing.xl),
        Text('Browse courses', style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.md),
        _Shelf(courses: courses, onOpenCourse: onOpenCourse),
        const SizedBox(height: AppSpacing.xl),
        Text('Exchange and Erasmus', style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          key: const Key('open-exchange'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ExchangeScreen()),
          ),
          child: Row(
            children: [
              const Icon(Icons.public_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Where students go', style: AppTextStyles.bodyStrong),
                    Text(
                      'Maps of Europe and the world, with posts.',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Latest reviews', style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.md),
        for (final (i, review) in reviews.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _ReviewCard(
            review: review,
            onTap: () {
              final course = courses
                  .where((c) => c.code == review.courseCode)
                  .firstOrNull;
              if (course != null) onOpenCourse(course);
            },
          ),
        ],
        // Developer shortcut kept from the placeholder; hidden in release.
        if (kDebugMode) ...[
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: TextLink(
              label: 'Widget gallery',
              muted: true,
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.gallery),
            ),
          ),
        ],
      ],
    );
  }
}

/// Looks like the search input but only opens search when tapped.
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search courses',
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          key: const Key('search-bar'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: FieldBox(
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.muted),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Search by code or title',
                    style: AppTextStyles.input.copyWith(color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Courses side by side that scroll sideways. Covers share one height even
/// when a title wraps.
class _Shelf extends StatelessWidget {
  const _Shelf({required this.courses, required this.onOpenCourse});

  final List<Course> courses;
  final ValueChanged<Course> onOpenCourse;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, course) in courses.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 150,
                child: CourseCover(
                  key: Key('shelf-${course.code}'),
                  course: course,
                  onTap: () => onOpenCourse(course),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.onTap});

  final Review review;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${review.courseCode} · ${review.term}',
            style: AppTextStyles.label.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            review.text,
            style: AppTextStyles.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          if (review.topics.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [for (final t in review.topics) TagChip(t.label)],
            ),
          ],
        ],
      ),
    );
  }
}
