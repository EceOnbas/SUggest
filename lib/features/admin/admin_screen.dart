import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/note_box.dart';
import '../../core/widgets/state_views.dart';
import '../../data/mock_data.dart';
import '../../models/review.dart';
import '../program/models/program_post.dart';
import '../program/program_post_store.dart';
import '../program/widgets/post_card.dart';

/// The admin panel. Admins do not approve content first:
/// they remove a post or review that breaks the community rules with
/// its delete icon, after confirming.
///
/// Two lists, picked with the chips: program posts and course reviews.
/// Step 2 has no admin accounts yet, so the screen opens from the
/// Community tab. Open it with
/// `Navigator.pushNamed(context, AppRoutes.admin)`.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  static const postsTab = 'Posts';
  static const reviewsTab = 'Reviews';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _tab = AdminScreen.postsTab;

  /// This screen's copy of the reviews, so removing one updates the list.
  /// In Step 3 removing deletes it from Firebase.
  final List<Review> _reviews = [...MockData.reviews];

  Future<void> _deletePost(ProgramPost post) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete this post?',
      message:
          'It will be removed from the ${post.programName} page. This '
          'cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    ProgramPostStore.instance.remove(post.id);
    AppToast.show(context, 'Post deleted.');
  }

  Future<void> _deleteReview(Review review) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete this review?',
      message:
          'It will be removed from the ${review.courseCode} course page. '
          'This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _reviews.removeWhere((r) => r.id == review.id));
    AppToast.show(context, 'Review deleted.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: ProgramPostStore.instance,
          builder: (context, _) {
            final posts = ProgramPostStore.instance.all;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Row(
                  children: [
                    const AppBackButton(),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          'Admin panel',
                          style: AppTextStyles.heading.copyWith(fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const NoteBox.info(
                  'Admin view. Delete posts and reviews that break the '
                  'community rules.',
                ),
                const SizedBox(height: AppSpacing.lg),
                ChipFilterRow(
                  options: const [AdminScreen.postsTab, AdminScreen.reviewsTab],
                  selected: _tab,
                  onSelected: (tab) => setState(() => _tab = tab),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _tab == AdminScreen.postsTab
                      ? _countLabel(posts.length, 'post')
                      : _countLabel(_reviews.length, 'review'),
                  style: AppTextStyles.helper,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_tab == AdminScreen.postsTab)
                  ..._buildPosts(posts)
                else
                  ..._buildReviews(),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _countLabel(int count, String noun) =>
      count == 1 ? '1 $noun' : '$count ${noun}s';

  List<Widget> _buildPosts(List<ProgramPost> posts) {
    if (posts.isEmpty) {
      return const [
        EmptyState(
          icon: Icons.forum_outlined,
          title: 'No posts to review',
          message: 'New program posts will show up here.',
        ),
      ];
    }
    return [
      for (final post in posts) ...[
        PostCard(
          post: post,
          showProgram: true,
          onDelete: () => _deletePost(post),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    ];
  }

  List<Widget> _buildReviews() {
    if (_reviews.isEmpty) {
      return const [
        EmptyState(
          icon: Icons.rate_review_outlined,
          title: 'No reviews to review',
          message: 'New course reviews will show up here.',
        ),
      ];
    }
    return [
      for (final review in _reviews) ...[
        _AdminReviewCard(
          review: review,
          onDelete: () => _deleteReview(review),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    ];
  }
}

/// A course review with its course, author and a red delete icon.
class _AdminReviewCard extends StatelessWidget {
  const _AdminReviewCard({required this.review, required this.onDelete});

  final Review review;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final author = review.authorHandle == null
        ? 'Anonymous'
        : '@${review.authorHandle}';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.courseCode, style: AppTextStyles.bodyStrong),
                    Text(
                      '$author, ${review.term}, ${review.instructor}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete review',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review.text, style: AppTextStyles.body),
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
