import 'package:flutter/material.dart';

import '../shell/team_placeholder_screen.dart';

/// Community tab: exchange maps and program pages.
// TODO(Emine Sena Cesur, Nil Sözlü): replace this placeholder.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamPlaceholderScreen(
      title: 'Community',
      owner: 'Emine Sena Cesur, Nil Sözlü',
      description:
          'Exchange maps (Erasmus and world) and program pages '
          '(major, minor, double major, usual route, posts).',
    );
  }
}
