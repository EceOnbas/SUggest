import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/state_views.dart';
import '../../data/mock_data.dart';
import '../../models/course.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import 'models/my_course.dart';
import 'models/my_review.dart';
import 'my_profile_store.dart';
import 'profile_mock_data.dart';
import 'review_actions.dart';
import 'utils/search_text.dart';
import 'widgets/profile_widgets.dart';
import 'widgets/suggestion_field.dart';

/// "My Courses": the courses the student finished, grouped by the term
/// they took them, newest first.
///
/// - Courses can only be added from the team's course list
///   ([MockData.courses]), for a finished term, once each.
/// - "Reviewed" opens the course's review; "Write review" opens the form
///   with the course filled in.
/// - A reviewed course cannot be removed until its review is deleted.
///
/// Open it with `Navigator.pushNamed(context, AppRoutes.myCourses)`.
/// Pass a course code as `arguments` to start with that course picked;
/// then the screen closes after adding it and returns true.
class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key, this.preselectedCode});

  /// The course to start the add form with, for example "CS 310".
  final String? preselectedCode;

  static const duplicateMessage = 'This course is already in My Courses.';

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final email = auth.email ?? '';
    return ListenableBuilder(
      listenable: MyProfileStore.instance,
      builder: (context, _) {
        final store = MyProfileStore.instance;
        final courses = MyCourse.allOf(auth.profile);
        final reviewed = {
          for (final r in store.reviewsOf(email)) r.courseCode: r,
        };
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const AppBackButton(),
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            'My Courses',
                            style: AppTextStyles.heading.copyWith(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'The courses you finished at SU. You can review a '
                    'course once it is here.',
                    style: AppTextStyles.helper,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _AddCourseCard(
                    profile: auth.profile,
                    graduated: store.dataFor(email).graduated,
                    preselectedCode: preselectedCode,
                    onAdd: (taken) => _add(context, taken),
                  ),
                  const SizedBox(height: 28),
                  Semantics(
                    header: true,
                    child: Text('Courses Taken', style: AppTextStyles.heading),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    coursesSummary(courses, reviewed.keys.toSet()),
                    style: AppTextStyles.helper,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (courses.isEmpty)
                    const EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'No courses yet',
                      message:
                          'Add the courses you finished above. Then you '
                          'can review them.',
                    ),
                  ..._buildTerms(context, courses, reviewed),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// One heading per term, newest first, with that term's courses.
  List<Widget> _buildTerms(
    BuildContext context,
    List<MyCourse> courses,
    Map<String, MyReview> reviewed,
  ) {
    final terms = <String>[];
    for (final c in courses) {
      if (!terms.contains(c.term)) terms.add(c.term);
    }
    return [
      for (final term in terms) ...[
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 10),
          child: Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                text: term,
                style: AppTextStyles.bodyStrong,
                children: [
                  TextSpan(
                    text:
                        '  ·  ${_count(courses.where((c) => c.term == term).length)}',
                    style: AppTextStyles.helper,
                  ),
                ],
              ),
            ),
          ),
        ),
        for (final course in courses.where((c) => c.term == term))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _CourseTile(
              key: ValueKey(course.code),
              course: course,
              review: reviewed[course.code],
              onRemove: () => _remove(context, course, reviewed[course.code]),
            ),
          ),
      ],
    ];
  }

  static String _count(int n) => '$n course${n == 1 ? '' : 's'}';

  /// "6 courses · 4 not reviewed yet".
  static String coursesSummary(List<MyCourse> courses, Set<String> reviewed) {
    if (courses.isEmpty) return 'No courses added yet.';
    final open = courses.where((c) => !reviewed.contains(c.code)).length;
    final status = open == 0 ? 'all reviewed' : '$open not reviewed yet';
    return '${_count(courses.length)} · $status';
  }

  /// Saves [taken]. Returns an error message, or null when added.
  Future<String?> _add(BuildContext context, TakenCourse taken) async {
    final auth = AuthScope.of(context);
    final profile = auth.profile ?? const UserProfile();
    final code = MyCourse(taken).code;
    if (MyCourse.allOf(profile).any((c) => c.code == code)) {
      return duplicateMessage;
    }
    await auth.saveProfile(
      profile.copyWith(coursesTaken: [...profile.coursesTaken, taken]),
    );
    if (!context.mounted) return null;
    if (preselectedCode != null) {
      Navigator.pop(context, true);
    } else {
      AppToast.show(context, '$code added to My Courses.');
    }
    return null;
  }

  Future<void> _remove(
    BuildContext context,
    MyCourse course,
    MyReview? review,
  ) async {
    if (review != null) {
      final open = await showConfirmDialog(
        context: context,
        title: 'Delete the review first',
        message:
            'You reviewed ${course.code}. A course with a review cannot be '
            'removed. Delete the review first, then remove the course.',
        confirmLabel: 'Open review',
        cancelLabel: 'Close',
      );
      if (open && context.mounted) await ReviewActions.open(context, review);
      return;
    }
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Remove ${course.code}?',
      message: 'It will no longer be in My Courses.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final auth = AuthScope.of(context);
    final profile = auth.profile ?? const UserProfile();
    await auth.saveProfile(
      profile.copyWith(
        coursesTaken: [
          for (final t in profile.coursesTaken)
            if (t != course.taken) t,
        ],
      ),
    );
    if (context.mounted) {
      AppToast.show(context, '${course.code} removed from My Courses.');
    }
  }
}

