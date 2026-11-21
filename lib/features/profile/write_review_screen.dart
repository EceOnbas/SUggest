import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/field_error.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/state_views.dart';
import '../../core/widgets/text_link.dart';
import '../../models/review_topic.dart';
import '../../services/auth_service.dart';
import 'models/my_course.dart';
import 'models/my_review.dart';
import 'my_profile_store.dart';
import 'widgets/rating_row.dart';

/// "Write Review", or "Edit Review" for a course already reviewed.
///
/// Only courses on My Courses can be reviewed, once each. Picking one
/// fills in its term and instructor from My Courses; they cannot be
/// changed here. All four ratings are needed; tags and written feedback
/// are optional.
///
/// Open it with `Navigator.pushNamed(context, AppRoutes.writeReview)`.
/// As `arguments`, pass the [MyReview] to edit, or a course code such as
/// "CS 310" to start with that course: its review opens if there is one,
/// and a course not on My Courses asks to add it first. It returns the
/// saved [MyReview], or null when closed.
class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key, this.existing, this.courseCode});

  final MyReview? existing;

  /// The course to start with, for example "CS 310".
  final String? courseCode;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  /// The review being edited, or null for a new one. Found when the
  /// screen first opens.
  MyReview? _existing;
  bool get _editing => _existing != null;
  bool _started = false;

  /// The chosen course's code.
  String? _code;

  final _feedback = TextEditingController();
  final Map<ReviewTopic, int> _scores = {};
  final Set<ReviewTopic> _tags = {};

  /// Errors only show once the user has tried to submit.
  bool _triedToSubmit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final email = AuthScope.of(context).email ?? '';
    final code = widget.courseCode;
    final existing =
        widget.existing ??
        (code == null ? null : MyProfileStore.instance.reviewFor(email, code));
    _existing = existing;
    _code = existing?.courseCode ?? code;
    if (existing != null) {
      _scores.addAll(existing.ratings);
      _tags.addAll(existing.tags);
      _feedback.text = existing.feedback;
    }
  }

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _openMyCourses([String? code]) async {
    await Navigator.pushNamed(context, AppRoutes.myCourses, arguments: code);
    // My Courses saves to the profile, which rebuilds this screen.
  }

  String? _ratingsProblem() =>
      RatingScale.order.any((t) => !_scores.containsKey(t))
      ? 'Please rate all four course criteria before submitting.'
      : null;

  void _submit(MyCourse? course) {
    final problem = course == null && !_editing
        ? 'Choose one of your courses to review.'
        : _ratingsProblem();
    if (problem != null) {
      setState(() => _triedToSubmit = true);
      AppToast.show(context, problem, isError: true);
      return;
    }
    final tags = [
      for (final topic in ReviewTopic.values)
        if (_tags.contains(topic)) topic,
    ];
    final ratings = Map<ReviewTopic, int>.unmodifiable(_scores);
    final now = DateTime.now();
    final existing = _existing;
    final review = existing == null
        ? MyReview(
            id: 'my-${now.microsecondsSinceEpoch}',
            courseCode: course!.code,
            courseTitle: course.title,
            term: course.term,
            instructor: course.instructor,
            ratings: ratings,
            tags: tags,
            feedback: _feedback.text.trim(),
            posted: now,
          )
        : existing.edit(
            term: course?.term ?? existing.term,
            instructor: course?.instructor ?? existing.instructor,
            ratings: ratings,
            tags: tags,
            feedback: _feedback.text.trim(),
            edited: now,
          );
    final email = AuthScope.of(context).email;
    if (email != null) MyProfileStore.instance.saveReview(email, review);
    Navigator.pop(context, review);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final email = auth.email ?? '';
    final courses = MyCourse.allOf(auth.profile);
    final reviewed = {
      for (final r in MyProfileStore.instance.reviewsOf(email)) r.courseCode,
    };
    final open = [
      for (final c in courses)
        if (!reviewed.contains(c.code)) c,
    ];
    final code = widget.courseCode;

    final Widget body;
    if (_editing) {
      body = _buildForm(courses, open, auth.handle);
    } else if (code != null && !courses.any((c) => c.code == code)) {
      body = EmptyState(
        icon: Icons.playlist_add_rounded,
        title: 'Add $code to My Courses first',
        message:
            'You can only review courses you took. Add $code with the '
            'term and instructor, then write your review.',
        actionLabel: 'Add $code to My Courses',
        onAction: () => _openMyCourses(code),
      );
    } else if (courses.isEmpty) {
      body = EmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Add a course first',
        message:
            'You can only review courses on your My Courses list. Add the '
            'courses you finished, then come back.',
        actionLabel: 'Go to My Courses',
        onAction: _openMyCourses,
      );
    } else if (open.isEmpty) {
      body = EmptyState(
        icon: Icons.task_alt_rounded,
        title: 'All your courses are reviewed',
        message:
            'Each course can be reviewed once. Add another course in My '
            'Courses to write a new review, or edit a review on My '
            'Profile.',
        actionLabel: 'Go to My Courses',
        onAction: _openMyCourses,
      );
    } else {
      body = _buildForm(courses, open, auth.handle);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(title: _editing ? 'Edit Review' : 'Write Review'),
              const SizedBox(height: 20),
              body,
            ],
          ),
        ),
      ),
    );
  }

  /// The review form. [open] are the courses not reviewed yet.
  Widget _buildForm(
    List<MyCourse> courses,
    List<MyCourse> open,
    String? handle,
  ) {
    final existing = _existing;
    MyCourse? course;
    for (final c in courses) {
      if (c.code == _code) course = c;
    }
    // A new review can only pick a course that is not reviewed yet.
    if (existing == null && course != null && !open.contains(course)) {
      course = null;
    }
    final choices = existing == null ? open : [?course];
    final term = course?.term ?? existing?.term ?? '';
    final instructor = course?.instructor ?? existing?.instructor ?? '';
    final labels = {for (final c in choices) c.code: c.label};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          outlined: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (existing != null && course == null)
                _LockedField(
                  label: 'Course',
                  value: existing.courseLabel,
                  helperText:
                      'Course selection is locked while editing. To review '
                      'a different course, start a new review.',
                )
              else
                AppDropdownField<String>(
                  label: 'Course',
                  items: [for (final c in choices) c.code],
                  itemLabel: (code) => labels[code] ?? code,
                  value: course?.code,
                  enabled: existing == null,
                  hintText: 'Select one of your courses',
                  helperText: existing != null
                      ? 'Course selection is locked while editing. To '
                            'review a different course, start a new review.'
                      : 'Only your courses that are not reviewed yet are '
                            'listed.',
                  errorText: _triedToSubmit && course == null
                      ? 'Choose one of your courses to review.'
                      : null,
                  onChanged: (code) => setState(() => _code = code),
                ),
              if (existing == null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextLink(
                    label: 'Course not listed? Add it in My Courses',
                    onPressed: _openMyCourses,
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              _LockedField(
                label: 'Term Taken',
                value: term,
                hintText: 'Select a course first',
                helperText: 'From My Courses.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _LockedField(
                label: 'Instructor',
                value: instructor,
                hintText: 'Select a course first',
                helperText: 'From My Courses.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          child: Text('Course Ratings', style: AppTextStyles.heading),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Choose one option for each category. Nothing is preselected.',
          style: AppTextStyles.helper,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          outlined: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, topic) in RatingScale.order.indexed) ...[
                if (i > 0) const SizedBox(height: 18),
                RatingRow(
                  topic: topic,
                  score: _scores[topic],
                  showError: _triedToSubmit,
                  onChanged: (score) => setState(() => _scores[topic] = score),
                ),
              ],
            ],
          ),
        ),
        if (_triedToSubmit ? _ratingsProblem() : null case final message?) ...[
          const SizedBox(height: AppSpacing.sm),
          FieldError(message),
        ],
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          child: Text('Topic Tags', style: AppTextStyles.heading),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'What does your review talk about? The course page filters '
          'reviews by these topics.',
          style: AppTextStyles.helper,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final topic in ReviewTopic.values)
              AppChip(
                label: topic.label,
                selected: _tags.contains(topic),
                onTap: () => setState(() {
                  if (!_tags.remove(topic)) _tags.add(topic);
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const FieldLabel('Written Feedback', optional: true),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: 'Written Feedback',
          child: TextField(
            controller: _feedback,
            minLines: 4,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.input,
            cursorColor: AppColors.primary,
            decoration: const InputDecoration(
              hintText:
                  'Share details about assignments, exams, and overall '
                  'course experience...',
              hintMaxLines: 3,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (handle != null) ...[
          Text(
            'Posted as @$handle. Your name stays private.',
            style: AppTextStyles.helper,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        PrimaryButton(
          label: _editing ? 'Save Changes' : 'Submit',
          onPressed: () => _submit(course),
        ),
        if (_editing)
          Center(
            child: TextLink(
              label: 'Cancel',
              muted: true,
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
      ],
    );
  }
}

/// A field that shows a value which cannot be changed here.
class _LockedField extends StatefulWidget {
  const _LockedField({
    required this.label,
    required this.value,
    this.hintText,
    this.helperText,
  });

  final String label;
  final String value;
  final String? hintText;
  final String? helperText;

  @override
  State<_LockedField> createState() => _LockedFieldState();
}

class _LockedFieldState extends State<_LockedField> {
  late final _text = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(_LockedField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _text.text = widget.value;
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppTextField(
    label: widget.label,
    controller: _text,
    enabled: false,
    hintText: widget.hintText,
    helperText: widget.helperText,
  );
}

/// The screen title with the back arrow on the left, like My Courses
/// and Edit Academic Info.
class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppBackButton(),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: AppTextStyles.stepTitle),
          ),
        ),
      ],
    );
  }
}
