import 'package:flutter/material.dart';

import '../shell/team_placeholder_screen.dart';

/// Log in. Placeholder until the screen is built.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamPlaceholderScreen(
      title: 'Log in',
      owner: 'Beren Güler',
      description: 'SU email, password and Forgot password?',
      showBackButton: true,
    );
  }
}