/// The form that adds a course: course from the team's list, a finished
/// term and the instructor.
class _AddCourseCard extends StatefulWidget {
  const _AddCourseCard({
    required this.profile,
    required this.graduated,
    required this.onAdd,
    this.preselectedCode,
  });

  final UserProfile? profile;
  final bool graduated;
  final String? preselectedCode;

  /// Saves the course; returns an error message or null.
  final Future<String?> Function(TakenCourse taken) onAdd;

  @override
  State<_AddCourseCard> createState() => _AddCourseCardState();
}

class _AddCourseCardState extends State<_AddCourseCard> {
  late final _courseText = TextEditingController(
    text: switch (MockData.courseByCode(widget.preselectedCode ?? '')) {
      final course? => MyCourse.courseLabel(course),
      null => '',
    },
  );
  String? _term;
  String? _instructor;
  bool _triedToAdd = false;
  bool _saving = false;

  @override
  void dispose() {
    _courseText.dispose();
    super.dispose();
  }

  Set<String> get _takenCodes => {
    for (final c in MyCourse.allOf(widget.profile)) c.code,
  };

  /// The course whose exact label was typed or picked, or null.
  Course? get _course {
    final text = _courseText.text.trim();
    for (final c in MockData.courses) {
      if (MyCourse.courseLabel(c) == text) return c;
    }
    return null;
  }

  List<String> get _terms =>
      finishedTermsFor(widget.profile, graduated: widget.graduated);

  Iterable<String> _suggestions(String text) {
    final taken = _takenCodes;
    return [
      for (final c in MockData.courses)
        if (!taken.contains(c.code) &&
            matchesSearch(
              [
                c.code,
                c.title,
                ...?ProfileMockData.courseAliases[c.code],
              ].join(' '),
              text,
            ))
          MyCourse.courseLabel(c),
    ];
  }

  String? get _courseProblem {
    final course = _course;
    if (course != null && _takenCodes.contains(course.code)) {
      return MyCoursesScreen.duplicateMessage;
    }
    if (!_triedToAdd) return null;
    return course == null
        ? 'Choose a course from the course list. Only listed courses can '
              'be added.'
        : null;
  }

  String? get _termProblem => _triedToAdd && !_terms.contains(_term)
      ? 'Pick the term you took it.'
      : null;

  String? get _instructorProblem =>
      _triedToAdd && _instructor == null ? 'Pick the instructor.' : null;

  Future<void> _add() async {
    setState(() => _triedToAdd = true);
    final course = _course;
    if (course == null ||
        _courseProblem != null ||
        _termProblem != null ||
        _instructorProblem != null) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final error = await widget.onAdd(
      TakenCourse(
        courseName: course.fullName,
        term: _term!,
        instructor: _instructor!,
      ),
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (error == null) {
        _courseText.clear();
        _term = null;
        _instructor = null;
        _triedToAdd = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final terms = _terms;
    return AppCard(
      outlined: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Add a course', style: AppTextStyles.bodyStrong),
          ),
          const SizedBox(height: AppSpacing.md),
          SuggestionField(
            label: 'Course',
            controller: _courseText,
            hintText: 'Search by course code or title',
            helperText: 'Pick a course from the list.',
            errorText: _courseProblem,
            suggestionsFor: _suggestions,
            onChanged: (_) => setState(() {}),
            onClear: () => setState(_courseText.clear),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDropdownField<String>(
            label: 'Term Taken',
            items: terms,
            value: terms.contains(_term) ? _term : null,
            enabled: terms.isNotEmpty,
            hintText: terms.isEmpty ? 'No finished terms yet' : 'Select a term',
            helperText: terms.isEmpty
                ? 'Courses can be added once their term is over.'
                : 'Only finished terms are listed.',
            errorText: terms.isEmpty ? null : _termProblem,
            onChanged: (term) => setState(() => _term = term),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppDropdownField<String>(
            label: 'Instructor',
            items: MockData.instructors,
            value: _instructor,
            hintText: 'Select an instructor',
            errorText: _instructorProblem,
            onChanged: (name) => setState(() => _instructor = name),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Add Course',
            loading: _saving,
            onPressed: terms.isEmpty ? null : _add,
          ),
        ],
      ),
    );
  }
}

/// One course: its name, instructor, review status and Remove.
class _CourseTile extends StatelessWidget {
  const _CourseTile({
    super.key,
    required this.course,
    required this.review,
    required this.onRemove,
  });

  final MyCourse course;

  /// The student's review of this course, or null.
  final MyReview? review;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final review = this.review;
    return AppCard(
      outlined: true,
      padding: const EdgeInsets.fromLTRB(18, 12, 6, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.label, style: AppTextStyles.bodyStrong),
                      Text(course.instructor, style: AppTextStyles.helper),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove ${course.code}',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (review != null)
            Semantics(
              label: 'Reviewed. Open your review of ${course.code}',
              excludeSemantics: true,
              button: true,
              child: OutlinedButton.icon(
                style: compactPillStyle(color: AppColors.primary),
                onPressed: () => ReviewActions.open(context, review),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Reviewed'),
              ),
            )
          else
            Semantics(
              label: 'Write a review of ${course.code}',
              excludeSemantics: true,
              button: true,
              child: OutlinedButton.icon(
                style: compactPillStyle(),
                onPressed: () =>
                    ReviewActions.write(context, courseCode: course.code),
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text('Write review'),
              ),
            ),
        ],
      ),
    );
  }
}
