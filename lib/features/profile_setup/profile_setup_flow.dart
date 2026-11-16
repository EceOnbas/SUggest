import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import 'all_set_screen.dart';
import 'courses_step.dart';
import 'exchange_step.dart';
import 'profile_intro_screen.dart';
import 'program_step.dart';
import 'year_step.dart';

/// The screens of profile setup, in order.
enum SetupStep { intro, program, year, courses, exchange, allSet }

/// Runs profile setup: the intro, four steps and "You're all set".
///
/// It keeps the answers in one [UserProfile] draft while the user moves
/// forward and back, and saves it at the end. Any step can be skipped;
/// a skipped step leaves its part of the profile empty.
class ProfileSetupFlow extends StatefulWidget {
  const ProfileSetupFlow({super.key});

  @override
  State<ProfileSetupFlow> createState() => _ProfileSetupFlowState();
}

class _ProfileSetupFlowState extends State<ProfileSetupFlow> {
  SetupStep _step = SetupStep.intro;
  UserProfile _draft = const UserProfile();
  bool _saving = false;

  void _goTo(SetupStep step) => setState(() => _step = step);

  void _next() => _goTo(SetupStep.values[_step.index + 1]);

  void _back() => _goTo(SetupStep.values[_step.index - 1]);

  /// Keeps a step's answers and moves on.
  void _saveAndNext(UserProfile updated) {
    _draft = updated;
    _next();
  }

  /// Saves [profile] and lets the auth gate open Home.
  Future<void> _finish(UserProfile profile) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await AuthScope.of(context).saveProfile(profile);
      if (mounted) await AppRoutes.restart(context);
    } on AuthException {
      if (mounted) {
        AppToast.show(
          context,
          'No connection. Check your internet and try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // The phone's back gesture goes to the previous step, not out of
      // setup.
      canPop: _step == SetupStep.intro,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(_step), child: _buildStep()),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      SetupStep.intro => ProfileIntroScreen(
        onStart: _next,
        skipping: _saving,
        // Skip for now saves an empty profile, so Home opens next time.
        onSkip: () => _finish(const UserProfile()),
      ),
      SetupStep.program => ProgramStep(
        profile: _draft,
        onBack: _back,
        onContinue: _saveAndNext,
        onSkip: _next,
      ),
      SetupStep.year => YearStep(
        profile: _draft,
        onBack: _back,
        onContinue: _saveAndNext,
        onSkip: _next,
      ),
      SetupStep.courses => CoursesStep(
        profile: _draft,
        onBack: _back,
        onContinue: _saveAndNext,
        onSkip: _next,
      ),
      SetupStep.exchange => ExchangeStep(
        profile: _draft,
        onBack: _back,
        onContinue: _saveAndNext,
        onSkip: _next,
      ),
      SetupStep.allSet => AllSetScreen(
        saving: _saving,
        onStart: () => _finish(_draft),
      ),
    };
  }
}
