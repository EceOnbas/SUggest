import 'package:flutter/material.dart';

import '../shell/team_placeholder_screen.dart';

/// Set up your private profile. Placeholder until the screen is built.
class ProfileIntroScreen extends StatelessWidget {
  const ProfileIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamPlaceholderScreen(
      title: 'Set up your private profile',
      owner: 'Beren Güler',
      description: 'Intro, then program, year, courses taken and exchange.',
      showBackButton: true,
    );
  }
}
