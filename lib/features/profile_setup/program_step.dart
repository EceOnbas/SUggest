import 'package:flutter/material.dart';

import '../../core/widgets/app_dropdown_field.dart';
import '../../data/mock_data.dart';
import '../../models/user_profile.dart';
import 'widgets/setup_step_scaffold.dart';

/// Step 1: major, plus optional double major and minor.
class ProgramStep extends StatefulWidget {
  const ProgramStep({
    super.key,
    required this.profile,
    required this.onBack,
    required this.onContinue,
    required this.onSkip,
  });

  /// The answers so far, shown again when the user comes back.
  final UserProfile profile;
  final VoidCallback onBack;
  final ValueChanged<UserProfile> onContinue;
  final VoidCallback onSkip;

  @override
  State<ProgramStep> createState() => _ProgramStepState();
}

class _ProgramStepState extends State<ProgramStep> {
  /// Shown in the optional lists for "I don't have one".
  static const _none = 'None';

  late String? _major = widget.profile.major;
  late String _doubleMajor = widget.profile.doubleMajor ?? _none;
  late String _minor = widget.profile.minor ?? _none;

  @override
  Widget build(BuildContext context) {
    return SetupStepScaffold(
      step: 1,
      title: 'What do you study?',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      onPrimary: () => widget.onContinue(
        widget.profile.withProgram(
          major: _major,
          doubleMajor: _doubleMajor == _none ? null : _doubleMajor,
          minor: _minor == _none ? null : _minor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppDropdownField<String>(
            label: 'Major',
            hintText: 'Choose your major',
            items: MockData.majors,
            value: _major,
            onChanged: (value) => setState(() => _major = value),
          ),
          const SizedBox(height: 22),
          AppDropdownField<String>(
            label: 'Double major',
            optional: true,
            items: const [_none, ...MockData.doubleMajors],
            value: _doubleMajor,
            onChanged: (value) => setState(() => _doubleMajor = value!),
          ),
          const SizedBox(height: 22),
          AppDropdownField<String>(
            label: 'Minor',
            optional: true,
            items: const [_none, ...MockData.minors],
            value: _minor,
            onChanged: (value) => setState(() => _minor = value!),
          ),
        ],
      ),
    );
  }
}
