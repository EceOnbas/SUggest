import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/text_link.dart';
import '../models/my_review.dart';
import 'profile_widgets.dart';

/// One of my reviews. Closed, it shows the course, dates and the start
/// of the feedback; "show more" opens the tags, the four ratings, the
/// full feedback and the Edit and Delete buttons.
class MyReviewCard extends StatefulWidget {
  const MyReviewCard({
    super.key,
    required this.review,
    required this.onEdit,
    required this.onDelete,
    this.handle,
    this.initiallyExpanded = false,
  });

  final MyReview review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// The author's public handle, shown as "Posted as @handle".
  final String? handle;

  /// Opens the card at the start, for example in the review sheet.
  final bool initiallyExpanded;

  /// Longer feedback is cut to this many characters while closed.
  static const snippetLength = 145;

  @override
  State<MyReviewCard> createState() => _MyReviewCardState();
}

class _MyReviewCardState extends State<MyReviewCard> {
  late bool _expanded = widget.initiallyExpanded;

  void _toggle() => setState(() => _expanded = !_expanded);

  String get _snippet {
    final text = widget.review.feedback;
    if (text.length <= MyReviewCard.snippetLength) return text;
    return '${text.substring(0, MyReviewCard.snippetLength).trimRight()}…';
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final feedbackStyle = AppTextStyles.body.copyWith(color: AppColors.inkSoft);
    return AppCard(
      outlined: true,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(review.courseLabel, style: AppTextStyles.bodyStrong),
          Text(
            '${review.term} · ${review.instructor}',
            style: AppTextStyles.helper,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              if (widget.handle case final handle?)
                Text(
                  'Posted as @$handle',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              Text(
                'Posted: ${formatReviewDate(review.posted)}',
                style: AppTextStyles.caption,
              ),
              if (review.edited != null)
                Text(
                  'Edited: ${formatReviewDate(review.edited!)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkSoft,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (!_expanded) ...[
            if (review.feedback.isNotEmpty)
              Text(_snippet, style: feedbackStyle),
            TextLink(label: '...show more', onPressed: _toggle),
          ] else ...[
            if (review.tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in review.tags) TagChip.topic(tag.label),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _RatingsGrid(review: review),
            if (review.feedback.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(review.feedback, style: feedbackStyle),
            ],
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.borderStrong),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton.icon(
                  style: compactPillStyle(),
                  onPressed: widget.onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Review'),
                ),
                OutlinedButton.icon(
                  style: compactPillStyle(color: AppColors.error),
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete Review'),
                ),
              ],
            ),
            TextLink(label: 'show less', onPressed: _toggle),
          ],
        ],
      ),
    );
  }
}

/// The four scores of a review. Four columns on a wide screen, two on a
/// phone, one with very large text, so no title is cut.
class _RatingsGrid extends StatelessWidget {
  const _RatingsGrid({required this.review});

  final MyReview review;

  /// The narrowest a column may be at normal text size.
  static const _minColumnWidth = 88.0;
  static const _gap = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final minWidth = MediaQuery.textScalerOf(context).scale(_minColumnWidth);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final fits = (box.maxWidth / minWidth).floor();
          final columns = fits >= 4 ? 4 : (fits >= 2 ? 2 : 1);
          final cellWidth = (box.maxWidth - _gap * (columns - 1)) / columns;
          return Wrap(
            spacing: _gap,
            runSpacing: AppSpacing.md,
            children: [
              for (final topic in RatingScale.order)
                SizedBox(
                  width: cellWidth,
                  child: _Score(
                    title: topic.ratingTitle,
                    score: review.ratings[topic] ?? 0,
                    word: topic.wordForScore(review.ratings[topic] ?? 1),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.title, required this.score, required this.word});

  final String title;
  final int score;
  final String word;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        children: [
          Text('$score', style: AppTextStyles.heading.copyWith(height: 1)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          Text(word, textAlign: TextAlign.center, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
