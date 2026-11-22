import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/segmented_choice.dart';
import '../../core/widgets/text_link.dart';
import '../../data/mock_data.dart';
import '../../models/user_profile.dart';
import 'models/my_course.dart';
import 'models/profile_details.dart';
import 'profile_mock_data.dart';
import 'utils/search_text.dart';
import 'widgets/suggestion_field.dart';

/// What [EditAcademicScreen] opens with.
class EditAcademicArgs {
  const EditAcademicArgs(this.details, {this.focus});

  final AcademicDetails details;

  /// The optional field to jump to, for example after "+ Add Minor".
  final AcademicExtra? focus;
}

/// "Edit Academic Info": graduation status, major, class year, current
/// and start term (or graduation year), and the four optional fields.
/// Programs and universities must be picked from the fixed lists; Erasmus
/// and Exchange each need a term too.
///
/// Open it with `Navigator.pushNamed(context, AppRoutes.editAcademic,
/// arguments: EditAcademicArgs(details))`; it returns the saved
/// [AcademicDetails], or null when the user goes back.
class EditAcademicScreen extends StatefulWidget {
  const EditAcademicScreen({super.key, required this.args});

  final EditAcademicArgs args;

  @override
  State<EditAcademicScreen> createState() => _EditAcademicScreenState();
}

class _EditAcademicScreenState extends State<EditAcademicScreen> {
  late final AcademicDetails _start = widget.args.details;

  late bool _graduated = _start.graduated;
  late String? _classYear = _start.classYear;
  late String? _currentTerm = _start.currentTerm;
  late String? _startTerm = _start.startTerm;
  late final Map<AcademicExtra, String?> _exchangeTerms = {
    for (final field in _exchangeFields)
      field: _start.exchangeTerm(field).isEmpty
          ? null
          : _start.exchangeTerm(field),
  };
  late String _graduationYear =
      ProfileMockData.graduationYears.contains(_start.graduationYear)
      ? _start.graduationYear
      : ProfileMockData.graduationYears.first;

  late final _major = TextEditingController(text: _start.major);
  late final _extras = {
    for (final field in AcademicExtra.values)
      field: TextEditingController(text: _start.extra(field)),
  };
  final _focusNodes = {
    for (final field in AcademicExtra.values) field: FocusNode(),
  };
  final _fieldKeys = {
    for (final field in AcademicExtra.values) field: GlobalKey(),
  };

  bool _triedToSave = false;

  static const _exchangeFields = [
    AcademicExtra.erasmus,
    AcademicExtra.exchange,
  ];

  /// The terms an exchange can be in: finished or current ones, as in
  /// profile setup. A saved term that is not listed is kept.
  /// Finished terms from the start term on, the same rule as My Courses.
  /// They follow the term fields above, so changing the start term
  /// updates the list.
  List<String> _exchangeTermsFor(AcademicExtra field) => finishedTermsFor(
    UserProfile(currentTerm: _currentTerm, startTerm: _startTerm),
    graduated: _graduated,
  );

