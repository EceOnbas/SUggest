import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../models/program_post.dart';

/// A program post in an [AppCard]: who wrote it and when, the text, and
/// its topic tag.
///
/// The admin screen sets [showProgram] to say which program it is on and
/// [onDelete] to show the red delete icon.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.showProgram = false,
    this.onDelete,
  });

  final ProgramPost post;
  final bool showProgram;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final author = post.authorHandle == null
        ? 'Anonymous'
        : '@${post.authorHandle}';
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
                    if (showProgram)
                      Text(post.programName, style: AppTextStyles.bodyStrong),
                    Text('$author, ${post.term}', style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete post',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(post.text, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          TagChip(post.topic),
        ],
      ),
    );
  }
}
