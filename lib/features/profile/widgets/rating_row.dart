import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/segmented_choice.dart';
import '../../../models/review_topic.dart';
import '../models/my_review.dart';

/// One rating on the Write Review screen: its title, the chosen word
/// ("Hard (4)" or "Not rated") and the 1–5 picker. Nothing is picked at
/// the start.
class RatingRow extends StatelessWidget {
  const RatingRow({
    super.key,
    required this.topic,
    required this.score,
    required this.onChanged,
    this.showError = false,
  });

  final ReviewTopic topic;

  /// From 1 to 5, or null when not rated yet.
  final int? score;
  final ValueChanged<int> onChanged;

  /// Shows "Not rated" in red after a submit without this rating.
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final value = score;
    final status = value == null
        ? 'Not rated'
        : '${topic.wordForScore(value)} ($value)';
    final statusColor = value != null
        ? AppColors.primary
        : showError
        ? AppColors.error
        : AppColors.muted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A Wrap moves the status under the title when they do not fit.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: AppSpacing.md,
          children: [
            Text(topic.ratingTitle, style: AppTextStyles.label),
            Text(
              status,
              style: AppTextStyles.label.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SegmentedChoice<int>(
          options: const [1, 2, 3, 4, 5],
          value: value,
          onChanged: onChanged,
          semanticLabel: topic.ratingTitle,
        ),
      ],
    );
  }
}
