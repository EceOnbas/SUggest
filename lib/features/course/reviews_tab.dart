import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/state_views.dart';
import '../../models/review.dart';
import '../../models/review_topic.dart';
import 'review_filter.dart';
import 'widgets/review_filter_sheet.dart';

/// The Reviews tab: topic chips, a count with the filter button, then the
/// reviews that match as cards.
///
/// The filter lives in the course page, so it is still there after a
/// visit to another tab.
class ReviewsTab extends StatelessWidget {
  const ReviewsTab({
    super.key,
    required this.reviews,
    required this.filter,
    required this.onFilterChanged,
  });

  /// Every review of the course.
  final List<Review> reviews;
  final ReviewFilter filter;
  final ValueChanged<ReviewFilter> onFilterChanged;

  static const _all = 'All';

  /// Side padding of the course page. The chip row scrolls under it.
  static const _gutter = 20.0;

  Future<void> _openSheet(BuildContext context) async {
    final chosen = await showReviewFilterSheet(
      context: context,
      reviews: reviews,
      filter: filter,
    );
    if (chosen != null) onFilterChanged(chosen);
  }

  void _selectTopic(String label) {
    ReviewTopic? topic;
    for (final t in ReviewTopic.values) {
      if (t.label == label) topic = t;
    }
    onFilterChanged(filter.withTopic(topic));
  }

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: _gutter),
        child: EmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No reviews yet',
          message: 'Be the first to review this course.',
        ),
      );
    }

    final shown = filter.apply(reviews);
    final topic = filter.topic;
    final filterCount = filter.sheetFilterCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: 'Filter by topic',
          child: ChipFilterRow(
            options: [_all, for (final t in ReviewTopic.values) t.label],
            selected: topic?.label ?? _all,
            onSelected: _selectTopic,
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // A Wrap, so the button moves under the count when they do
              // not fit side by side.
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: [
                  Text(
                    topic == null
                        ? '${shown.length} shown'
                        : '${shown.length} shown about '
                              '${topic.label.toLowerCase()}',
                    style: AppTextStyles.helper,
                  ),
                  AppChip(
                    label: filterCount == 0
                        ? 'Term and instructor'
                        : 'Filters ($filterCount)',
                    onTap: () => _openSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (shown.isEmpty)
                EmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  title: 'No reviews match',
                  message: 'Try another topic, term or instructor.',
                  actionLabel: 'Clear filters',
                  onAction: () => onFilterChanged(const ReviewFilter()),
                ),
              for (final (i, review) in shown.indexed) ...[
                if (i > 0) const SizedBox(height: 14),
                _ReviewCard(review: review),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One anonymous review: when and with whom, the text, and its topics.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${review.term}, ${review.instructor}',
            style: AppTextStyles.helper,
          ),
          const SizedBox(height: 10),
          Text(
            review.text,
            style: AppTextStyles.body.copyWith(
              height: 1.5,
              color: AppColors.ink,
            ),
          ),
          if (review.topics.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final topic in review.topics) TagChip(topic.label),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
