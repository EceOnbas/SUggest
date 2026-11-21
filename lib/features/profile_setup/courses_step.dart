import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../data/mock_data.dart';
import '../../models/user_profile.dart';
import '../profile/models/my_course.dart';
import 'widgets/setup_step_scaffold.dart';

/// Step 3: the courses the student has finished.
///
/// The form needs a course, a term and an instructor; pressing Add
/// course with a gap shows the error under that field. Added courses
/// appear as cards, each with a remove button. Continue asks
/// "Save N courses?" before saving.
class CoursesStep extends StatefulWidget {
  const CoursesStep({
    super.key,
    required this.profile,
    required this.onBack,
    required this.onContinue,
    required this.onSkip,
  });

  final UserProfile profile;
  final VoidCallback onBack;
  final ValueChanged<UserProfile> onContinue;
  final VoidCallback onSkip;

  /// Shown under Term when the student has no finished term yet.
  static const noFinishedTermsMessage =
      'Courses can be added once their term is over.';

  @override
  State<CoursesStep> createState() => _CoursesStepState();
}

class _CoursesStepState extends State<CoursesStep> {
  final _formKey = GlobalKey<FormState>();
  late final List<TakenCourse> _courses = [...widget.profile.coursesTaken];

  /// Finished terms from the start term on, the same rule as My Courses.
  late final List<String> _terms = finishedTermsFor(widget.profile);

  // Filled in by the form fields when the form is saved.
  String? _course;
  String? _term;
  String? _instructor;

  /// After the first failed Add, errors update as the fields are fixed.
  bool _triedToAdd = false;

  bool _alreadyAdded(String? course) =>
      course != null && _courses.any((c) => c.courseName == course);

  void _addCourse() {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      setState(() => _triedToAdd = true);
      return;
    }
    form.save();
    setState(() {
      _courses.add(
        TakenCourse(
          courseName: _course!,
          term: _term!,
          instructor: _instructor!,
        ),
      );
      _triedToAdd = false;
    });
    form.reset();
  }

  void _remove(TakenCourse course) => setState(() => _courses.remove(course));

  Future<void> _continue() async {
    final updated = widget.profile.copyWith(coursesTaken: [..._courses]);
    if (_courses.isEmpty) {
      widget.onContinue(updated);
      return;
    }
    final count = _courses.length;
    final save = await showConfirmDialog(
      context: context,
      title: count == 1 ? 'Save 1 course?' : 'Save $count courses?',
      message:
          'They go to your private profile. You can edit or remove them '
          'any time.',
      cancelLabel: 'Go back',
      confirmLabel: 'Save',
    );
    if (save && mounted) widget.onContinue(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SetupStepScaffold(
      step: 3,
      title: "Courses you've taken",
      subtitle:
          'You can only review courses on this list. Term and instructor '
          'are needed so reviews stay accurate.',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      onPrimary: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(child: _buildForm()),
          const SizedBox(height: AppSpacing.xl),
          Semantics(
            header: true,
            child: Text(
              'Added (${_courses.length})',
              style: AppTextStyles.bodyStrong.copyWith(fontSize: 17),
            ),
          ),
          const SizedBox(height: 10),
          if (_courses.isEmpty)
            const _EmptyNote()
          else
            for (final course in _courses)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CourseCard(
                  course: course,
                  onRemove: () => _remove(course),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: _triedToAdd
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDropdownFormField<String>(
            label: 'Course',
            hintText: 'Choose a course',
            items: [for (final c in MockData.courses) c.fullName],
            validator: (value) {
              if (value == null) return 'Choose a course.';
              if (_alreadyAdded(value)) return 'This course is already added.';
              return null;
            },
            onSaved: (value) => _course = value,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppDropdownFormField<String>(
                  label: 'Term',
                  hintText: _terms.isEmpty ? 'None yet' : 'Choose',
                  items: _terms,
                  validator: (value) => value != null
                      ? null
                      : _terms.isEmpty
                      ? CoursesStep.noFinishedTermsMessage
                      : 'Pick a term.',
                  onSaved: (value) => _term = value,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppDropdownFormField<String>(
                  label: 'Instructor',
                  hintText: 'Choose',
                  items: MockData.instructors,
                  validator: (value) =>
                      value == null ? 'Pick an instructor.' : null,
                  onSaved: (value) => _instructor = value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              textStyle: AppTextStyles.button.copyWith(fontSize: 16),
            ),
            onPressed: _addCourse,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add course'),
          ),
        ],
      ),
    );
  }
}

/// One added course: its name, term and instructor, and a remove button.
class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onRemove});

  final TakenCourse course;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.courseName, style: AppTextStyles.bodyStrong),
                const SizedBox(height: 2),
                Text(
                  '${course.term}, ${course.instructor}',
                  style: AppTextStyles.helper,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove ${course.courseName}',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

/// Shown under "Added (0)" while the list is empty.
class _EmptyNote extends StatelessWidget {
  const _EmptyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.inputBorder, width: 1.5),
      ),
      child: Text(
        "No courses yet. Add the ones you've finished; you can always add "
        'more from your profile.',
        style: AppTextStyles.bodySmall,
      ),
    );
  }
}
