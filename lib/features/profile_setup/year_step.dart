import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/segmented_choice.dart';
import '../../data/mock_data.dart';
import '../../models/user_profile.dart';
import 'widgets/setup_step_scaffold.dart';

/// Step 2: class year, current term and the term the student started in.
class YearStep extends StatefulWidget {
  const YearStep({
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
  State<YearStep> createState() => _YearStepState();
}

class _YearStepState extends State<YearStep> {
  late String? _classYear = widget.profile.classYear;
  late String? _currentTerm =
      widget.profile.currentTerm ?? MockData.currentTerm;
  late String? _startTerm = widget.profile.startTerm;

  @override
  Widget build(BuildContext context) {
    return SetupStepScaffold(
      step: 2,
      title: 'Where are you in your degree?',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      onPrimary: () => widget.onContinue(
        widget.profile.withYear(
          classYear: _classYear,
          currentTerm: _currentTerm,
          startTerm: _startTerm,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FieldLabel('Class year'),
          const SizedBox(height: AppSpacing.sm),
          SegmentedChoice<String>(
            semanticLabel: 'Class year',
            options: MockData.classYears,
            value: _classYear,
            onChanged: (value) => setState(() => _classYear = value),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppDropdownField<String>(
            label: 'Current term',
            items: MockData.currentTerms,
            value: _currentTerm,
            onChanged: (value) => setState(() => _currentTerm = value),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppDropdownField<String>(
            label: 'You started in',
            hintText: 'Choose a term',
            items: MockData.startTerms,
            value: _startTerm,
            onChanged: (value) => setState(() => _startTerm = value),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Used to show which year students usually take a course.',
            style: AppTextStyles.helper,
          ),
        ],
      ),
    );
  }
}
