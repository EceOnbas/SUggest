import 'package:flutter/material.dart';

import '../shell/team_placeholder_screen.dart';

/// Reset your password. Placeholder until the screen is built.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamPlaceholderScreen(
      title: 'Reset your password',
      owner: 'Beren Güler',
      description: 'SU email and Send reset link.',
      showBackButton: true,
    );
  }
}
