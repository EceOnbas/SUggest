import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/state_views.dart';
import '../../models/course.dart';
import 'catalog_search.dart';
import 'widgets/course_result_row.dart';

/// Search inside the Courses tab: an input, department chips, live results
/// and a list of recent searches that can be removed one by one.
class SearchView extends StatefulWidget {
  const SearchView({
    super.key,
    required this.courses,
    required this.recent,
    required this.onRecentChanged,
    required this.onClose,
    required this.onOpenCourse,
  });

  final List<Course> courses;
  final List<String> recent;
  final ValueChanged<List<String>> onRecentChanged;
  final VoidCallback onClose;
  final ValueChanged<Course> onOpenCourse;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String _query = '';
  String _department = allDepartments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _setQuery(String value) => setState(() => _query = value);

  void _remember(String query) =>
      widget.onRecentChanged(addRecentSearch(widget.recent, query));

  void _open(Course course) {
    _remember(_query.isEmpty ? course.code : _query);
    widget.onOpenCourse(course);
  }

  void _removeRecent(String query) =>
      widget.onRecentChanged([
        for (final r in widget.recent)
          if (r != query) r,
      ]);

  @override
  Widget build(BuildContext context) {
    final results = searchCourses(
      widget.courses,
      _query,
      department: _department,
    );
    final browsing = _query.trim().isEmpty && _department == allDepartments;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: AppSpacing.pagePadding,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Close search',
              onPressed: widget.onClose,
              icon: const Icon(Icons.close_rounded, color: AppColors.ink),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: Text('Search', style: AppTextStyles.heading)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'Course code or title',
          controller: _controller,
          focusNode: _focus,
          hintText: 'For example CS 310 or data',
          textInputAction: TextInputAction.search,
          autocorrect: false,
          onChanged: _setQuery,
          onSubmitted: _remember,
          suffix: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear',
                  onPressed: () {
                    _controller.clear();
                    _setQuery('');
                  },
                  icon: const Icon(Icons.cancel_rounded, color: AppColors.muted),
                ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ChipFilterRow(
          options: departmentsOf(widget.courses),
          selected: _department,
          onSelected: (d) => setState(() => _department = d),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (browsing && widget.recent.isNotEmpty) ...[
          Text('Recent searches', style: AppTextStyles.heading),
          const SizedBox(height: AppSpacing.md),
          for (final (i, q) in widget.recent.indexed) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _RecentCard(
              query: q,
              onTap: () {
                _controller.text = q;
                _controller.selection = TextSelection.collapsed(offset: q.length);
                _setQuery(q);
              },
              onRemove: () => _removeRecent(q),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
        Text(
          browsing ? 'All courses' : '${results.length} result'
              '${results.length == 1 ? '' : 's'}',
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: AppSpacing.md),
        if (results.isEmpty)
          const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No courses found',
            message: 'Check the spelling, or try the course code.',
          )
        else
          for (final (i, course) in results.indexed) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            CourseResultRow(course: course, onTap: () => _open(course)),
          ],
      ],
    );
  }
}

/// One recent search with a remove button (the list's "remove" action).
class _RecentCard extends StatelessWidget {
  const _RecentCard({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.only(left: 18),
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: AppColors.muted),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(query, style: AppTextStyles.body)),
          IconButton(
            tooltip: 'Remove "$query" from recent searches',
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
