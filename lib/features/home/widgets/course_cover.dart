import 'package:flutter/material.dart';

import '../../../core/art/sakura_branch.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/course.dart';

/// A course's sakura branch with its code and title, for the Home shelf.
/// A branch needs ratings; without them the cover shows a plain branch.
class CourseCover extends StatelessWidget {
  const CourseCover({super.key, required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = course.ratings;
    return Semantics(
      button: true,
      label: '${course.code} ${course.title}',
      child: Material(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: SakuraBranch(
                    seed: course.code,
                    difficulty: r?.difficulty ?? 3,
                    workload: r?.workload ?? 3,
                    attendance: r?.attendance ?? 3.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(course.code, style: AppTextStyles.bodyStrong),
                Text(
                  course.title,
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
