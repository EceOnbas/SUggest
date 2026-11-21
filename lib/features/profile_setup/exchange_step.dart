import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/field_error.dart';
import '../../core/widgets/segmented_choice.dart';
import '../../data/mock_data.dart';
import '../../models/user_profile.dart';
import '../profile/models/my_course.dart';
import 'widgets/setup_step_scaffold.dart';

/// Step 4: has the student been an outgoing exchange student?
///
/// "Yes" asks which programs: Erasmus, Exchange or both. Each one picked
/// opens its own host university and term. There are no ratings here;
/// the answer only feeds the anonymous exchange numbers.
class ExchangeStep extends StatefulWidget {
  const ExchangeStep({
    super.key,
    required this.profile,
    required this.onBack,
    required this.onContinue,
    required this.onSkip,
  });

  static const title = 'Have you been an outgoing exchange student?';
  static const noProgramMessage = 'Choose Erasmus, Exchange or both.';

  /// Shown under the term when the student has no finished term yet.
  static const noFinishedTermsMessage =
      'Only finished terms can be picked. Choose "Not yet" for now.';

  final UserProfile profile;
  final VoidCallback onBack;
  final ValueChanged<UserProfile> onContinue;
  final VoidCallback onSkip;

  @override
  State<ExchangeStep> createState() => _ExchangeStepState();
}

class _ExchangeStepState extends State<ExchangeStep> {
  static const _yes = 'Yes';
  static const _notYet = 'Not yet';

  final _formKey = GlobalKey<FormState>();
  late bool _went = widget.profile.exchanges.isNotEmpty;

  /// The programs picked, in the order of [ExchangeProgram.values].
  late final Set<ExchangeProgram> _programs = {
    for (final e in widget.profile.exchanges) e.program,
  };

  // Kept while a program is unticked, so ticking it again restores them.
  late final Map<ExchangeProgram, String?> _hosts = {
    for (final e in widget.profile.exchanges) e.program: e.hostUniversity,
  };

  /// Finished terms from the start term on, the same rule as My Courses.
  late final List<String> _termOptions = finishedTermsFor(widget.profile);

  // A saved term outside the list (the start term changed) is dropped.
  late final Map<ExchangeProgram, String?> _terms = {
    for (final e in widget.profile.exchanges)
      e.program: _termOptions.contains(e.term) ? e.term : null,
  };
  bool _triedToFinish = false;

  void _finish() {
    if (!_went) {
      widget.onContinue(widget.profile.withExchanges(const []));
      return;
    }
    final formValid = _formKey.currentState!.validate();
    if (!formValid || _programs.isEmpty) {
      setState(() => _triedToFinish = true);
      return;
    }
    widget.onContinue(
      widget.profile.withExchanges([
        for (final program in ExchangeProgram.values)
          if (_programs.contains(program))
            ExchangeInfo(
              hostUniversity: _hosts[program]!,
              term: _terms[program]!,
              program: program,
            ),
      ]),
    );
  }

  void _toggle(ExchangeProgram program) {
    setState(() {
      if (!_programs.remove(program)) _programs.add(program);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SetupStepScaffold(
      step: 4,
      title: ExchangeStep.title,
      subtitle: 'Helps others see where SU students usually go.',
      primaryLabel: 'Finish',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      onPrimary: _finish,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedChoice<String>(
            semanticLabel: 'Outgoing exchange',
            options: const [_yes, _notYet],
            value: _went ? _yes : _notYet,
            onChanged: (value) => setState(() => _went = value == _yes),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_went)
            _buildForm()
          else
            Text(
              'No problem. If you go later, add it from your profile and '
              'the Exchange page will show your school.',
              style: AppTextStyles.body.copyWith(color: AppColors.muted),
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: _triedToFinish
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FieldLabel('Program'),
          const SizedBox(height: AppSpacing.xs),
          Text('Pick one or both.', style: AppTextStyles.helper),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final program in ExchangeProgram.values)
                Semantics(
                  selected: _programs.contains(program),
                  child: AppChip(
                    label: program.label,
                    selected: _programs.contains(program),
                    onTap: () => _toggle(program),
                  ),
                ),
            ],
          ),
          if (_triedToFinish && _programs.isEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const FieldError(ExchangeStep.noProgramMessage),
          ],
          for (final program in ExchangeProgram.values)
            if (_programs.contains(program)) _buildProgram(program),
        ],
      ),
    );
  }

  /// Host university and term for one program.
  Widget _buildProgram(ExchangeProgram program) {
    final universities = program == ExchangeProgram.erasmus
        ? MockData.erasmusUniversities
        : MockData.hostUniversities;
    return Padding(
      key: ValueKey(program),
      padding: const EdgeInsets.only(top: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(program.label, style: AppTextStyles.bodyStrong),
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdownFormField<String>(
            label: '${program.label} host university',
            hintText: 'Choose a university',
            items: universities,
            initialValue: _hosts[program],
            validator: (value) =>
                value == null ? 'Choose your host university.' : null,
            onChanged: (value) => _hosts[program] = value,
          ),
          const SizedBox(height: 22),
          AppDropdownFormField<String>(
            label: '${program.label} term',
            hintText: _termOptions.isEmpty
                ? 'No finished terms yet'
                : 'Choose a term',
            items: _termOptions,
            initialValue: _terms[program],
            validator: (value) => value != null
                ? null
                : _termOptions.isEmpty
                ? ExchangeStep.noFinishedTermsMessage
                : 'Pick a term.',
            onChanged: (value) => _terms[program] = value,
          ),
        ],
      ),
    );
  }
}