  @override
  void initState() {
    super.initState();
    final focus = widget.args.focus;
    if (focus != null) {
      // After the first frame, scroll to the field and put the cursor in.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _fieldKeys[focus]!.currentContext;
        if (!mounted || target == null) return;
        Scrollable.ensureVisible(
          target,
          alignment: 0.3,
          duration: const Duration(milliseconds: 250),
        );
        _focusNodes[focus]!.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _major.dispose();
    for (final c in _extras.values) {
      c.dispose();
    }
    for (final n in _focusNodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  // Validation. Each returns the message to show, or null when fine.

  String? _majorProblem() {
    final major = _major.text.trim();
    if (major.isEmpty) return 'A primary program is required.';
    if (!MockData.majors.contains(major)) {
      return 'Choose a program from the list.';
    }
    return null;
  }

  String? _extraProblem(AcademicExtra field) {
    final value = _extras[field]!.text.trim();
    if (value.isEmpty) return null;
    if (!field.options.contains(value)) {
      return field.program == null
          ? 'Choose a program from the list, or clear the field.'
          : 'Choose a university from the list, or clear the field.';
    }
    if (field == AcademicExtra.doubleMajor && value == _major.text.trim()) {
      return 'Your double major must differ from your major.';
    }
    return null;
  }

  String? _exchangeTermProblem(AcademicExtra field) =>
      _extras[field]!.text.trim().isNotEmpty &&
          !_exchangeTermsFor(field).contains(_exchangeTerms[field])
      ? 'Pick the term of your ${field.program!.label} experience.'
      : null;

  String? _startTermProblem() {
    final start = _startTerm;
    final current = _currentTerm;
    if (_graduated || start == null || current == null) return null;
    return compareTerms(start, current) > 0
        ? 'Your start term cannot be after your current term.'
        : null;
  }

  bool get _hasProblem =>
      _majorProblem() != null ||
      _startTermProblem() != null ||
      AcademicExtra.values.any((f) => _extraProblem(f) != null) ||
      _exchangeFields.any((f) => _exchangeTermProblem(f) != null);

  /// [problem], once the user has tried to save.
  String? _shown(String? problem) => _triedToSave ? problem : null;

  void _save() {
    if (_hasProblem) {
      setState(() => _triedToSave = true);
      AppToast.show(
        context,
        'Please fix the highlighted fields.',
        isError: true,
      );
      return;
    }
    final details = AcademicDetails(
      major: _major.text.trim(),
      graduated: _graduated,
      classYear: _classYear,
      currentTerm: _currentTerm,
      startTerm: _startTerm,
      graduationYear: _graduationYear,
      extras: {
        for (final MapEntry(key: field, value: c) in _extras.entries)
          if (c.text.trim().isNotEmpty) field: c.text.trim(),
      },
      exchangeTerms: {
        for (final field in _exchangeFields)
          if (_extras[field]!.text.trim().isNotEmpty)
            field: _exchangeTerms[field]!,
      },
    );
    Navigator.pop(context, details);
  }

  /// Suggestions from [options] that match what is typed.
  Iterable<String> Function(String) _suggest(List<String> options) =>
      (text) => options.where((o) => matchesSearch(o, text));

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 18);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  const AppBackButton(tooltip: 'Back to profile'),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Edit Academic Info',
                        style: AppTextStyles.heading.copyWith(fontSize: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FieldLabel('Graduation Status'),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedChoice<bool>(
                      options: const [false, true],
                      value: _graduated,
                      labelOf: (graduated) =>
                          graduated ? 'Graduated' : 'Studying',
                      semanticLabel: 'Graduation status',
                      onChanged: (value) => setState(() => _graduated = value),
                    ),
                    gap,
                    SuggestionField(
                      label: 'Primary Program (Major)',
                      controller: _major,
                      hintText: 'Search your degree program',
                      errorText: _shown(_majorProblem()),
                      suggestionsFor: _suggest(MockData.majors),
                      onChanged: (_) => setState(() {}),
                    ),
                    gap,
                    if (_graduated) _buildGraduationYear() else _buildYearRow(),
                    gap,
                    _buildStartTerm(),
                    for (final field in AcademicExtra.values) ...[
                      gap,
                      KeyedSubtree(
                        key: _fieldKeys[field],
                        child: SuggestionField(
                          label: field.label,
                          optional: true,
                          controller: _extras[field]!,
                          focusNode: _focusNodes[field],
                          hintText: field.program == null
                              ? 'Search ${field.label.toLowerCase()} programs'
                              : 'Search ${field.program!.label} partner '
                                    'universities',
                          errorText: _shown(_extraProblem(field)),
                          suggestionsFor: _suggest(field.options),
                          onChanged: (_) => setState(() {}),
                          onClear: () => setState(() {
                            _extras[field]!.clear();
                            if (field.program != null) {
                              _exchangeTerms[field] = null;
                            }
                          }),
                        ),
                      ),
                      if (field.program != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildExchangeTerm(field),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            _BottomBar(onSave: _save),
          ],
        ),
      ),
    );
  }

  /// The term of an Erasmus or Exchange experience. It can be picked
  /// once the university is filled in.
  Widget _buildExchangeTerm(AcademicExtra field) {
    final hasUniversity = _extras[field]!.text.trim().isNotEmpty;
    final terms = _exchangeTermsFor(field);
    return AppDropdownField<String>(
      label: '${field.program!.label} Term',
      optional: true,
      items: terms,
      value: hasUniversity && terms.contains(_exchangeTerms[field])
          ? _exchangeTerms[field]
          : null,
      enabled: hasUniversity,
      hintText: !hasUniversity
          ? 'Choose a university first'
          : terms.isEmpty
          ? 'No finished terms yet'
          : 'Choose a term',
      errorText: _shown(_exchangeTermProblem(field)),
      onChanged: (term) => setState(() => _exchangeTerms[field] = term),
    );
  }

  Widget _buildStartTerm() {
    final saved = _start.startTerm;
    final terms = [
      ...MockData.startTerms,
      if (saved != null && !MockData.startTerms.contains(saved)) saved,
    ];
    return AppDropdownField<String>(
      label: 'Start Term',
      hintText: 'Choose',
      items: terms,
      value: _startTerm,
      helperText: 'The term you started at SU.',
      errorText: _shown(_startTermProblem()),
      onChanged: (value) => setState(() => _startTerm = value),
    );
  }

  /// Class year and current term, side by side.
  Widget _buildYearRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppDropdownField<String>(
            label: 'Class Year',
            hintText: 'Choose',
            items: MockData.classYears,
            itemLabel: AcademicDetails.yearLabel,
            value: _classYear,
            onChanged: (value) => setState(() => _classYear = value),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppDropdownField<String>(
            label: 'Current Term',
            hintText: 'Choose',
            items: [
              ...MockData.currentTerms,
              if (_start.currentTerm case final saved?
                  when !MockData.currentTerms.contains(saved))
                saved,
            ],
            value: _currentTerm,
            onChanged: (value) => setState(() => _currentTerm = value),
          ),
        ),
      ],
    );
  }

  Widget _buildGraduationYear() {
    return AppDropdownField<String>(
      label: 'Graduation Year',
      items: ProfileMockData.graduationYears,
      itemLabel: (year) => 'Class of $year',
      value: _graduationYear,
      onChanged: (value) => setState(() => _graduationYear = value!),
    );
  }
}

/// Save Changes and "Back to Profile", fixed at the bottom of the screen.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border(top: BorderSide(color: AppColors.borderStrong)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(label: 'Save Changes', onPressed: onSave),
            Center(
              child: TextLink(
                label: '← Back to Profile',
                muted: true,
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
