import 'package:flutter/material.dart';

import '../shell/team_placeholder_screen.dart';

/// Check your inbox. Placeholder until the screen is built.
class CheckInboxScreen extends StatelessWidget {
  const CheckInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamPlaceholderScreen(
      title: 'Check your inbox',
      owner: 'Beren Güler',
      description: 'Verification link, I\'ve verified and Resend email.',
      showBackButton: true,
    );
  }
}
