import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/review.dart';
import '../review_filter.dart';

/// "4 reviews", "1 review".
String reviewCountLabel(int count) =>
    count == 1 ? '1 review' : '$count reviews';

/// Opens the "Filter reviews" sheet. Returns the chosen filter, or null
/// when the sheet is closed without pressing the button.
Future<ReviewFilter?> showReviewFilterSheet({
  required BuildContext context,
  required List<Review> reviews,
  required ReviewFilter filter,
}) {
  return showAppBottomSheet<ReviewFilter>(
    context: context,
    title: 'Filter reviews',
    builder: (_) => _ReviewFilterSheet(reviews: reviews, initial: filter),
  );
}

class _ReviewFilterSheet extends StatefulWidget {
  const _ReviewFilterSheet({required this.reviews, required this.initial});

  final List<Review> reviews;
  final ReviewFilter initial;

  @override
  State<_ReviewFilterSheet> createState() => _ReviewFilterSheetState();
}

class _ReviewFilterSheetState extends State<_ReviewFilterSheet> {
  // The choice made in the sheet; the page only gets it on "Show".
  late ReviewFilter _filter = widget.initial;

  /// Every different value in the reviews, in the order it first appears.
  List<String> _valuesOf(String Function(Review) pick) =>
      widget.reviews.map(pick).toSet().toList();

  @override
  Widget build(BuildContext context) {
    final count = _filter.apply(widget.reviews).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OptionGroup(
          label: 'Term',
          anyLabel: 'Any term',
          options: _valuesOf((r) => r.term),
          selected: _filter.term,
          onSelected: (term) =>
              setState(() => _filter = _filter.withTerm(term)),
        ),
        const SizedBox(height: AppSpacing.lg),
        _OptionGroup(
          label: 'Instructor',
          anyLabel: 'Any instructor',
          options: _valuesOf((r) => r.instructor),
          selected: _filter.instructor,
          onSelected: (instructor) =>
              setState(() => _filter = _filter.withInstructor(instructor)),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Show ${reviewCountLabel(count)}',
          onPressed: () => Navigator.pop(context, _filter),
        ),
      ],
    );
  }
}

/// A label and its chips; the first chip ("Any term") clears the choice.
class _OptionGroup extends StatelessWidget {
  const _OptionGroup({
    required this.label,
    required this.anyLabel,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String anyLabel;
  final List<String> options;

  /// Null when "any" is selected.
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppChip(
              label: anyLabel,
              selected: selected == null,
              onTap: () => onSelected(null),
            ),
            for (final option in options)
              AppChip(
                label: option,
                selected: option == selected,
                onTap: () => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }
}
