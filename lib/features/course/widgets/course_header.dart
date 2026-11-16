import 'package:flutter/material.dart';

import '../../../core/art/sakura_branch.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/course.dart';

/// The top of the course page: the course's sakura branch, the round
/// Back and Save buttons, then the code, title and credits.
class CourseHeader extends StatelessWidget {
  const CourseHeader({
    super.key,
    required this.course,
    required this.saved,
    required this.onToggleSaved,
  });

  final Course course;
  final bool saved;
  final VoidCallback onToggleSaved;

  /// Height of the band the branch is drawn in.
  static const _bandHeight = 220.0;

  /// How far the course code climbs into the band.
  static const _overlap = 56.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _bandHeight,
          child: _BranchBand(course: course),
        ),
        // The text decides the height of the header.
        Padding(
          padding: const EdgeInsets.fromLTRB(20, _bandHeight - _overlap, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                // Shrinks instead of overflowing with long codes or large
                // text.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    course.code,
                    style: AppTextStyles.courseTitle.copyWith(
                      fontSize: 52,
                      height: 0.95,
                      letterSpacing: -2.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                course.title,
                style: AppTextStyles.heading.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.44,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(course.creditsLine, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundIconButton(
                tooltip: 'Back',
                icon: Icons.chevron_left_rounded,
                iconSize: 28,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              _RoundIconButton(
                tooltip: saved ? 'Remove from saved' : 'Save course',
                icon: saved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                onPressed: onToggleSaved,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The branch, fading into the page background at the bottom so the
/// course code stays readable on top of it.
class _BranchBand extends StatelessWidget {
  const _BranchBand({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final ratings = course.ratings;
    return Stack(
      children: [
        // Drawn a little taller than the band, like the design, and cut
        // off by the Stack.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 260,
          // A course with no ratings yet gets the default branch.
          child: ratings == null
              ? SakuraBranch(seed: course.code)
              : SakuraBranch(
                  seed: course.code,
                  difficulty: ratings.difficulty,
                  workload: ratings.workload,
                  attendance: ratings.attendance,
                ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 120,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.8],
                colors: [
                  AppColors.background.withValues(alpha: 0),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A 44 px round button that sits on top of the branch.
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.iconSize = 22,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints.tightFor(
          width: AppSpacing.minTap,
          height: AppSpacing.minTap,
        ),
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: iconSize, color: AppColors.ink),
      ),
    );
  }
}
