import 'package:flutter/material.dart';

import '../shell/team_placeholder_screen.dart';

/// Welcome. Placeholder until the screen is built.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamPlaceholderScreen(
      title: 'Welcome',
      owner: 'Beren Güler',
      description: 'Sakura band, Create account and Log in.',
      showBackButton: true,
    );
  }
}
