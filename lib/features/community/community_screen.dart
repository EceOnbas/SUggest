import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/widgets/secondary_button.dart';
import '../shell/team_placeholder_screen.dart';

/// Community tab: exchange maps and program pages.
// TODO(Emine Sena Cesur, Nil Sözlü): replace this placeholder.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TeamPlaceholderScreen(
      title: 'Community',
      owner: 'Emine Sena Cesur, Nil Sözlü',
      description:
          'Exchange maps (Erasmus and world) and program pages '
          '(major, minor, double major, usual route, posts).',
      actions: [
        SecondaryButton(
          label: 'Programs',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.programs),
        ),
        SecondaryButton(
          label: 'Admin panel',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.admin),
        ),
      ],
    );
  }
}
