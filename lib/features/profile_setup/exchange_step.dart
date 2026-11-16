import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/segmented_choice.dart';
import '../../data/mock_data.dart';
import '../../models/user_profile.dart';
import 'widgets/setup_step_scaffold.dart';

/// Step 4: has the student been on exchange?
///
/// "Yes" opens host university, term and program (Erasmus+ or
/// Bilateral). There are no ratings here; the answer only feeds the
/// anonymous exchange numbers.
class ExchangeStep extends StatefulWidget {
  const ExchangeStep({
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

  @override
  State<ExchangeStep> createState() => _ExchangeStepState();
}

class _ExchangeStepState extends State<ExchangeStep> {
  static const _yes = 'Yes';
  static const _notYet = 'Not yet';

  final _formKey = GlobalKey<FormState>();
  late bool _went = widget.profile.exchange != null;
  late ExchangeProgram _program =
      widget.profile.exchange?.program ?? ExchangeProgram.erasmus;
  String? _host;
  String? _term;
  bool _triedToFinish = false;

  void _finish() {
    if (!_went) {
      widget.onContinue(widget.profile.withExchange(null));
      return;
    }
    final form = _formKey.currentState!;
    if (!form.validate()) {
      setState(() => _triedToFinish = true);
      return;
    }
    form.save();
    widget.onContinue(
      widget.profile.withExchange(
        ExchangeInfo(hostUniversity: _host!, term: _term!, program: _program),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SetupStepScaffold(
      step: 4,
      title: 'Have you been on exchange?',
      subtitle: 'Helps others see where SU students usually go.',
      primaryLabel: 'Finish',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      onPrimary: _finish,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedChoice<String>(
            semanticLabel: 'Exchange',
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
    final saved = widget.profile.exchange;
    return Form(
      key: _formKey,
      autovalidateMode: _triedToFinish
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDropdownFormField<String>(
            label: 'Host university',
            hintText: 'Choose a university',
            items: MockData.hostUniversities,
            initialValue: saved?.hostUniversity,
            validator: (value) =>
                value == null ? 'Choose your host university.' : null,
            onSaved: (value) => _host = value,
          ),
          const SizedBox(height: 22),
          AppDropdownFormField<String>(
            label: 'Term',
            hintText: 'Choose a term',
            items: MockData.terms.skip(1).toList(),
            initialValue: saved?.term,
            validator: (value) => value == null ? 'Pick a term.' : null,
            onSaved: (value) => _term = value,
          ),
          const SizedBox(height: 22),
          const FieldLabel('Program'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final program in ExchangeProgram.values)
                AppChip(
                  label: program.label,
                  selected: program == _program,
                  onTap: () => setState(() => _program = program),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
