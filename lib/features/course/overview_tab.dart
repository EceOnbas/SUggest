import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/note_box.dart';
import '../../core/widgets/text_link.dart';
import '../../models/course.dart';
import '../../models/review_topic.dart';
import 'widgets/section_heading.dart';

/// The Overview tab: what the branch means, the four ratings, the course
/// description, its prerequisites and who takes it.
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final ratings = course.ratings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ratings == null)
          const NoteBox.info(
            'Not enough ratings yet. The averages appear once enough '
            'students have rated this course.',
          )
        else ...[
          Text(
            'The branch comes from the ratings: more blossoms, stricter '
            'attendance. Deeper pink, harder course. Thicker branches, '
            'heavier workload.',
            style: AppTextStyles.helper,
          ),
          const SizedBox(height: AppSpacing.sm),
          _DifficultyBar(difficulty: ratings.difficulty),
          const SizedBox(height: AppSpacing.xl),
          SectionHeading('Ratings', trailing: 'from ${ratings.count} students'),
          const SizedBox(height: AppSpacing.md),
          _RatingsGrid(ratings: ratings),
        ],
        if (course.about.isNotEmpty) ...[
          const SizedBox(height: 28),
          const SectionHeading('About'),
          const SizedBox(height: 10),
          Text(
            course.about,
            style: AppTextStyles.body.copyWith(
              height: 1.55,
              color: AppColors.inkSoft,
            ),
          ),
          if (course.syllabusTerm != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextLink(
                label: 'Syllabus, ${course.syllabusTerm}',
                fontSize: 16,
                onPressed: () => AppToast.show(
                  context,
                  'The syllabus opens here once it is linked.',
                ),
              ),
            ),
        ],
        const SizedBox(height: 28),
        const SectionHeading('Before and after'),
        const SizedBox(height: AppSpacing.md),
        _CourseLinksRow(
          label: 'Prerequisite',
          codes: course.prerequisites,
          filled: true,
        ),
        const SizedBox(height: 10),
        _CourseLinksRow(label: 'Corequisite', codes: course.corequisites),
        const SizedBox(height: 10),
        _CourseLinksRow(label: 'Unlocks', codes: course.unlocks),
        if (course.majorShares.isNotEmpty) ...[
          const SizedBox(height: 28),
          const SectionHeading('Who takes it'),
          const SizedBox(height: AppSpacing.md),
          _MajorSharesBar(shares: course.majorShares),
          const SizedBox(height: AppSpacing.md),
          _MajorSharesLegend(shares: course.majorShares),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Anonymous totals. Hidden until enough students contribute.',
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }
}

/// The Easy–Hard bar: a pink ramp with a marker at the course's
/// difficulty.
class _DifficultyBar extends StatelessWidget {
  const _DifficultyBar({required this.difficulty});

  /// From 1 (easy) to 5 (hard).
  final double difficulty;

  @override
  Widget build(BuildContext context) {
    // 1 is the left end of the bar and 5 is the right end.
    final position = ((difficulty - 1) / 4).clamp(0.0, 1.0);
    return Row(
      children: [
        Text('Easy', style: AppTextStyles.caption),
        const SizedBox(width: 10),
        Expanded(
          child: Semantics(
            image: true,
            label: 'Difficulty ${difficulty.toStringAsFixed(1)} out of 5',
            child: SizedBox(
              height: 18,
              child: LayoutBuilder(
                builder: (context, box) => Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 4,
                      height: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          gradient: const LinearGradient(
                            colors: AppColors.sakuraRamp,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (box.maxWidth - 4) * position,
                      top: 0,
                      width: 4,
                      height: 18,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('Hard', style: AppTextStyles.caption),
      ],
    );
  }
}

/// The four averages: number, name and a word for it ("fairly hard").
class _RatingsGrid extends StatelessWidget {
  const _RatingsGrid({required this.ratings});

  final CourseRatings ratings;

  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Container(
      padding: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.ink, width: 1.5)),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          // Four in a row when they fit; two rows of two on a narrow
          // screen or with large text.
          final columns = box.maxWidth >= 340 && textScale <= 1.15 ? 4 : 2;
          final width = ((box.maxWidth - _gap * (columns - 1)) / columns)
              .floorToDouble();
          return Wrap(
            spacing: _gap,
            runSpacing: AppSpacing.lg,
            children: [
              for (final topic in ReviewTopic.values)
                SizedBox(
                  width: width,
                  child: _RatingCell(
                    topic: topic,
                    value: ratings.valueOf(topic),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RatingCell extends StatelessWidget {
  const _RatingCell({required this.topic, required this.value});

  final ReviewTopic topic;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.toStringAsFixed(1),
          style: AppTextStyles.courseTitle.copyWith(
            height: 1,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          topic.label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(topic.wordFor(value), style: AppTextStyles.caption),
      ],
    );
  }
}

/// One line of "Before and after": a label, then the course codes as
/// chips that open that course, or "None".
class _CourseLinksRow extends StatelessWidget {
  const _CourseLinksRow({
    required this.label,
    required this.codes,
    this.filled = false,
  });

  final String label;
  final List<String> codes;

  /// Dark chips, used for prerequisites.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    // The label column grows with the user's text size.
    final labelWidth = MediaQuery.textScalerOf(context)
        .scale(104)
        .clamp(104.0, 160.0);
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: codes.isEmpty
              ? Text(
                  'None',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final code in codes)
                      AppChip(
                        label: code,
                        compact: true,
                        selected: filled,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.course,
                          arguments: code,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Colors of the "Who takes it" slices, in order. "Other" is always grey.
Color _shareColor(int index, MajorShare share) {
  const colors = [AppColors.ink, AppColors.primary, AppColors.sakura3];
  if (share.major == 'Other') return AppColors.track;
  return colors[index % colors.length];
}

/// One bar split by major: each slice is as wide as its share.
class _MajorSharesBar extends StatelessWidget {
  const _MajorSharesBar({required this.shares});

  final List<MajorShare> shares;

  @override
  Widget build(BuildContext context) {
    const round = Radius.circular(AppRadius.pill);
    const square = Radius.circular(4);
    return ExcludeSemantics(
      child: SizedBox(
        height: 16,
        child: Row(
          children: [
            for (final (i, share) in shares.indexed) ...[
              if (i > 0) const SizedBox(width: 3),
              Expanded(
                flex: share.percent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _shareColor(i, share),
                    // Only the two ends of the bar are fully rounded.
                    borderRadius: BorderRadius.horizontal(
                      left: i == 0 ? round : square,
                      right: i == shares.length - 1 ? round : square,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The names under the bar, in two columns, each with its slice's color.
class _MajorSharesLegend extends StatelessWidget {
  const _MajorSharesLegend({required this.shares});

  final List<MajorShare> shares;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final width = ((box.maxWidth - _gap) / 2).floorToDouble();
        return Wrap(
          spacing: _gap,
          runSpacing: 6,
          children: [
            for (final (i, share) in shares.indexed)
              SizedBox(
                width: width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 5, right: 6),
                      decoration: BoxDecoration(
                        color: _shareColor(i, share),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${share.major} ${share.percent}%',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
