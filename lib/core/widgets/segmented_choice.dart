import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A row of options in one grey pill where exactly one can be picked,
/// for example class year (1 2 3 4 5+) or Yes / Not yet.
///
/// The picked option is a dark pill; the others are plain text.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labelOf,
    this.semanticLabel,
  });

  final List<T> options;

  /// The picked option, or null when nothing is picked yet.
  final T? value;
  final ValueChanged<T> onChanged;

  /// Text shown for an option; defaults to `option.toString()`.
  final String Function(T option)? labelOf;

  /// What the choice is about, for screen readers ("Class year").
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final label = labelOf ?? (T option) => option.toString();
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          children: [
            for (final option in options)
              Expanded(
                child: _Segment(
                  label: label(option),
                  selected: option == value,
                  onTap: () => onChanged(option),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: Material(
        color: selected ? AppColors.ink : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.input.copyWith(
                color: selected ? AppColors.onPrimary : AppColors.inkSoft,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
