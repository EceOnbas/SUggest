import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/state_views.dart';
import '../../data/mock_data.dart';
import '../../models/course.dart';
import 'widgets/section_heading.dart';

/// The Sections tab: this term's sections as cards, then how each
/// instructor was rated in earlier terms.
class SectionsTab extends StatelessWidget {
  const SectionsTab({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    if (course.sections.isEmpty && course.instructorRatings.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_outlined,
        title: 'No sections this term',
        message:
            'Sections appear here when the course is offered in '
            '${MockData.currentTerm}.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading(
          '${MockData.currentTerm} sections',
          trailing: 'from BannerWeb',
        ),
        const SizedBox(height: AppSpacing.md),
        if (course.sections.isEmpty)
          Text('Not offered this term.', style: AppTextStyles.bodySmall),
        for (final (i, section) in course.sections.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _SectionCard(section: section),
        ],
        const SizedBox(height: 28),
        const SectionHeading('Instructor rating by term'),
        const SizedBox(height: AppSpacing.md),
        if (course.instructorRatings.isEmpty)
          Text('No instructor ratings yet.', style: AppTextStyles.bodySmall)
        else
          _InstructorRatingList(ratings: course.instructorRatings),
      ],
    );
  }
}

/// One section: its letter, instructor, lecture and lab times and CRN.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final CourseSection section;

  @override
  Widget build(BuildContext context) {
    final hasLab = section.labId != null;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A Wrap, so the instructor moves to a second line when the two
          // do not fit side by side.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: AppSpacing.md,
            children: [
              Text(
                'Section ${section.id}',
                style: AppTextStyles.button.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(section.instructor, style: AppTextStyles.helper),
            ],
          ),
          const SizedBox(height: 10),
          _TimeLine(label: 'Lecture', times: section.lectureTimes),
          if (hasLab) ...[
            const SizedBox(height: AppSpacing.xs),
            _TimeLine(
              label: 'Lab ${section.labId}',
              times: section.labTimes ?? '',
            ),
          ],
          const SizedBox(height: 10),
          Text(
            hasLab
                ? 'CRN ${section.crn}. Lab is linked: you register both '
                      'together.'
                : 'CRN ${section.crn}.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

/// "**Lecture** Mon 10:40, Wed 10:40": a bold label and its times.
class _TimeLine extends StatelessWidget {
  const _TimeLine({required this.label, required this.times});

  final String label;
  final String times;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.bodySmall.copyWith(color: AppColors.ink);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' $times'),
        ],
      ),
      style: style,
    );
  }
}

/// A plain list: instructor and term on the left, the rating on the right.
class _InstructorRatingList extends StatelessWidget {
  const _InstructorRatingList({required this.ratings});

  final List<InstructorTermRating> ratings;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.ink, width: 1.5)),
      ),
      child: Column(
        children: [
          for (final rating in ratings)
            Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderStrong),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rating.instructor,
                          style: AppTextStyles.bodyStrong.copyWith(height: 1.3),
                        ),
                        Text(
                          '${rating.term}, ${rating.count} ratings',
                          style: AppTextStyles.helper.copyWith(height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    rating.rating.toStringAsFixed(1),
                    style: AppTextStyles.heading.copyWith(fontSize: 24),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
