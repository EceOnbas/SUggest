import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/course.dart';
import '../../../models/review_topic.dart';

/// One search result: code, title, credits and a one-word difficulty.
class CourseResultRow extends StatelessWidget {
  const CourseResultRow({super.key, required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final difficulty = course.ratings?.difficulty;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.code, style: AppTextStyles.bodyStrong),
                Text(course.title, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  difficulty == null
                      ? '${course.suCredits} SU credits · not enough ratings yet'
                      : '${course.suCredits} SU credits · '
                            '${ReviewTopic.difficulty.wordFor(difficulty)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
