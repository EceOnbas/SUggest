import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A pill you can tap: filter chips ("All", "Difficulty"…), options in a
/// sheet, or links to another course ("CS 204").
///
/// Selected chips are filled dark; the others are outlined. [compact] is
/// the 40 px version used for course codes.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 40.0 : AppSpacing.minTap;
    return Semantics(
      button: onTap != null,
      selected: selected,
      child: Material(
        color: selected ? AppColors.ink : Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.ink : AppColors.inputBorder,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: height),
            padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.link.copyWith(
                    color: selected ? AppColors.onPrimary : AppColors.ink,
                    fontWeight: compact ? FontWeight.w600 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A row of [AppChip]s that scrolls sideways and lets one be picked.
class ChipFilterRow extends StatelessWidget {
  const ChipFilterRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.padding = EdgeInsets.zero,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  /// Side padding inside the scroll area, so chips can scroll under the
  /// page edge.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (final (i, option) in options.indexed) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            AppChip(
              label: option,
              selected: option == selected,
              onTap: () => onSelected(option),
            ),
          ],
        ],
      ),
    );
  }
}

/// The small label on a review. Not tappable.
///
/// `TagChip` is the pink tag shown on course reviews; `TagChip.topic` is
/// the warm yellow tag for a selected topic.
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key})
      : _background = AppColors.sakura1,
        _foreground = AppColors.sakura5;

  const TagChip.topic(this.label, {super.key})
      : _background = AppColors.tagBackground,
        _foreground = AppColors.tagText;

  final String label;
  final Color _background;
  final Color _foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption
            .copyWith(color: _foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}
