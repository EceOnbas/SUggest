import 'package:flutter/material.dart';

import '../shell/team_placeholder_screen.dart';

/// Create account. Placeholder until the screen is built.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamPlaceholderScreen(
      title: 'Create account',
      owner: 'Beren Güler',
      description: 'SU email, password rules and community rules.',
      showBackButton: true,
    );
  }
}
